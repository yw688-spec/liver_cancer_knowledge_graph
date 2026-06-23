% =====================================================================
%  diagnosis.pl  --  MODULE 3: DIAGNOSIS
%  Screening, imaging, serum/liquid markers, portal-HTN assessment,
%  clinical diagnostic pathways, biopsy indications, pathology,
%  response criteria, follow-up. Every fact ends in src/2.
% =====================================================================

:- multifile kb_fact_predicate/2.
:- discontiguous
       screening/5, imaging_modality/4, serum_marker/4, porthtn_assessment/3,
       diagnostic_pathway/5, imaging_hallmark/3, biopsy_indication/3,
       ihc_marker/3, sampling_method/2, path_response/4, response_criterion/3,
       followup/4, recurrence_site/4.

kb_fact_predicate(diagnosis, screening/5).
kb_fact_predicate(diagnosis, imaging_modality/4).
kb_fact_predicate(diagnosis, serum_marker/4).
kb_fact_predicate(diagnosis, porthtn_assessment/3).
kb_fact_predicate(diagnosis, diagnostic_pathway/5).
kb_fact_predicate(diagnosis, imaging_hallmark/3).
kb_fact_predicate(diagnosis, biopsy_indication/3).
kb_fact_predicate(diagnosis, ihc_marker/3).
kb_fact_predicate(diagnosis, sampling_method/1).
kb_fact_predicate(diagnosis, path_response/4).
kb_fact_predicate(diagnosis, response_criterion/3).
kb_fact_predicate(diagnosis, followup/4).
kb_fact_predicate(diagnosis, recurrence_site/4).

% ---- 3.1  Screening populations & intervals --------------------------
% screening(Population, Condition, Tests, Interval, Src)
screening(moderate_high_risk, 'aMAP 50-100; or HBV/HCV; or cirrhosis of any cause; or male >40 yr',
          'ultrasound + AFP + PIVKA-II', 'every 6 months (L1/Rec A)', src([nhc], 'Diagnosis 3.1')).
screening(very_high_risk, 'aMAP-2 Plus very-high score',
          'contrast MRI (or aMRI) + AFP + PIVKA-II (+/- cfDNA)', 'every 6-12 months', src([nhc], 'Diagnosis 3.1')).
screening(hbcab_only, 'HBsAg-negative but HBcAb-positive',
          'ultrasound + AFP', 'every 6 months', src([nhc], 'Diagnosis 3.1')).
screening(post_curative_within2y, 'after resection/ablation/transplant',
          '>=2 imaging modalities + AFP + PIVKA-II + 7-miRNA', 'every 3 months', src([nhc, caca], 'Diagnosis 3.1')).
screening(post_curative_beyond2y, 'beyond 2 years post-curative',
          'imaging + AFP', 'every 3-6 months', src([nhc, caca], 'Diagnosis 3.1')).
% [ESMO] surveillance: abdominal US (or multiphase CT/MRI) every 6 mo, with or without AFP.
screening(esmo_general, 'cirrhosis surveillance (ESMO)',
          'abdominal ultrasound (or multiphase CT/MRI), with or without AFP', 'every 6 months', src([esmo], 'Diagnosis 3.1')).

% ---- 3.2  Imaging modalities -----------------------------------------
% imaging_modality(Modality, Role, Level, Src)
imaging_modality(ultrasound,        'initial screening; surveillance', 'routine', src([nhc], 'Diagnosis 3.2')).
imaging_modality(ceus,              'differential dx; ablation guidance & immediate assessment (NCCN limits for whole-liver screen/staging)', 'L2/Rec A', src([nhc], 'Diagnosis 3.2')).
imaging_modality(dynamic_ct,        'diagnosis, staging, response; TACE lipiodol assessment', 'L1/Rec A', src([nhc], 'Diagnosis 3.2')).
imaging_modality(dynamic_mri_ecf,   'preferred imaging; <=2 cm diagnosis superior to CT', 'L1/Rec A', src([nhc], 'Diagnosis 3.2')).
imaging_modality(gd_eob_dtpa_mri,   'subcentimetre HCC; poor liver function; premalignant differentiation', 'L2/Rec B', src([nhc], 'Diagnosis 3.2')).
imaging_modality(dsa_cbct,          'mandatory before TACE; 3D vascular anatomy', 'L2/Rec A', src([nhc], 'Diagnosis 3.2')).
imaging_modality(pet_ct_fdg,        'whole-body staging; restaging; high FDG suggests aggressiveness', 'L1/Rec A (staging)', src([nhc, nccn], 'Diagnosis 3.2')).
imaging_modality(pet_ct_acetate,    'supplement for well-differentiated HCC', 'L2/Rec B', src([nhc], 'Diagnosis 3.2')).
imaging_modality(y90_spect_ct,      'pre-radioembolisation dosimetry & response assessment', 'reference', src([nccn], 'Diagnosis 3.2')).
% Conflict: NCCN does NOT recommend CEUS for whole-liver eval/surveillance/staging
% (only problem-solving for indeterminate nodules). FDG-PET routine staging: ESMO/NCCN not recommended. NHC authoritative.

% ---- 3.3  Serum / liquid markers -------------------------------------
% serum_marker(Marker, PositiveThreshold, Role, Src)
serum_marker(afp,        '>= 400 ng/mL (after excluding other causes); CACA: >=200 ng/mL x2 mo or >400 x1 mo -> clinical dx',
             'screening, diagnosis, monitoring, recurrence prediction', src([nhc, caca], 'Diagnosis 3.3')).
serum_marker(pivka_ii,   'above normal', 'early dx of AFP-negative HCC; complements AFP', src([nhc], 'Diagnosis 3.3')).
serum_marker(afp_l3,     'elevated', 'differential dx (usually not raised in benign liver disease)', src([nhc], 'Diagnosis 3.3')).
serum_marker(galad,      'composite model', 'early HCC: sensitivity 85.6%, specificity 93.3% (L1/Rec A)', src([nhc, nccn], 'Diagnosis 3.3')).
serum_marker(gaad_asap,  'composite model', 'diagnostic performance similar to GALAD (L1/Rec A)', src([nhc], 'Diagnosis 3.3')).
serum_marker(mirna_7,    'NMPA Class-III device', 'sensitivity 86.1%, specificity 76.8%; AFP-neg HCC sens 77.7%', src([nhc, caca], 'Diagnosis 3.3')).
serum_marker(cfdna_ctdna,'-', 'early dx superior to AFP; tracks treatment response', src([nhc], 'Diagnosis 3.3')).
serum_marker(epcam_ctc,  '-', 'independent predictor of early post-op recurrence; post TACE/RT recurrence', src([nhc, caca], 'Diagnosis 3.3')).
serum_marker(amap2_cfdna,'-', 'identifies very-high-risk (annual incidence up to 12.5%)', src([nhc], 'Diagnosis 3.3')).
serum_marker(msi_mmr,    'tissue/liquid biopsy', 'no routine indication; only atypical histology/trial/cHCC-CCA (MGPT)', src([nccn], 'Diagnosis 3.3')).

% ---- 3.3A  Portal hypertension assessment (Baveno VII) [ESMO] --------
% porthtn_assessment(Mode, Criterion, Src)
porthtn_assessment(indirect, 'varices and/or splenomegaly and/or platelets < 100 x10^9/L', src([esmo], 'Diagnosis 3.3A')).
porthtn_assessment(invasive, 'HVPG > 10 mmHg (transjugular)', src([esmo], 'Diagnosis 3.3A')).

% ---- 3.4  Clinical diagnostic pathways (NHC Fig.3, authoritative) ----
% diagnostic_pathway(Id, Trigger, DxCriterion, NegativeHandling, Src)
diagnostic_pathway(path1, 'liver nodule <= 1 cm',
                   'dynamic-enhanced MRI AND Gd-EOB-DTPA MRI both show hallmark -> clinical dx',
                   'imaging follow-up q2-3 mo + AFP/PIVKA-II/7-miRNA; biopsy if needed', src([nhc], 'Diagnosis 3.4')).
diagnostic_pathway(path2, 'liver nodule 1-2 cm',
                   '>=2 of 4 (dynamic MRI/CT/CEUS/EOB-MRI) show hallmark -> clinical dx',
                   '0-1 positive: follow-up q2-3 mo + markers; biopsy if needed', src([nhc], 'Diagnosis 3.4')).
diagnostic_pathway(path3, 'liver nodule > 2 cm',
                   '>=1 of 4 shows hallmark -> clinical dx',
                   '0 positive: follow-up q2-3 mo + markers; biopsy if needed', src([nhc], 'Diagnosis 3.4')).
diagnostic_pathway(path4, 'AFP/PIVKA-II persistently rising',
                   '>=1 of 4 hallmark -> clinical dx',
                   'no hallmark: exclude pregnancy/active liver disease/GCT/GI tumour, recheck q2-3 mo', src([nhc], 'Diagnosis 3.4')).
% Conflict N2: NCCN uses LI-RADS (LR-5 >=10 mm); NHC 4-pathway roadmap authoritative.

% ---- Imaging hallmark "wash-in / wash-out" ---------------------------
% imaging_hallmark(Id, Definition, Src)
imaging_hallmark(wash_in,  'arterial-phase non-rim hyperenhancement', src([nhc], 'Diagnosis 3.4')).
imaging_hallmark(wash_out, 'non-peripheral washout in portal-venous and/or delayed phase (below parenchyma)', src([nhc], 'Diagnosis 3.4')).
imaging_hallmark(schcc,    'subcentimetre HCC (<= 1 cm): recommend Gd-EOB-DTPA MRI; local resection 5-yr OS 97.3%', src([nhc], 'Diagnosis 3.4')).

% ---- 3.5  Biopsy indications -----------------------------------------
% biopsy_indication(Situation, Recommendation, Src)
biopsy_indication('typical imaging meets dx criteria', 'biopsy usually not needed (L1/Rec A)', src([nhc], 'Diagnosis 3.5')).
biopsy_indication('surgical or transplant candidate', 'pre-op biopsy not advised (bleeding/seeding); if transplant considered refer to centre first', src([nhc, nccn], 'Diagnosis 3.5')).
biopsy_indication('lacking typical features', 'biopsy needed to confirm pathology', src([nhc], 'Diagnosis 3.5')).
biopsy_indication('before conversion/neoadjuvant therapy', 'biopsy feasible (microenvironment/necrosis/inflammation)', src([nhc], 'Diagnosis 3.5')).
biopsy_indication('negative biopsy but high suspicion', 'repeat biopsy or close follow-up', src([nhc], 'Diagnosis 3.5')).
biopsy_indication('nodule <= 2 cm', 'high false-negative rate; negative biopsy does NOT exclude HCC', src([nhc], 'Diagnosis 3.5')).
biopsy_indication('non-high-risk patient (no cirrhosis/CHB/prior HCC)', 'imaging criteria not applicable; biopsy to confirm', src([nccn], 'Diagnosis 3.5')).
biopsy_indication('advanced/metastatic HCC before systemic therapy', 'biopsy preferred; ~7% of radiologic HCC prove to be CCA/cHCC-CCA', src([nccn, esmo], 'Diagnosis 3.5')).
biopsy_indication('mixed histologic features', 'perform NGS (IV,A); guides molecular 2nd-line after 1L progression', src([esmo], 'Diagnosis 3.5')).

% ---- 3.6  Pathology --------------------------------------------------
% "7-point" baseline sampling
sampling_method('7-point baseline sampling: 12/3/6/9 o''clock tumour-peritumour junction (1:1); >=1 block intratumoural; 1 block near (<=1 cm) + 1 block distal (>1 cm); small HCC <=3 cm sampled entirely').
kb_fact_predicate(diagnosis, sampling_src/1).
sampling_src(src([nhc], 'Diagnosis 3.6')).

% IHC markers  ihc_marker(Use, Markers, Src)
ihc_marker('hepatocyte origin (positive)', 'Arg-1, HepPar-1, CD10, pCEA, BSEP', src([nhc], 'Diagnosis 3.6')).
ihc_marker('benign vs malignant HCC', 'GS (diffuse strong), GPC-3 (NMPA Class-III), HSP70', src([nhc], 'Diagnosis 3.6')).
ihc_marker('microvessel density/pattern', 'CD34 (HCC diffuse; adenoma patchy; FNH cords)', src([nhc], 'Diagnosis 3.6')).
ihc_marker('ICC targetable (large duct)', 'HER2, BRAF, KRAS, NTRK, RET, MSI, TMB', src([nhc], 'Diagnosis 3.6')).
ihc_marker('ICC targetable (small duct)', 'FGFR2 rearrangement, IDH1', src([nhc], 'Diagnosis 3.6')).
ihc_marker('FLHCC molecular dx', 'DNAJB1::PRKACA fusion (79-100% accuracy)', src([nccn], 'Diagnosis 3.6')).
% TLS: mature TLS count correlates positively with HCC prognosis; intratumoural > peritumoural.
ihc_marker('TLS (tertiary lymphoid structures)', 'mature TLS count positively prognostic; intratumoural > peritumoural', src([nhc, caca], 'Diagnosis 3.6')).

% Neoadjuvant/conversion pathology response  path_response(Id, Definition, Threshold, Src)
path_response(cpr, 'complete pathologic response: no viable tumour in tumour bed', '-', src([nhc], 'Diagnosis 3.6')).
path_response(mpr, 'major pathologic response: viable tumour below prognostic threshold', '<= 10% (varies; report %)', src([nhc], 'Diagnosis 3.6')).

% ---- 3.7  Response-evaluation criteria -------------------------------
% response_criterion(Id, Applicability, Src)
response_criterion('RECIST 1.1', 'general standard for trials & practice (all systemic therapy)', src([nhc, nccn], 'Diagnosis 3.7')).
response_criterion('mRECIST',    'antiangiogenic targeted therapy; ablation/TACE; radiotherapy response', src([nhc, nccn], 'Diagnosis 3.7')).
response_criterion('iRECIST',    'ICI therapy (handles pseudoprogression: iUPD -> iCPD)', src([nhc], 'Diagnosis 3.7')).
response_criterion('LI-RADS TRA v2024', 'internal/external radiotherapy response; combine T2WI & DWI', src([nhc], 'Diagnosis 3.7')).

% ---- 3.8  Follow-up schedule -----------------------------------------
% followup(Phase, Interval, Items, Src)
followup('post-curative within 2 yr',  'every 2-3 months', 'contrast CT/MRI (alternate with US) + AFP + PIVKA-II + liver/renal function', src([nhc, caca], 'Diagnosis 3.8')).
followup('post-curative 3-5 yr',       'every 4-5 months', 'contrast CT/MRI + AFP', src([caca], 'Diagnosis 3.8')).
followup('post-curative > 5 yr',       'every 6 months',   'contrast CT/MRI + AFP', src([nhc, caca], 'Diagnosis 3.8')).
followup('palliative active phase',    'every 4-6 weeks',  'contrast CT/MRI + markers + liver/renal function + AE monitoring', src([caca], 'Diagnosis 3.8')).
followup('palliative stable phase',    'every 2-3 months', 'contrast CT/MRI + markers', src([caca], 'Diagnosis 3.8')).
followup('systemic therapy first 6 mo','every 6-8 weeks',  'imaging + markers', src([nhc], 'Diagnosis 3.8')).
followup('systemic therapy after 6 mo','every 9-12 weeks', 'imaging + markers', src([nhc], 'Diagnosis 3.8')).
followup('minimum duration (NCCN)',    'at least 5 years', 'thereafter per HCC risk factors', src([nccn], 'Diagnosis 3.8')).
followup('post-curative (ESMO)',       'q3mo x2yr then q6mo x5yr', 'CEMRI or CECT; assess hepatic decompensation', src([esmo], 'Diagnosis 3.8')).

% ---- Common recurrence/metastasis sites [CACA] -----------------------
% recurrence_site(Site, Frequency, Strategy, Src)
recurrence_site(intrahepatic, 'most common', 'abdominal imaging primary', src([caca], 'Diagnosis 3.8')).
recurrence_site(lung,         'second',      'chest X-ray/CT every 6-12 months', src([caca], 'Diagnosis 3.8')).
recurrence_site(adrenal,      'third',       'covered by abdominal imaging', src([caca], 'Diagnosis 3.8')).
recurrence_site(bone,         'less common', 'bone scan only for bone pain or unexplained AFP rise', src([caca], 'Diagnosis 3.8')).
recurrence_site(lymph_node,   'regional/distant', 'CT/MRI sufficient', src([caca], 'Diagnosis 3.8')).
