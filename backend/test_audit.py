# -*- coding: utf-8 -*-
"""
Unit tests for audit.py (stdlib unittest, no pyswip / no new dependency).

Run:
    cd backend && python -m unittest test_audit -v
"""
import os
import sqlite3
import tempfile
import threading
import unittest

import audit


class AuditChainTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        audit.set_db_path(os.path.join(self.tmp, "audit_test.db"))
        audit._reset_kb_version_cache()

    def tearDown(self):
        audit.set_db_path(audit._DEFAULT_DB)

    def _decision(self, patient="p1"):
        return audit.record_decision(
            endpoint="/api/staging",
            inp={"ps": 0, "child_pugh": "A"},
            output={"stage": "Ia"},
            user_id="dr_wang", role="hepatologist", patient_ref=patient,
            rule_chain="single tumour <=5cm", citations=[{"g": ["nhc"], "sec": "T4.1"}],
        )

    def test_first_record_uses_genesis(self):
        rec = self._decision()
        conn = audit._connect()
        row = conn.execute("SELECT * FROM audit_log WHERE record_id=?",
                           (rec["decision_id"],)).fetchone()
        self.assertEqual(row["seq"], 1)
        self.assertEqual(row["prev_hash"], audit.GENESIS)
        business = {k: row[k] for k in audit.BUSINESS_FIELDS}
        self.assertEqual(row["record_hash"],
                         audit._compute_hash(audit.GENESIS, business))

    def test_chain_links_prev_to_record(self):
        first = self._decision()
        second = self._decision()
        self.assertNotEqual(first["record_hash"], second["record_hash"])
        conn = audit._connect()
        row2 = conn.execute("SELECT prev_hash FROM audit_log WHERE record_id=?",
                            (second["decision_id"],)).fetchone()
        self.assertEqual(row2["prev_hash"], first["record_hash"])

    def test_verify_clean_chain(self):
        self._decision()
        self._decision()
        result = audit.verify_chain()
        self.assertTrue(result["ok"])
        self.assertEqual(result["count"], 2)
        self.assertIsNone(result["first_break_seq"])

    def test_verify_detects_tamper(self):
        self._decision()
        target = self._decision()
        self._decision()
        # Tamper with the middle row's payload directly in the DB.
        conn = audit._connect()
        conn.execute("UPDATE audit_log SET output_json=? WHERE record_id=?",
                     ('{"stage":"IV"}', target["decision_id"]))
        conn.commit()
        result = audit.verify_chain()
        self.assertFalse(result["ok"])
        self.assertEqual(result["first_break_seq"], 2)

    def test_disposition_appends_and_links(self):
        dec = self._decision()
        disp = audit.set_disposition(dec["decision_id"], "override",
                                     reason="patient comorbidity", user_id="dr_li")
        self.assertIsNotNone(disp)
        self.assertTrue(audit.verify_chain()["ok"])
        record = audit.get_record(dec["decision_id"])
        self.assertEqual(len(record["dispositions"]), 1)
        self.assertEqual(record["dispositions"][0]["refers_to"], dec["decision_id"])

    def test_disposition_unknown_decision_returns_none(self):
        self.assertIsNone(audit.set_disposition("does_not_exist", "accept"))
        conn = audit._connect()
        count = conn.execute("SELECT COUNT(*) c FROM audit_log").fetchone()["c"]
        self.assertEqual(count, 0)

    def test_disposition_bad_action_raises(self):
        dec = self._decision()
        with self.assertRaises(audit.DispositionError):
            audit.set_disposition(dec["decision_id"], "delete")

    def test_kb_version_stable_and_change_sensitive(self):
        v1 = audit.kb_version()
        self.assertEqual(v1, audit.kb_version())
        # Point KB_DIR at a temp dir with different .pl content.
        kb_dir = os.path.join(self.tmp, "kb")
        os.makedirs(kb_dir)
        with open(os.path.join(kb_dir, "x.pl"), "w") as fh:
            fh.write("fact(1).")
        orig = audit.KB_DIR
        try:
            audit.KB_DIR = kb_dir
            audit._reset_kb_version_cache()
            v2 = audit.kb_version()
            self.assertNotEqual(v1, v2)
            with open(os.path.join(kb_dir, "x.pl"), "w") as fh:
                fh.write("fact(2).")
            audit._reset_kb_version_cache()
            self.assertNotEqual(v2, audit.kb_version())
        finally:
            audit.KB_DIR = orig
            audit._reset_kb_version_cache()

    def test_canonical_hash_ignores_key_order(self):
        a = audit._canon({"b": 1, "a": 2})
        b = audit._canon({"a": 2, "b": 1})
        self.assertEqual(a, b)

    def test_concurrent_writes_keep_chain_linear(self):
        errors = []

        def worker():
            try:
                for _ in range(20):
                    self._decision()
            except Exception as e:  # pragma: no cover
                errors.append(e)

        threads = [threading.Thread(target=worker) for _ in range(5)]
        for t in threads:
            t.start()
        for t in threads:
            t.join()
        self.assertEqual(errors, [])
        result = audit.verify_chain()
        self.assertTrue(result["ok"])
        self.assertEqual(result["count"], 100)


if __name__ == "__main__":
    unittest.main()
