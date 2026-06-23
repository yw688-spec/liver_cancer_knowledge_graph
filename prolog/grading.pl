% =====================================================================
%  grading.pl  --  MODULE: GRADING & STAGING
%  Differentiation, MVI, performance status, liver function, surgical
%  thresholds, CNLC staging + cross-system mapping, risk stratification,
%  transplant criteria (as classification), PVTT (Cheng) typing.
%  Every fact ends in src/2.
% =====================================================================

:- multifile kb_fact_predicate/2.
:- discontiguous
       differentiation_grade/4, mvi_grade/4, ecog_ps/3, child_pugh/4,
       albi_grade/3, surgical_lft_threshold/4, cnlc_stage/3,
       stage_mapping/4, risk_model/5, transplant_criterion/4,
       pvtt_type/4.

kb_fact_predicate(grading, differentiation_grade/4).
kb_fact_predicate(grading, mvi_grade/4).
kb_fact_predicate(grading, ecog_ps/3).
kb_fact_predicate(grading, child_pugh/4).
kb_fact_predicate(grading, albi_grade/3).
kb_fact_predicate(grading, surgical_lft_threshold/4).
kb_fact_predicate(grading, cnlc_stage/3).
kb_fact_predicate(grading, stage_mapping/4).
kb_fact_predicate(grading, risk_model/5).
kb_fact_predicate(grading, transplant_criterion/4).
kb_fact_predicate(grading, pvtt_type/4).

% ---- 1.4  Differentiation grade --------------------------------------
% differentiation_grade(Tumour, System, Grades, Src)
differentiation_grade(hcc, 'Edmondson-Steiner', 'I-IV (WHO: well/moderate/poor); report main + worst component', src([nhc], 'Grading 1.4')).
differentiation_grade(icc, 'WHO',               'well / moderate / poor', src([nhc], 'Grading 1.4')).

% ---- 1.5  MVI grade (microvascular invasion), 7-point sampling -------
% mvi_grade(Grade, Criterion, Risk, Src)
mvi_grade(m0,  'no MVI found', none, src([nhc], 'Grading 1.5')).
mvi_grade(m1,  '<= 5 MVI, all in peritumoural liver (<= 1 cm)', low, src([nhc], 'Grading 1.5')).
mvi_grade(m2a, '> 5 MVI, all in peritumoural liver (<= 1 cm)', high, src([nhc], 'Grading 1.5')).
mvi_grade(m2b, 'MVI in distal liver tissue (> 1 cm)', high, src([nhc], 'Grading 1.5')).
% Conflict C2: CACA uses 3-tier M0/M1/M2 (no M2a/M2b split); NCCN has no
% standardised MVI grading. NHC 4-tier is authoritative. (see evidence.pl)

% ---- 1.8  ECOG performance status ------------------------------------
% ecog_ps(Score, Description, Src)
ecog_ps(0, 'fully active, no restriction', src([nhc], 'Grading 1.8')).
ecog_ps(1, 'restricted in strenuous activity, ambulatory, light work', src([nhc], 'Grading 1.8')).
ecog_ps(2, 'ambulatory, self-care, no work; up >50% of waking hours', src([nhc], 'Grading 1.8')).
ecog_ps(3, 'limited self-care; confined to bed/chair >50% of waking hours', src([nhc], 'Grading 1.8')).
ecog_ps(4, 'completely disabled; no self-care', src([nhc], 'Grading 1.8')).

% ---- 1.9  Liver function: Child-Pugh ---------------------------------
% child_pugh(Class, ScoreRange, ClinicalState, Src)
child_pugh('A', '5-6',   'well compensated; suitable for most treatments', src([nhc], 'Grading 1.9')).
child_pugh('B', '7-9',   'functional impairment; selective treatment', src([nhc], 'Grading 1.9')).
child_pugh('C', '10-15', 'decompensated; very limited treatment options', src([nhc], 'Grading 1.9')).

% ALBI grade  albi_grade(Grade, CutoffAndMeaning, Src)
albi_grade(1, '<= -2.60 : excellent liver function', src([nhc], 'Grading 1.9')).
albi_grade(2, '-2.60 to -1.39 : moderate liver function', src([nhc], 'Grading 1.9')).
albi_grade(3, '> -1.39 : poor liver function', src([nhc], 'Grading 1.9')).

% Surgical liver-function thresholds
% surgical_lft_threshold(Metric, SafeThreshold, Use, Src)
surgical_lft_threshold(icg_r15,        '< 30%', 'surgical-safety prerequisite (mainly Asia)', src([nhc], 'Grading 1.9')).
surgical_lft_threshold(flr_slv_normal, '>= 30%', 'minimum for resection (normal liver)', src([nhc], 'Grading 1.9')).
surgical_lft_threshold(flr_slv_chronic,'>= 40%', 'higher threshold (chronic liver disease/cirrhosis)', src([nhc], 'Grading 1.9')).
surgical_lft_threshold(flr_nccn_noncirrhotic, '>= 20%', 'NCCN standard (West does not use ICG-R15)', src([nccn], 'Grading 1.9')).
% Conflict: FLR (non-cirrhotic) NHC >=30% vs NCCN >=20%; NHC authoritative.

% ---- CNLC staging (NHC primary staging system) -----------------------
% cnlc_stage(Stage, Description, Src)
cnlc_stage('Ia',  'single tumour <= 5 cm; PS 0-2; Child-Pugh A/B; no vascular invasion/extrahepatic spread', src([nhc], 'Grading CNLC')).
cnlc_stage('Ib',  'single >5 cm, or 2-3 tumours each <= 3 cm; PS 0-2; CP A/B; no invasion/spread', src([nhc], 'Grading CNLC')).
cnlc_stage('IIa', '2-3 tumours, at least one > 3 cm; PS 0-2; CP A/B; no invasion/spread', src([nhc], 'Grading CNLC')).
cnlc_stage('IIb', '>= 4 tumours of any size; PS 0-2; CP A/B; no invasion/spread', src([nhc], 'Grading CNLC')).
cnlc_stage('IIIa','any tumour with portal/hepatic/IVC tumour thrombus (PVTT); PS 0-2; CP A/B', src([nhc], 'Grading CNLC')).
cnlc_stage('IIIb','any tumour with extrahepatic/lymph-node metastasis; PS 0-2; CP A/B', src([nhc], 'Grading CNLC')).
cnlc_stage('IV',  'PS 3-4, or Child-Pugh C', src([nhc], 'Grading CNLC')).

% Cross-system stage mapping (CNLC is primary; BCLC/NCCN for reference).
% stage_mapping(CNLC, BCLC, Note, Src)
stage_mapping('Ia',  '0',     'very early', src([nhc, caca], 'Conflict 2.4 staging')).
stage_mapping('Ib',  'A',     'early', src([nhc, caca], 'Conflict 2.4 staging')).
stage_mapping('IIa', 'A/B',   'early/intermediate', src([nhc, caca], 'Conflict 2.4 staging')).
stage_mapping('IIb', 'B',     'intermediate', src([nhc, caca], 'Conflict 2.4 staging')).
stage_mapping('IIIa','C',     'advanced (macrovascular invasion)', src([nhc, caca], 'Conflict 2.4 staging')).
stage_mapping('IIIb','C',     'advanced (extrahepatic spread)', src([nhc, caca], 'Conflict 2.4 staging')).
stage_mapping('IV',  'D',     'terminal', src([nhc, caca], 'Conflict 2.4 staging')).
% Note: NHC CNLC is authoritative; BCLC for reference only; NCCN 3-class as mapping aid.

% ---- 1.7  Risk-stratification models (aMAP system) -------------------
% risk_model(Id, Band, ScoreRange, AnnualIncidence, Src)
risk_model(amap, low,        '0-50',   '0-0.2%',  src([nhc], 'Grading 1.7')).
risk_model(amap, moderate,   '50-60',  '0.4-1.0%',src([nhc], 'Grading 1.7')).
risk_model(amap, high,       '60-100', '1.6-4.0%',src([nhc], 'Grading 1.7')).
risk_model(amap2_plus, very_high, 'model-specific', 'up to 12.5%', src([nhc], 'Grading 1.7')).
risk_model(alarm, early_warning, 'model-specific', '~95% events predicted 3-12 mo ahead', src([nhc], 'Grading 1.7')).
% ESMO supplement
risk_model(page_b, hbv_risk_stratification, 'age/sex/platelets', 'for ETV/TDF-treated CHB; monitor moderate/high', src([esmo], 'Grading 1.6B')).

% ---- Transplant criteria (classification of eligibility) -------------
% transplant_criterion(Name, TumourCondition, AuthorityStatus, Src)
transplant_criterion(ucsf,  'single <= 6.5 cm; or <= 3 tumours, max <= 4.5 cm, total <= 8.0 cm; no macrovascular invasion',
                     'NHC 2026 explicitly recommended', src([nhc], 'Treatment 4.3')).
transplant_criterion(milan, 'single <= 5 cm; or <= 3 tumours each <= 3 cm; no vascular invasion/extrahepatic spread',
                     'international minimum reference (ESMO European standard)', src([nhc, esmo], 'Treatment 4.3')).
transplant_criterion(hz_wx_sanya, 'various expanded criteria (total diameter / AFP combinations)',
                     'exploratory; awaiting multicentre high-level evidence', src([nhc], 'Treatment 4.3')).
transplant_criterion(unos, 'AFP <= 1000 ng/mL + single 2-5 cm, or 2-3 tumours 1-3 cm; no macrovascular invasion',
                     'US UNOS organ-allocation policy (reference only)', src([nccn], 'Treatment 4.3')).

% ---- 4.10  PVTT (Cheng) typing  --------------------------------------
% pvtt_type(Type, Definition, RiskNote, Src)  -- management in treatment.pl
pvtt_type('I',   'invasion of segmental/lobar portal branches', 'resection considerable after MDT', src([nhc], 'Grading 4.10')).
pvtt_type('II',  'invasion of left or right portal branch (first-order)', 'as type I', src([nhc], 'Grading 4.10')).
pvtt_type('III', 'invasion of the main portal trunk', 'direct surgery NOT advised', src([nhc], 'Grading 4.10')).
pvtt_type('IV',  'invasion of the superior mesenteric vein', 'systemic therapy primary', src([nhc], 'Grading 4.10')).
