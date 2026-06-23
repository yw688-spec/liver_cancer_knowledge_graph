# HCC Clinical Knowledge Base (Prolog)

A modular, English-language Prolog knowledge graph for **hepatocellular carcinoma (HCC)** clinical decision support, compiled from four guidelines and structured for maintenance and provenance-aware querying.

Built with **SWI-Prolog 9.x**; the deployment runs it via the `pyswip` bridge on **SWI-Prolog 10.0.0**.

---

## Source guidelines & authority

The knowledge base integrates four guidelines. The **NHC (China) 2026** guideline is the final authority; where guidelines disagree, the `conflict_resolution/4` table records the NHC-anchored ruling.

| Code   | Guideline                                   | Region | Authority rank |
|--------|---------------------------------------------|--------|----------------|
| `nhc`  | National Health Commission of China, 2026   | China  | 5 (primary)    |
| `caca` | China Anti-Cancer Association, 2026          | China  | 4              |
| `nccn` | NCCN, 2026                                  | USA    | 3              |
| `esmo` | ESMO, 2025                                  | Europe | 3              |

---

## File / module layout

Each clinical domain is a **separate file** so modules can be maintained independently. `hcc_kb.pl` is the integration interface — load only that.

```
prolog/
│   ── fact layer: sources + 5 knowledge modules ──
├── hcc_kb.pl      ← INTEGRATION INTERFACE (load this; pulls in sources + 5 modules)
├── sources.pl     ← guideline registry, authority ranking, provenance helpers (the only module)
├── ontology.pl    ← Module 1  Ontology
├── grading.pl     ← "Grading / Staging" (分级方式)
├── diagnosis.pl   ← Module 3  Diagnosis
├── treatment.pl   ← Module 4  Treatment
├── evidence.pl    ← Module 2  Evidence system + conflict resolution
│
│   ── reasoning & reference layers (NOT pulled in by hcc_kb.pl; loaded separately) ──
├── reasoning.pl   ← inference on top of the facts (CNLC classifier, Child-Pugh/ALBI from labs)
├── references.pl  ← maps each src Section code to real guideline document + section title + page
│
├── tests.pl       ← plunit regression suite (pins exact expected values)
└── README.md
```

> **Load order.** `hcc_kb.pl` loads `sources` (via `use_module`) then `ensure_loaded`s the five knowledge modules. `reasoning.pl` and `references.pl` are **not** pulled in by `hcc_kb.pl` — the backend (`backend/kb.py`) consults them separately, in the order `hcc_kb.pl → reasoning.pl → references.pl`. `tests.pl` loads `hcc_kb` + `reasoning`.

| Module        | Covers                                                                                                  |
|---------------|---------------------------------------------------------------------------------------------------------|
| **ontology**  | cancer types, gross morphology, histologic architecture, HCC/ICC subtypes, risk factors, etiologic synergy, molecular subtypes, genetic susceptibility |
| **grading**   | differentiation grade (Edmondson–Steiner), MVI (M0–M2b), ECOG PS, Child-Pugh, ALBI, surgical liver-function thresholds (ICG-R15, FLR), CNLC staging, CNLC↔BCLC mapping, risk models (aMAP/PAGE-B…), transplant criteria, PVTT (Cheng) typing |
| **diagnosis** | screening/surveillance, imaging modalities, serum markers, Baveno-VII portal-hypertension, diagnostic pathways, biopsy indications, IHC, pathology response, response criteria, follow-up, recurrence sites |
| **treatment** | CNLC-staged roadmap, resection, transplant, ablation, TACE/HAIC/TARE, radiotherapy, systemic 1L/2L, molecular-targeted, the absolute antiviral rule, TCM, PVTT management, rupture, patient education |
| **evidence**  | evidence levels, recommendation strength, clinical & negative trials, ESMO-MCBS, `conflict_resolution/4` |

Current size: **396 sourced facts** across the five modules.

### Interface, reasoning & reference files

| File | Purpose | Key predicates / entry points |
|------|---------|-------------------------------|
| **hcc_kb.pl** | Integration interface. Loads `sources` + the five modules; provides generic cross-module querying and stats. Load this in an interactive session. | `fact_with_source/2`, `kb_stats`, `help` |
| **sources.pl** | Provenance backbone and the **only Prolog module**. Guideline registry, authority ranking, and helpers to read a `src/2` term. | `guideline/5`, `authority_rank/2`, `higher_authority/2`, `src_guidelines/2`, `src_section/2`, `primary_source/2` |
| **reasoning.pl** | Inference layer loaded **after** `hcc_kb`; combines base facts, never mutates them. The CNLC classifier encodes decision logic in clause order (first match wins → explainable). | `cnlc_classify/7`, `cnlc_classify_explained/8`, `child_pugh_from_labs/12`, `albi_from_labs/4` |
| **references.pl** | Reference layer. Maps each `src(_, Section)` internal code (e.g. `'Treatment 4.7'`) to the **real** guideline document, section title and page, so a citation is traceable to "which document, which section, which page". | `guideline_doc/2`, `reference/4` (Section, Guideline, SectionTitle, Locator) |
| **tests.pl** | plunit regression suite. Assertions pin exact expected values so any change to a fact, source tag, or count is caught. | `run_tests` |

---

## Provenance convention (every entry is sourced)

The **last argument of every clinical fact** is a source term:

```prolog
src(Guidelines, Section)
```

* `Guidelines` — a **non-empty list** of guideline codes. The **first element is the primary attributing guideline**; any others are co-attributions.
  e.g. `src([nhc], 'Ontology 1.1')`, `src([nhc,caca,nccn], 'Conflict 2.4')`
* `Section` — an atom locating the entry in the source document, e.g. `'Treatment 4.2'`.

Two facts hold a descriptive string in the last slot and keep their source in a companion fact (still fully enumerable):

| Fact               | Companion source fact |
|--------------------|-----------------------|
| `sampling_method/1`| `sampling_src/1`      |
| `esmo_mcbs/3`      | `esmo_mcbs_src/1`     |

Every fact predicate is registered with `kb_fact_predicate(Module, Name/Arity)`, which lets the interface enumerate facts and extract provenance **generically** — no per-predicate code.

---

## Real document references (`references.pl`)

The `Section` atom above (e.g. `'Treatment 4.7'`) is an **internal KB locator**, not a real page. `references.pl` resolves it to actual guideline coordinates:

```prolog
guideline_doc(nhc, '《原发性肝癌诊疗指南（2026年版）》 … 协和医学杂志 2026;17(3):735-770').
reference('Treatment 4.7', nhc, '系统抗肿瘤治疗（一线 / 二线）', '期刊 p.763-766').
```

* `guideline_doc(Guideline, FullCitation)` — one row per source document.
* `reference(Section, Guideline, SectionTitle, Locator)` — one row per `(Section, Guideline)` pair; `Locator` is the real page (NHC uses journal pages, the others use PDF pages).

All **87** `(Section, Guideline)` pairs are filled. The backend's `kb.py._src()` joins these onto every `src` it returns, so the frontend shows the real document/section/page under each provenance badge. A missing pair simply yields no real reference (the guideline badge still shows). Source PDFs live in the project's `reference/` folder.

---

## Loading

```prolog
?- [hcc_kb].
HCC knowledge base loaded. Type  help.  for the query interface.

?- help.
```

Or from the shell:

```bash
swipl hcc_kb.pl
```

---

## Query interface

### Provenance
| Goal | Meaning |
|------|---------|
| `cite(Goal)` | print matching fact(s) with a readable citation |
| `source_of(Goal, Src)` | unify `Src = src(Guidelines, Section)` for a matching fact |
| `fact_with_source(Goal, Src)` | enumerate **every** sourced fact in the KB |

### By source
| Goal | Meaning |
|------|---------|
| `facts_from(Code)` | every fact citing a guideline (`nhc`/`caca`/`nccn`/`esmo`), primary or co-attribution |
| `primary_facts_from(Code)` | only facts whose **primary** attribution is `Code` |

### Structure
| Goal | Meaning |
|------|---------|
| `modules` | list modules and their registered predicates |
| `kb_stats` | fact counts per module + total |

### Clinical shortcuts
| Goal | Meaning |
|------|---------|
| `staging(Stage)` | CNLC stage definition + BCLC mapping (accepts `ia`, `Ia`, `IA`) |
| `treatment_for(Stage)` | treatment roadmap for a CNLC stage |
| `pathway_for(SizeDesc)` | diagnostic pathway by nodule-size description (substring match) |
| `conflict(Topic)` | cross-guideline conflict ruling (leave `Topic` a variable to list all) |

---

## Examples

```prolog
% Cite an ontology fact
?- cite(cancer_type(hcc, Name, Pct, _)).
cancer_type(hcc,'Hepatocellular Carcinoma','80%',src([nhc],'Ontology 1.1'))
    [National Health Commission of China | Ontology 1.1]

% Stage definition + mapping, and the matching treatment roadmap
?- staging(ia).
?- treatment_for(ia).

% Everything attributed to ESMO
?- facts_from(esmo).

% How a cross-guideline disagreement is resolved
?- conflict(hbv_antiviral).

% Raw provenance for any fact, for programmatic use
?- source_of(child_pugh(Class, Range, _, _), Src).

% List every sourced fact (use with care / a limit)
?- fact_with_source(Goal, Src).
```

---

## Maintenance notes

* **Adding a fact:** append it to the relevant module file and ensure its last argument is `src([...], 'Section')`. If it introduces a new predicate, also add a `kb_fact_predicate(Module, Name/Arity)` registration line — the interface then picks it up automatically.
* **Adding a new `Section`:** to keep it traceable, add a `reference/4` row in `references.pl` for each guideline that cites it (otherwise the frontend shows only the guideline name, no real page).
* **Validate a module standalone:** `swipl -q -g halt module.pl` (no output = clean load).
* **Validate the whole system:** `swipl -q -g "demo, halt" hcc_kb.pl`.
* **Run the regression tests:** `swipl -q -g "(run_tests -> halt(0) ; halt(1))" tests.pl` (CI-friendly: exits non-zero on any failure).
* Source comments are kept ASCII-only to avoid multibyte-encoding warnings under `swipl`.
