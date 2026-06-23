% =====================================================================
%  evidence.pl  --  MODULE 2: EVIDENCE SYSTEM & CONFLICT RESOLUTION
%  Evidence-level systems and cross-mappings, recommendation strength,
%  key clinical trials, negative trials, ESMO-MCBS, and the master
%  conflict_resolution/4 table. Every fact ends in src/2 where applicable.
% =====================================================================

:- multifile kb_fact_predicate/2.
:- discontiguous
       evidence_level/4, evidence_map/4, recommendation_strength/5,
       clinical_trial/5, negative_trial/3, esmo_mcbs/3, conflict_resolution/4.

kb_fact_predicate(evidence, evidence_level/4).
kb_fact_predicate(evidence, evidence_map/4).
kb_fact_predicate(evidence, recommendation_strength/5).
kb_fact_predicate(evidence, clinical_trial/5).
kb_fact_predicate(evidence, negative_trial/3).
kb_fact_predicate(evidence, esmo_mcbs/3).
kb_fact_predicate(evidence, conflict_resolution/4).

% ---- 2.1  Evidence-level systems -------------------------------------
% evidence_level(System, Level, Basis, Src)  -- NHC = Oxford CEBM 2011
evidence_level(nhc, 1, 'systematic review of RCTs / single RCT with large effect', src([nhc], 'Evidence 2.1')).
evidence_level(nhc, 2, 'single RCT, or prospective cohort study', src([nhc], 'Evidence 2.1')).
evidence_level(nhc, 3, 'non-randomised controlled cohort / follow-up study', src([nhc], 'Evidence 2.1')).
evidence_level(nhc, 4, 'case series, case-control, or historical control', src([nhc], 'Evidence 2.1')).
evidence_level(nhc, 5, 'mechanism-based reasoning; expert opinion', src([nhc], 'Evidence 2.1')).

% Cross-system evidence mapping  evidence_map(System, NativeGrade, NHCEquivalent, Src)
evidence_map(caca, high,      1,     src([caca], 'Evidence 2.1')).
evidence_map(caca, moderate,  2,     src([caca], 'Evidence 2.1')).
evidence_map(caca, low,       '3-4', src([caca], 'Evidence 2.1')).
evidence_map(caca, very_low,  5,     src([caca], 'Evidence 2.1')).
evidence_map(nccn, category_1,  'Rec A',   src([nccn], 'Evidence 2.1')).
evidence_map(nccn, category_2a, 'Rec A/B', src([nccn], 'Evidence 2.1')).
evidence_map(nccn, category_2b, 'Rec B/C', src([nccn], 'Evidence 2.1')).
evidence_map(nccn, preferred,   'Rec A (preferred)', src([nccn], 'Evidence 2.1')).
evidence_map(esmo, 'I',   1,     src([esmo], 'Evidence 2.1B')).
evidence_map(esmo, 'II',  2,     src([esmo], 'Evidence 2.1B')).
evidence_map(esmo, 'III', 3,     src([esmo], 'Evidence 2.1B')).
evidence_map(esmo, 'IV',  '4-5', src([esmo], 'Evidence 2.1B')).
evidence_map(esmo, 'V',   none,  src([esmo], 'Evidence 2.1B')).

% ---- 2.2  Recommendation strength (NHC 3-tier, authoritative) --------
% recommendation_strength(Tier, Meaning, GRADE, CACA, NCCN, ... ) -> use Src last
recommendation_strength('A', 'strong: high confidence; most should adopt', 'high-quality', 'strong / Cat.1-Preferred', src([nhc], 'Evidence 2.2')).
recommendation_strength('B', 'moderate: moderate confidence; shared decision', 'good evidence', 'strong-weak / Cat.2A-Other', src([nhc], 'Evidence 2.2')).
recommendation_strength('C', 'weak: limited confidence; conditional, shared decision', 'limited evidence', 'weak / Cat.2B-Useful', src([nhc], 'Evidence 2.2')).

% ---- 2.3  Key clinical trials ----------------------------------------
% clinical_trial(Trial, Comparison, Result, Line, Src)
clinical_trial('IMbrave150', 'Atezo+Bev vs Sor (1L)', 'mOS 19.2 vs 13.4 mo (HR=0.66); China subgroup HR=0.53; ORR 27.3% vs 11.9%', first_line, src([nhc, caca, nccn], 'Evidence 2.3')).
clinical_trial('CheckMate-9DW', 'Nivo+Ipi vs Len/Sor (1L)', 'mOS 23.7 vs 20.6 mo (HR=0.79); ORR 36% vs 13%', first_line, src([nhc, nccn], 'Evidence 2.3')).
clinical_trial('CARES-310', 'Camrelizumab+Apatinib vs Sor (1L)', 'mOS 23.8 vs 15.2 mo (HR=0.64); 2-yr OS 49%', first_line, src([nhc], 'Evidence 2.3')).
clinical_trial('ORIENT-32', 'Sintilimab+Bev-biosimilar vs Sor (1L, China)', 'mOS NR vs 10.4 mo (HR=0.57); ORR 21%', first_line, src([nhc, caca], 'Evidence 2.3')).
clinical_trial('SCT-C301', 'Penpulimab+Bev vs Sor (1L, China)', 'mOS 22.1 vs 14.2 mo (HR=0.60)', first_line, src([nhc], 'Evidence 2.3')).
clinical_trial('HEPATORCH', 'Toripalimab+Bev vs Sor (1L, China)', 'mOS 20.0 vs 14.5 mo (HR=0.76)', first_line, src([nhc], 'Evidence 2.3')).
clinical_trial('APOLLO', 'Anlotinib+Penpulimab vs Sor (1L)', 'PFS risk -47%; OS risk -31%', first_line, src([nhc], 'Evidence 2.3')).
clinical_trial('ZGDH3', 'Donafenib vs Sor (1L, China)', 'mOS 12.1 vs 10.3 mo (HR=0.831, superior)', first_line, src([nhc, caca], 'Evidence 2.3')).
clinical_trial('REFLECT', 'Lenvatinib vs Sor (1L)', 'mOS non-inferior (HR=0.92); mPFS +34%', first_line, src([nhc, caca, nccn], 'Evidence 2.3')).
clinical_trial('RATIONALE-301', 'Tislelizumab vs Sor (1L)', 'mOS non-inferior; 15.9 vs 14.1 mo', first_line, src([nhc, nccn], 'Evidence 2.3')).
clinical_trial('HIMALAYA', 'Durva+Treme (STRIDE) vs Sor', 'HR=0.78; 5-yr OS 19.6% vs 9.4%; HBV+ subgroup HR=0.66', first_line, src([nhc, nccn], 'Evidence 2.3')).
clinical_trial('TALENTOP', 'surgery+maintenance vs continued systemic (after conversion)', 'TTF 20.4 vs 11.8 mo (HR=0.60); L1/Rec A', conversion, src([nhc], 'Evidence 2.3')).
clinical_trial('LEAP-012', 'TACE+Len+Pembro vs TACE+placebo', 'PFS risk -34%; L1/Rec A', adjuvant, src([nhc], 'Evidence 2.3')).
clinical_trial('EMERALD-1', 'TACE+Durva+Bev vs TACE+placebo', 'mPFS 15.0 vs 8.2 mo (HR=0.77); G5 AE rose 5.5%->10.4%', adjuvant, src([nccn, esmo], 'Evidence 2.3')).
clinical_trial('RESORCE', 'regorafenib vs placebo (2L, post-sorafenib)', 'death -37%; PFS -54%', second_line, src([nhc, caca, nccn], 'Evidence 2.3')).
clinical_trial('AHELP', 'apatinib vs placebo (2L, China)', 'mOS 8.7 vs 6.8 mo; death -21.5%', second_line, src([nhc, caca, nccn], 'Evidence 2.3')).
clinical_trial('REACH-2', 'ramucirumab vs placebo (2L, AFP>=400)', 'death -29%; PFS -55%', second_line, src([nhc, nccn], 'Evidence 2.3')).
clinical_trial('KEYNOTE-394', 'pembrolizumab vs placebo (2L, Asia-Pacific)', 'mOS 14.6 vs 13.0 mo (HR=0.79)', second_line, src([nhc, nccn], 'Evidence 2.3')).
clinical_trial('CELESTIAL', 'cabozantinib vs placebo (2L+, post-sorafenib)', 'mOS 10.2 vs 8.0 mo (HR=0.76); mPFS 5.2 vs 1.9 mo', second_line, src([nccn], 'Evidence 2.3')).
clinical_trial('EACH', 'FOLFOX4 vs doxorubicin (1L, Asia)', 'mOS 6.47 vs 4.90 mo; death -21.5%', first_line, src([nhc, caca], 'Evidence 2.3')).
clinical_trial('XXL', 'OLT vs local therapy (Metroticket 2.0)', 'stopped early for OLT benefit (HR=0.32, P=0.035)', transplant, src([esmo], 'Evidence 2.3')).
clinical_trial('TRACE', 'TARE vs DEB-TACE (intermediate HCC)', 'stopped early (TTP HR<0.39); mOS 30.2 vs 15.6 mo (HR=0.48)', intra_arterial, src([esmo, nccn], 'Evidence 2.3')).

% ---- 2.3A  Negative trials (recorded to prevent mis-recommendation) --
% negative_trial(Trial, Result, Src)
negative_trial('CheckMate-459 (Nivo 1L)', 'negative: mOS HR=0.85, P=0.0522; FDA withdrew nivo mono 2L in 2021', src([caca, nccn], 'Evidence 2.3A')).
negative_trial('KEYNOTE-240 (pembro 2L)', 'negative: OS/PFS improved but missed pre-specified endpoints', src([caca, nccn], 'Evidence 2.3A')).
negative_trial('SCOOP-2/SILIUS (Japanese cisplatin HAIC)', 'negative: cisplatin/5-FU HAIC+sorafenib not superior; does not affect China mFOLFOX-HAIC', src([caca, nccn], 'Evidence 2.3A')).
negative_trial('IMbrave050 adjuvant (updated)', 'RFS benefit not durable -> NCCN withdrew adjuvant Atezo+Bev', src([nccn], 'Evidence 2.3A')).
negative_trial('STORM (adjuvant sorafenib)', 'negative: no OS/RFS/recurrence difference; not recommended', src([nccn], 'Evidence 2.3A')).
negative_trial('LEAP-002 (Len+Pembro 1L)', 'negative: mOS HR=0.84, P=0.023 (missed threshold); not routine', src([nccn], 'Evidence 2.3A')).
negative_trial('TACE then sorafenib', 'multiple RCTs no OS benefit -> NCCN/ESMO do not recommend the sequence', src([nccn, esmo], 'Evidence 2.3A')).
negative_trial('Sirolimus adjuvant OLT (Phase III)', 'no significant RFS improvement -> ESMO does not recommend routine mTOR switch (I,D)', src([esmo], 'Evidence 2.3A')).
negative_trial('Systemic chemo (Western)', 'multiple RCTs no OS improvement -> ESMO strongly discourages (II,D); NHC keeps FOLFOX4 for China NMPA indication', src([esmo], 'Evidence 2.3A')).

% ---- 2.1C  ESMO-MCBS (EMA/FDA-approved regimens only) ----------------
% esmo_mcbs(Regimen, Score, Meaning)  [ESMO]
esmo_mcbs(atezolizumab_bevacizumab, 5, 'substantial clinical benefit').
esmo_mcbs(durvalumab_tremelimumab,  5, 'substantial clinical benefit').
esmo_mcbs(durvalumab_mono,          4, 'substantial clinical benefit').
esmo_mcbs(regorafenib,              4, 'substantial clinical benefit').
esmo_mcbs(sorafenib_1l,             3, 'moderate clinical benefit').
esmo_mcbs(cabozantinib,             3, 'moderate clinical benefit').
esmo_mcbs(ramucirumab_afp400,       1, 'limited clinical benefit').
kb_fact_predicate(evidence, esmo_mcbs_src/1).
esmo_mcbs_src(src([esmo], 'Evidence 2.1C')).

% ---- 2.4  Conflict-resolution table (NHC is final authority) ---------
% conflict_resolution(Topic, NHCAuthority, ResolutionRule, Src)
conflict_resolution(staging_system, 'CNLC (Ia-IV)', 'CNLC primary; BCLC reference only; NCCN 3-class as mapping aid', src([nhc, caca, nccn, esmo], 'Conflict 2.4')).
conflict_resolution(transplant_criteria, 'UCSF recommended', 'UCSF authoritative in China; ESMO recommends Milan (Europe); NCCN UNOS as US-policy note', src([nhc, esmo, nccn], 'Conflict 2.4')).
conflict_resolution(mvi_grading, 'M0/M1/M2a/M2b 4-tier', 'NHC subdivision authoritative; CACA 3-tier / NCCN no grading annotated', src([nhc, caca, nccn], 'Conflict 2.4')).
conflict_resolution(haic_status, 'mFOLFOX-HAIC core', 'NHC authoritative; negative Japanese cisplatin regimen does not affect China recommendation', src([nhc, caca, nccn], 'Conflict 2.4')).
conflict_resolution(hbv_antiviral, 'start immediately if HBsAg+ regardless of DNA', 'absolute rule; NCCN consult-based advice does not override', src([nhc, nccn, esmo], 'Conflict 2.4')).
conflict_resolution(sbrt_dose, '>=30-60 Gy/3-10 Fx, BED>=80 Gy', 'NHC authoritative; NCCN 27.5 Gy lower bound as reference', src([nhc, nccn], 'Conflict 2.4')).
conflict_resolution(conventional_dose, '50-70 Gy', 'NHC authoritative; NCCN 50-66 Gy close', src([nhc, nccn], 'Conflict 2.4')).
conflict_resolution(pvtt_surgery, 'active (type I/II)', 'NHC active strategy authoritative; NCCN conservative stance annotated', src([nhc, nccn], 'Conflict 2.4')).
conflict_resolution(flr_threshold_noncirrhotic, '>=30%', 'NHC authoritative; NCCN >=20% reflects no-ICG-R15 Western context', src([nhc, nccn], 'Conflict 2.4')).
conflict_resolution(stride, 'Rec B (China pending)', 'NHC Rec B authoritative; NCCN Cat.1 Preferred / ESMO I,A annotated', src([nhc, nccn, esmo], 'Conflict 2.4')).
conflict_resolution(nivolumab_mono, 'not recommended', 'FDA withdrew 2L indication 2021; not recommended', src([nhc, nccn], 'Conflict 2.4')).
conflict_resolution(adjuvant_atezo_bev, 'not recommended', 'IMbrave050 update: RFS benefit not durable; not recommended', src([nhc, nccn, esmo], 'Conflict 2.4')).
conflict_resolution(systemic_chemo_folfox4, 'NMPA-approved; L1/Rec A', 'keep FOLFOX4 for China NMPA indication; ESMO strongly discourages (Western no OS benefit); different contexts', src([nhc, esmo], 'Conflict 2.4')).
conflict_resolution(mtor_post_transplant, 'possibly beneficial (L3/Rec C conditional)', 'ESMO Phase III RCT negative; not routine switch (I,D); caution applied', src([nhc, esmo], 'Conflict 2.4')).
conflict_resolution(tace_stop_timing, '3-4 ineffective sessions then switch', 'ESMO more aggressive: stop if 2nd TACE no clear necrosis (III,A); take more aggressive stance as reference', src([nhc, esmo], 'Conflict 2.4')).
conflict_resolution(pei_ablation, 'retained (<=2 cm / high-risk sites)', 'ESMO does not recommend (thermal superior); NHC retains PEI for high-risk sites', src([nhc, esmo], 'Conflict 2.4')).
conflict_resolution(fdg_pet_staging, 'Rec A (staging)', 'ESMO/NCCN do not recommend routine staging; NHC retains; Western limits noted', src([nhc, esmo, nccn], 'Conflict 2.4')).
conflict_resolution(ceus_diagnosis, 'recommended', 'NHC + ESMO (IV,B) support CEUS diagnosis; NCCN limits to problem-solving', src([nhc, esmo, nccn], 'Conflict 2.4')).
conflict_resolution(ctdna_monitoring, 'valuable (investigational)', 'ESMO explicitly does not recommend routine use (IV,D); NHC marks investigational', src([nhc, esmo], 'Conflict 2.4')).
conflict_resolution(tcm, 'complete system (NHC+CACA)', 'NCCN/ESMO have none; follow NHC+CACA fully', src([nhc, caca], 'Conflict 2.4')).
