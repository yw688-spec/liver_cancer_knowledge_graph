# -*- coding: utf-8 -*-
"""
audit.py -- Tamper-evident decision audit trail + KB versioning.

Every recommendation-producing decision is appended as one immutable row in a
hash-chained SQLite table. Physician dispositions (accept / override) are
appended as separate rows that reference the decision, so the original decision
row is never mutated. `verify_chain` recomputes the whole chain and reports the
first break.

Storage is SQLite (stdlib, zero new dependency) for the demo phase. The write
path (record -> chain) is the only place that must stay append-only; a future
Postgres migration keeps the same schema and grants the app INSERT-only.

This module deliberately does NOT import the pyswip bridge: KB versioning hashes
the .pl files directly, so the audit layer (and its tests) run without SWI-Prolog.
"""
import hashlib
import json
import os
import sqlite3
import threading
import uuid
from datetime import datetime, timezone

# --- paths -------------------------------------------------------------------
_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_DEFAULT_KB_DIR = os.path.join(_PROJECT_ROOT, "prolog")
KB_DIR = os.environ.get("HCC_KB_DIR", _DEFAULT_KB_DIR)

_DEFAULT_DB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "audit.db")
DB_PATH = os.environ.get("HCC_AUDIT_DB", _DEFAULT_DB)

GENESIS = "GENESIS"
ALLOWED_ACTIONS = {"accept", "override", "modify"}

# The business fields that get hashed, in a fixed set. seq/prev_hash/record_hash
# are chain bookkeeping and are NOT part of the hashed payload.
BUSINESS_FIELDS = (
    "record_id", "event_type", "ts_utc", "user_id", "role", "patient_ref",
    "endpoint", "input_json", "output_json", "rule_chain", "citations_json",
    "kb_version", "refers_to",
)

_lock = threading.Lock()
_conn = None
_kb_version_cache = None


class DispositionError(Exception):
    """Raised for a malformed disposition (unknown action)."""


# --- connection / schema -----------------------------------------------------
def _connect():
    global _conn
    if _conn is None:
        parent = os.path.dirname(DB_PATH)
        if parent:
            os.makedirs(parent, exist_ok=True)
        conn = sqlite3.connect(DB_PATH, check_same_thread=False)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA journal_mode=WAL")
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS audit_log (
              seq          INTEGER PRIMARY KEY AUTOINCREMENT,
              record_id    TEXT NOT NULL,
              event_type   TEXT NOT NULL,
              ts_utc       TEXT NOT NULL,
              user_id      TEXT NOT NULL,
              role         TEXT NOT NULL,
              patient_ref  TEXT NOT NULL,
              endpoint     TEXT NOT NULL,
              input_json   TEXT NOT NULL,
              output_json  TEXT NOT NULL,
              rule_chain   TEXT NOT NULL,
              citations_json TEXT NOT NULL,
              kb_version   TEXT NOT NULL,
              refers_to    TEXT NOT NULL,
              prev_hash    TEXT NOT NULL,
              record_hash  TEXT NOT NULL
            )
            """
        )
        conn.commit()
        _conn = conn
    return _conn


def set_db_path(path):
    """Point the module at a different DB file (used by tests). Resets caches."""
    global DB_PATH, _conn
    if _conn is not None:
        _conn.close()
    _conn = None
    DB_PATH = path


# --- hashing -----------------------------------------------------------------
def _canon(value):
    """Deterministic JSON: sorted keys, UTF-8 preserved, compact."""
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


def _compute_hash(prev_hash, business):
    payload = prev_hash + _canon({k: business[k] for k in BUSINESS_FIELDS})
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def _now_utc():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")


def _last_hash(conn):
    row = conn.execute(
        "SELECT record_hash FROM audit_log ORDER BY seq DESC LIMIT 1"
    ).fetchone()
    return row["record_hash"] if row else GENESIS


def _append(conn, business):
    prev = _last_hash(conn)
    record_hash = _compute_hash(prev, business)
    conn.execute(
        """
        INSERT INTO audit_log
          (record_id, event_type, ts_utc, user_id, role, patient_ref, endpoint,
           input_json, output_json, rule_chain, citations_json, kb_version,
           refers_to, prev_hash, record_hash)
        VALUES (:record_id, :event_type, :ts_utc, :user_id, :role, :patient_ref,
                :endpoint, :input_json, :output_json, :rule_chain, :citations_json,
                :kb_version, :refers_to, :prev_hash, :record_hash)
        """,
        {**business, "prev_hash": prev, "record_hash": record_hash},
    )
    conn.commit()
    return record_hash


# --- KB versioning -----------------------------------------------------------
def kb_version():
    """sha256 over all prolog/*.pl (name + bytes), so a decision can be tied to
    the exact knowledge base that produced it. Cached in memory."""
    global _kb_version_cache
    if _kb_version_cache is None:
        h = hashlib.sha256()
        for name in sorted(f for f in os.listdir(KB_DIR) if f.endswith(".pl")):
            with open(os.path.join(KB_DIR, name), "rb") as fh:
                h.update(name.encode("utf-8"))
                h.update(fh.read())
        _kb_version_cache = "sha256:" + h.hexdigest()
    return _kb_version_cache


def _reset_kb_version_cache():
    global _kb_version_cache
    _kb_version_cache = None


# --- public API --------------------------------------------------------------
def record_decision(endpoint, inp, output, user_id=None, role=None,
                    patient_ref=None, rule_chain=None, citations=None):
    """Append one recommendation-producing decision. Returns its id + hash."""
    business = {
        "record_id": uuid.uuid4().hex,
        "event_type": "decision",
        "ts_utc": _now_utc(),
        "user_id": user_id or "unknown",
        "role": role or "unknown",
        "patient_ref": patient_ref or "",
        "endpoint": endpoint,
        "input_json": _canon(inp),
        "output_json": _canon(output),
        "rule_chain": rule_chain or "",
        "citations_json": _canon(citations or []),
        "kb_version": kb_version(),
        "refers_to": "",
    }
    with _lock:
        conn = _connect()
        record_hash = _append(conn, business)
    return {"decision_id": business["record_id"], "record_hash": record_hash}


def set_disposition(decision_id, action, reason=None, user_id=None, role=None):
    """Append a physician disposition referencing an existing decision.
    Returns id + hash, or None if the decision does not exist. Raises
    DispositionError on an unknown action."""
    if action not in ALLOWED_ACTIONS:
        raise DispositionError(f"unknown action: {action!r}")
    with _lock:
        conn = _connect()
        exists = conn.execute(
            "SELECT 1 FROM audit_log WHERE record_id=? AND event_type='decision' LIMIT 1",
            (decision_id,),
        ).fetchone()
        if not exists:
            return None
        business = {
            "record_id": uuid.uuid4().hex,
            "event_type": "disposition",
            "ts_utc": _now_utc(),
            "user_id": user_id or "unknown",
            "role": role or "unknown",
            "patient_ref": "",
            "endpoint": "",
            "input_json": _canon({"action": action, "reason": reason or ""}),
            "output_json": _canon(None),
            "rule_chain": "",
            "citations_json": _canon([]),
            "kb_version": kb_version(),
            "refers_to": decision_id,
        }
        record_hash = _append(conn, business)
    return {"disposition_id": business["record_id"], "record_hash": record_hash}


def _row_to_dict(row):
    return {k: row[k] for k in row.keys()}


def get_record(record_id):
    """Fetch a decision plus any dispositions that reference it."""
    conn = _connect()
    rows = conn.execute(
        "SELECT * FROM audit_log WHERE record_id=? OR refers_to=? ORDER BY seq ASC",
        (record_id, record_id),
    ).fetchall()
    if not rows:
        return None
    decision = None
    dispositions = []
    for row in rows:
        d = _row_to_dict(row)
        if d["event_type"] == "decision" and d["record_id"] == record_id:
            decision = d
        elif d["refers_to"] == record_id:
            dispositions.append(d)
    return {"decision": decision, "dispositions": dispositions}


def verify_chain():
    """Recompute the whole chain. Reports the first row whose stored hash or
    prev_hash does not match, which pinpoints tampering."""
    conn = _connect()
    rows = conn.execute("SELECT * FROM audit_log ORDER BY seq ASC").fetchall()
    prev = GENESIS
    for row in rows:
        business = {k: row[k] for k in BUSINESS_FIELDS}
        expected = _compute_hash(prev, business)
        if row["prev_hash"] != prev or row["record_hash"] != expected:
            return {"ok": False, "count": len(rows), "first_break_seq": row["seq"]}
        prev = row["record_hash"]
    return {"ok": True, "count": len(rows), "first_break_seq": None}
