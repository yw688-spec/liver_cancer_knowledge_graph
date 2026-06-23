% =====================================================================
%  treatment.pl  --  MODULE 4: TREATMENT
%  Surgery, transplant, ablation, intra-arterial (TACE/HAIC/TARE),
%  radiotherapy, systemic (1L/2L/targeted), antiviral, TCM, PVTT mgmt,
%  spontaneous rupture, patient education. Every fact ends in src/2.
% =====================================================================

:- multifile kb_fact_predicate/2.
:- discontiguous
       stage_treatment/5, surgery_prereq/2, curative_resection/3, surgery_technique/4,
       flr_strategy/6, adjuvant_therapy/4, ablation/5, tace_indication/3,
       tace_contraindication/2, tace_combo/4, haic/3, tare/3, radiotherapy/4,
       rt_dose/5, systemic_1l/5, systemic_2l/5, molecular_targeted/4,
       antiviral_rule/3, tcm_agent/5, tcm_syndrome/5, acupuncture/4,
       pvtt_management/4, rupture_management/3, patient_education/3.

kb_fact_predicate(treatment, stage_treatment/5).
kb_fact_predicate(treatment, surgery_prereq/2).
kb_fact_predicate(treatment, curative_resection/3).
kb_fact_predicate(treatment, surgery_technique/4).
kb_fact_predicate(treatment, flr_strategy/6).
kb_fact_predicate(treatment, adjuvant_therapy/4).
kb_fact_predicate(treatment, ablation/5).
kb_fact_predicate(treatment, tace_indication/3).
kb_fact_predicate(treatment, tace_contraindication/2).
kb_fact_predicate(treatment, tace_combo/4).
kb_fact_predicate(treatment, haic/3).
kb_fact_predicate(treatment, tare/3).
kb_fact_predicate(treatment, radiotherapy/4).
kb_fact_predicate(treatment, rt_dose/5).
kb_fact_predicate(treatment, systemic_1l/5).
kb_fact_predicate(treatment, systemic_2l/5).
kb_fact_predicate(treatment, molecular_targeted/4).
kb_fact_predicate(treatment, antiviral_rule/3).
kb_fact_predicate(treatment, tcm_agent/5).
kb_fact_predicate(treatment, tcm_syndrome/5).
kb_fact_predicate(treatment, acupuncture/4).
kb_fact_predicate(treatment, pvtt_management/4).
kb_fact_predicate(treatment, rupture_management/3).
kb_fact_predicate(treatment, patient_education/3).

% ---- 4.1  CNLC-staged treatment roadmap (NHC 2026 authoritative) -----
% stage_treatment(Stage, FirstChoice, Alternatives, KeyPrinciple, Src)
stage_treatment('Ia', 'resection or ablation', 'transplant (if unresectable)',
                '<=3 cm: OS similar to ablation; resection lower local recurrence', src([nhc], 'Treatment 4.1')).
stage_treatment('Ib', 'resection', 'ablation; TACE; transplant',
                'ablation for 2-3 lesions <=3 cm or insufficient function', src([nhc], 'Treatment 4.1')).
stage_treatment('IIa','resection', 'TACE; ablation',
                'standard surgery; TACE backup', src([nhc], 'Treatment 4.1')).
stage_treatment('IIb','TACE +/- systemic therapy', 'surgery (same lobe); HAIC',
                'surgery not first choice; feasible after MDT', src([nhc], 'Treatment 4.1')).
stage_treatment('IIIa','TACE/HAIC + systemic therapy', 'surgery (type I/II PVTT); radiotherapy',
                'main-trunk thrombus: direct surgery not advised', src([nhc], 'Treatment 4.1')).
stage_treatment('IIIb','systemic therapy', 'TACE/HAIC; radiotherapy',
                'isolated metastasis may receive SBRT', src([nhc], 'Treatment 4.1')).
stage_treatment('IV', 'best supportive care + TCM', 'systemic therapy (if it improves PS)',
                'quality of life is central', src([nhc], 'Treatment 4.1')).

% ---- 4.2  Surgery ----------------------------------------------------
% surgery_prereq(Condition, Src)  -- all required (none can be missing)
surgery_prereq('Child-Pugh A; ICG-R15 < 30% (mainly Asia)', src([nhc], 'Treatment 4.2')).
surgery_prereq('FLR/SLV >= 30% (no fibrosis/cirrhosis) or >= 40% (chronic liver disease/cirrhosis)', src([nhc], 'Treatment 4.2')).
surgery_prereq('ECOG PS 0-2; no significant portal hypertension (HVPG adjunct)', src([nhc], 'Treatment 4.2')).

% curative_resection(Timepoint, Criterion, Src)
curative_resection(intraoperative, 'no gross thrombus (hepatic/portal/bile/IVC); no adjacent-organ invasion; no hilar LN/distant mets; R0 margin (>=1 cm = wide)', src([nhc], 'Treatment 4.2')).
curative_resection(postoperative,  'imaging at 1-2 mo (>=2 modalities) no residual; AFP/PIVKA-II normalise within 2-3 mo', src([nhc], 'Treatment 4.2')).

% surgery_technique(Technique, KeyPoint, Level, Src)
surgery_technique(laparoscopic,   'tumour <=5 cm, peripheral segments preferred', 'L1/Rec A', src([nhc], 'Treatment 4.2')).
surgery_technique(robotic,        'fewer complications, similar OS; cost-effectiveness pending', 'L2/Rec B', src([nhc], 'Treatment 4.2')).
surgery_technique(anatomical,     'lower local recurrence in MVI+ cases', 'L2/Rec B', src([nhc], 'Treatment 4.2')).
surgery_technique(wide_margin,    'wide margin (>=1 cm) superior, esp. MVI-predicted', 'L2/Rec B', src([nhc], 'Treatment 4.2')).
surgery_technique(icg_fluorescence,'detect micro-lesions, mark resection extent', 'adjunct', src([nhc, caca], 'Treatment 4.2')).
surgery_technique(intraop_unresectable, 'intraoperative ablation, or arterial/portal catheter chemo if unresectable', 'option', src([caca], 'Treatment 4.2')).

% FLR augmentation strategies
% flr_strategy(Technique, Hypertrophy, WaitTime, Indication, Level, Src)
flr_strategy(pve,   '60-80% conversion success', '4-6 weeks', 'insufficient FLR; main/1st-order thrombus contraindicated', 'L2/Rec B', src([nhc], 'Treatment 4.2')).
flr_strategy(alpps, '47-192%; resection rate 95-100%', '1-2 weeks', 'FLR<30% (no cirrhosis) or <40% (cirrhosis); age<=70, CP A, ICG-R15<20%', 'L2/Rec A', src([nhc], 'Treatment 4.2')).
flr_strategy(y90_radiation_lobectomy, 'selective lobar irradiation', '4-8 weeks', 'alternative when FLR insufficient', 'investigational', src([nccn], 'Treatment 4.2')).

% Conversion therapy (TALENTOP RCT, L1/Rec A): Atezo+Bev success -> resection
% + sequential maintenance (12 mo) vs continued systemic: TTF 20.4 vs 11.8 mo (HR=0.60).
flr_strategy(conversion_talentop, 'Atezo+Bev conversion success', '-', 'resection + 12-mo maintenance vs continued systemic; TTF 20.4 vs 11.8 mo HR=0.60', 'L1/Rec A', src([nhc], 'Treatment 4.2')).

% Adjuvant therapy  adjuvant_therapy(Regimen, Indication, Level, Src)
adjuvant_therapy(adjuvant_tace,    'high recurrence risk (MVI+, multifocal, >5 cm, narrow margin)', 'L2/Rec B', src([nhc], 'Treatment 4.2')).
adjuvant_therapy(huaier_granule,   'post-op adjuvant; significantly prolongs RFS (multicentre RCT)', 'L1/Rec A', src([nhc, caca], 'Treatment 4.2')).
adjuvant_therapy(hbv_antiviral,    'HBsAg+ patients throughout treatment', 'L1/Rec A', src([nhc], 'Treatment 4.2')).
adjuvant_therapy(adjuvant_haic_folfox, 'MVI-HCC post-op; DFS HR=0.59 (P=0.001); cited but not routine', 'investigational', src([nccn], 'Treatment 4.2')).
adjuvant_therapy(adjuvant_atezo_bev, 'NOT recommended: IMbrave050 update shows RFS benefit not durable', 'withdrawn', src([nhc, nccn], 'Treatment 4.2')).
adjuvant_therapy(adjuvant_sorafenib, 'NOT recommended: STORM trial negative', 'not recommended', src([nccn], 'Treatment 4.2')).

% ---- 4.3  Liver transplantation (criteria are in grading.pl) ---------
% transplant management issues
adjuvant_therapy(bridging_downstaging, 'TACE/SIRT/ablation/SBRT/systemic; downstaging success -> better prognosis than non-transplant', 'L-mixed', src([nhc, caca, nccn], 'Treatment 4.3')).
adjuvant_therapy(ici_for_bridging, 'CAUTION: ICI for downstaging/bridging raises post-transplant rejection risk', 'L3/Rec C', src([nhc], 'Treatment 4.3')).
adjuvant_therapy(post_transplant_immunosuppression, 'early reduce steroids & CNI; mTOR inhibitor (sirolimus/everolimus) preferred if high recurrence risk', 'L2/Rec C', src([nhc, caca], 'Treatment 4.3')).
adjuvant_therapy(meld_exception, 'T2 tumour + AFP<=1000 ng/mL: standardised MELD exception, renew q3mo', 'policy', src([nccn], 'Treatment 4.3')).
adjuvant_therapy(post_transplant_mtor, 'sirolimus Phase III RCT negative; NOT routine switch (I,D); AFP-high+HCV subgroup may benefit', 'L3/Rec C (conditional)', src([esmo], 'Treatment 4.3')).

% ---- 4.4  Ablation ---------------------------------------------------
% ablation(Modality, Indication, Feature, Level, Src)
ablation(rfa, 'CNLC Ia & part Ib; single <=5 cm; or 2-3 <=3 cm; <=2 cm central preferred', 'OS similar to resection (<=3 cm); suits elderly/cirrhotic', 'L1/Rec A', src([nhc], 'Treatment 4.4')).
ablation(mwa, 'as RFA; better for larger or hypervascular tumours', 'high efficiency; reduces heat-sink; preferred near vessels', 'L1/Rec A', src([nhc], 'Treatment 4.4')).
ablation(cryoablation, '<=2 cm (similar to RFA)', 'watch coagulation function', 'L2/Rec B', src([nhc], 'Treatment 4.4')).
ablation(ire, 'risky locations adjacent to large vessels/bile ducts/diaphragm/GI tract', 'non-thermal; spares ductal structures; needs GA + muscle relaxation', 'L2/Rec B', src([nhc], 'Treatment 4.4')).
ablation(pei, '<=2 cm; high-risk sites (hilum/peri-gallbladder)', 'safest; high recurrence >2 cm; multiple punctures', 'L2/Rec B', src([nhc], 'Treatment 4.4')).
% Safety margin: cover >=5 mm beyond tumour. 3-5 cm: prefer resection (L1/Rec A);
% 3-7 cm unfit for surgery alone: ablation+TACE or ablation+surgery (L2/Rec B).
% Conflict: NCCN more conservative (>5 cm no ablation). [ESMO] MWA now more common than RFA.

% ---- 4.5  Trans-arterial therapies -----------------------------------
% TACE indications (9 categories)  tace_indication(Category, Condition, Src)
tace_indication(first_choice, 'CNLC IIb, IIIa', src([nhc], 'Treatment 4.5')).
tace_indication(suitable,     'CNLC IIIb (if TACE can control intrahepatic growth)', src([nhc], 'Treatment 4.5')).
tace_indication(alternative,  'CNLC Ia-IIa unable/unwilling for surgery/ablation (elderly, cirrhosis)', src([nhc], 'Treatment 4.5')).
tace_indication(massive_type, 'tumour < 70% of whole liver', src([nhc], 'Treatment 4.5')).
tace_indication(portal_ok,    'portal main trunk not completely occluded, or rich collaterals', src([nhc], 'Treatment 4.5')).
tace_indication(acute_bleed,  'tumour rupture bleeding or arterioportal shunt', src([nhc], 'Treatment 4.5')).
tace_indication(adjuvant,     'high recurrence risk (>5 cm, multifocal, vascular/bile thrombus, palliative surgery, markers not normal)', src([nhc], 'Treatment 4.5')).
tace_indication(conversion,   'initially unresectable, plan conversion/downstaging then surgery', src([nhc], 'Treatment 4.5')).
tace_indication(transplant_bridge, 'awaiting transplant > 6 months', src([nhc], 'Treatment 4.5')).

% TACE absolute contraindications  tace_contraindication(Condition, Src)
tace_contraindication('Child-Pugh C; uncorrectable coagulopathy; complete main-portal occlusion (insufficient collaterals)', src([nhc], 'Treatment 4.5')).
tace_contraindication('ECOG PS > 2; extensive metastasis (expected survival < 3 mo); multi-organ failure/cachexia', src([nhc], 'Treatment 4.5')).
tace_contraindication('renal impairment (Cr > 176.8 umol/L or CrCl < 30 mL/min); severe iodine contrast allergy', src([nhc], 'Treatment 4.5')).
tace_contraindication('bilirubin > 51 umol/L (>3 mg/dL) - relative; exception for segmental treatment', src([nhc], 'Treatment 4.5')).

% TACE combinations  tace_combo(Combo, Recommendation, Level, Src)
tace_combo(tace_systemic, 'LEAP-012: TACE+lenvatinib+pembro vs TACE+placebo: PFS reduced 34%', 'L1/Rec A', src([nhc], 'Treatment 4.5')).
tace_combo(tace_ablation, 'sequential or simultaneous; improves efficacy; less liver damage', 'L2/Rec B', src([nhc], 'Treatment 4.5')).
tace_combo(tace_ebrt,     'portal main-trunk thrombus, IVC thrombus, localised large HCC post-intervention', 'L2/Rec B', src([nhc], 'Treatment 4.5')).
tace_combo(tace_i125_stent, 'main-trunk thrombus: stent + I-125 seed strand; first-order: direct seeds', 'L3/Rec B', src([caca], 'Treatment 4.5')).
tace_combo(tace_durva_bev, 'EMERALD-1: mPFS 15.0 vs 8.2 mo (HR=0.77); not yet NCCN standard', 'investigational', src([nccn], 'Treatment 4.5')).
tace_combo(tace_then_sorafenib, 'NOT recommended: multiple RCTs show no OS benefit', 'not recommended', src([nccn, esmo], 'Treatment 4.5')).

% HAIC (China/Asia-specific standard)  haic(Element, Content, Src)
haic(core_regimen, 'mFOLFOX-HAIC: oxaliplatin + leucovorin + 5-FU (Chinese standard)', src([nhc], 'Treatment 4.5')).
haic(regimen_distinction, 'Chinese mFOLFOX effective; Japanese cisplatin/5-FU (SCOOP-2/SILIUS) negative, not recommended', src([caca, nccn], 'Treatment 4.5')).
haic(indications, 'high-burden HCC; portal thrombus (esp. main trunk); TACE-resistant; high post-op recurrence risk', src([nhc], 'Treatment 4.5')).
haic(min_cycles, 'complete >=4 HAIC cycles before assessing conversion opportunity', src([caca], 'Treatment 4.5')).
haic(combinations, 'HAIC+TACE; HAIC+systemic (targeted +/- ICI); HAIC+radiotherapy', src([nhc], 'Treatment 4.5')).

% TARE / Y-90 radioembolisation  tare(Indication, Recommendation, Src)
tare(unresectable_le8cm_bclc_a, 'single <=8 cm unresectable (BCLC A): alternative (III,B)', src([esmo], 'Treatment 4.5')).
tare(bclc_b_alt_tace,           'BCLC B intermediate: consider as TACE alternative (II,B)', src([esmo, nccn], 'Treatment 4.5')).
tare(olt_waitlist_small,        'transplant waitlist (small tumour): TARE superior to TACE (II,A)', src([esmo], 'Treatment 4.5')).
tare(segmental_pvtt,            'segmental/lobar PVTT: safe and effective', src([nccn, esmo], 'Treatment 4.5')).
tare(radiation_segmentectomy,   'Y-90 limited to <=2 segments; curative for early HCC; RASER high CR', src([nccn], 'Treatment 4.5')).
tare(dose_requirement,          'tumour dose >=205 Gy linked to OS; >400 Gy to <=25% liver (CTP A); LEGACY ORR 88.3%', src([nccn, esmo], 'Treatment 4.5')).
tare(vs_sorafenib,              'SARAH/SIRveNIB: Y-90 not superior to sorafenib in advanced HCC but less toxic', src([nccn, esmo], 'Treatment 4.5')).
tare(bilirubin_limit,           'bilirubin > 2 mg/dL increases radiation-induced liver disease risk', src([esmo], 'Treatment 4.5')).

% ---- 4.6  Radiotherapy -----------------------------------------------
% radiotherapy(Indication, Modality, Level, Src, _)
radiotherapy('Ia-part Ib, contraindication/refusal of invasive tx', 'SBRT alternative', 'L2/Rec B', src([nhc], 'Treatment 4.6')).
radiotherapy('IIa-IIb', 'TACE + external-beam RT', 'L2/Rec B', src([nhc], 'Treatment 4.6')).
radiotherapy('IIIa resectable PVTT', 'neoadjuvant or adjuvant RT', 'L2/Rec B', src([nhc], 'Treatment 4.6')).
radiotherapy('IIIa unresectable', 'palliative RT; or TACE + RT', 'L2/Rec B', src([nhc], 'Treatment 4.6')).
radiotherapy('IIIb oligometastasis (LN, lung, bone)', 'SBRT; or symptom-control RT', 'L3/Rec A', src([nhc], 'Treatment 4.6')).
radiotherapy('MVI+ post-op / narrow margin (<=1 cm)', 'adjuvant RT', 'L2/Rec B', src([nhc], 'Treatment 4.6')).
radiotherapy('pre-transplant bridging', 'SBRT for bridging', 'L2/Rec B', src([nhc, nccn], 'Treatment 4.6'), rt).

% RT dose parameters  rt_dose(Parameter, NHC, NCCN, CACA, Src)
rt_dose('SBRT dose range', '>= 30-60 Gy / 3-10 Fx; BED >= 80 Gy', '27.5-60 Gy / 3-5 Fx; BED10>72 Gy', '3-6 Fx', src([nhc], 'Treatment 4.6')).
rt_dose('conventional fractionation', '50-70 Gy', '50-66 Gy', '50-75 Gy', src([nhc], 'Treatment 4.6')).
rt_dose('PVTT neoadjuvant RT', '3 Gy x 6 Fx', '-', 'same', src([nhc], 'Treatment 4.6')).
rt_dose('normal-liver mean dose (SBRT 3-5Fx, Liver-GTV>700mL)', '< 15 Gy', 'same', 'same', src([nhc], 'Treatment 4.6')).
rt_dose('stomach/small-bowel max (SBRT)', '< 22.2-35 Gy (best <30)', 'same', 'same', src([nhc], 'Treatment 4.6')).
% Conflict: SBRT dose NHC BED>=80 Gy authoritative over NCCN BED10>72 Gy.
% [ESMO] HDR brachytherapy: early HCC (BCLC A) RT option, 1 fraction, 2-5yr LC>80% (II,B).

% ---- 4.7  Systemic therapy -------------------------------------------
% First-line preferred (immune-combination, all NMPA-approved)
% systemic_1l(Regimen, Trial, Result, Level, Src)
systemic_1l(atezolizumab_bevacizumab, 'IMbrave150', 'mOS 19.2 vs 13.4 mo; China subgroup HR=0.53; ORR 27.3% vs 11.9%', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_1l(nivolumab_ipilimumab,     'CheckMate-9DW', 'mOS 23.7 vs 20.6 mo (HR=0.79); ORR 36% vs 13%; WARN: higher early mortality, 29% high-dose steroids', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_1l(camrelizumab_apatinib,    'CARES-310', 'mOS 23.8 vs 15.2 mo (HR=0.64); 2-yr OS 49%; highest toxicity (G3-4 AE 81%)', 'L1/Rec A', src([nhc], 'Treatment 4.7')).
systemic_1l(sintilimab_bev_biosimilar,'ORIENT-32', 'mOS NR vs 10.4 mo (HR=0.57); ORR 21%', 'L1/Rec A', src([nhc], 'Treatment 4.7')).
systemic_1l(penpulimab_bevacizumab,   'SCT-C301', 'mOS 22.1 vs 14.2 mo (HR=0.60)', 'L1/Rec A', src([nhc], 'Treatment 4.7')).
systemic_1l(toripalimab_bevacizumab,  'HEPATORCH', 'mOS 20.0 vs 14.5 mo (HR=0.76)', 'L1/Rec A', src([nhc], 'Treatment 4.7')).
systemic_1l(anlotinib_penpulimab,     'APOLLO', 'PFS risk -47%; OS risk -31%', 'L1/Rec A', src([nhc], 'Treatment 4.7')).
% First-line standard (monotherapy / chemo)
systemic_1l(donafenib,   'ZGDH3', 'superior to sorafenib (death -17%); good safety', 'L1/Rec A', src([nhc], 'Treatment 4.7')).
systemic_1l(lenvatinib,  'REFLECT', 'mOS non-inferior; PFS superior to sorafenib', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_1l(tislelizumab,'RATIONALE-301', 'mOS non-inferior to sorafenib', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_1l(sorafenib,   'SHARP/Oriental', 'CP-A clearer benefit; some CP-B data', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_1l(folfox4,     'EACH', 'locally advanced/metastatic HCC unfit for surgery/local therapy (NMPA)', 'L1/Rec A', src([nhc], 'Treatment 4.7')).
systemic_1l(stride_durva_treme, 'HIMALAYA', 'HR=0.78; HBV+ subgroup HR=0.66; China pending NMPA', 'L1/Rec B (China pending)', src([nhc], 'Treatment 4.7')).
systemic_1l(durvalumab_mono,    'HIMALAYA', 'mOS 16.6 mo; non-inferior to sorafenib (HR=0.86); NCCN Cat.1; not approved in China', 'NCCN Cat.1 / ESMO I,A', src([nccn, esmo], 'Treatment 4.7')).

% Second-line systemic therapy  systemic_2l(Drug, Condition, Result, Level, Src)
systemic_2l(regorafenib,  'after sorafenib progression; tolerated sorafenib', 'death -37%; PFS -54%', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_2l(apatinib,     '>=1 prior systemic line (NMPA)', 'mOS 8.7 vs 6.8 mo; death -21.5%', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_2l(ramucirumab,  'after sorafenib and AFP >= 400 ng/mL', 'death -29%; PFS -55%', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_2l(pembrolizumab,'after sorafenib or oxaliplatin chemo (NMPA)', 'KEYNOTE-394: mOS 14.6 vs 13.0 mo', 'L1/Rec A', src([nhc, nccn], 'Treatment 4.7')).
systemic_2l(cabozantinib, 'after sorafenib progression (CTP A); FDA-approved', 'CELESTIAL: mOS 10.2 vs 8.0 mo (HR=0.76)', 'NCCN Cat.1', src([nccn], 'Treatment 4.7')).
systemic_2l(camrelizumab, 'after sorafenib/lenvatinib/oxaliplatin chemo (NMPA)', 'RATIONALE-208 data', 'L3/Rec B', src([nhc], 'Treatment 4.7')).
systemic_2l(tislelizumab_2l, 'after sorafenib/lenvatinib/oxaliplatin chemo (NMPA)', 'mOS 13.2 mo', 'L3/Rec B', src([nhc], 'Treatment 4.7')).
systemic_2l(post_ici_failure, 'no high-level evidence', 'switch to unused 1L regimen; strongly encourage clinical trial', 'L5/Rec C', src([nhc], 'Treatment 4.7')).
systemic_2l(nivolumab_mono, 'NOT recommended', 'FDA withdrew 2L HCC indication in 2021', 'not recommended', src([nhc, nccn], 'Treatment 4.7')).

% Molecular targeted (specific alterations) [NCCN]  molecular_targeted(Target, Drug, Indication, Src)
molecular_targeted(msi_h_dmmr, 'dostarlimab-gxly', 'MSI-H/dMMR advanced HCC; no satisfactory alternative; ICI-naive; NCCN Cat.2B', src([nccn], 'Treatment 4.7')).
molecular_targeted(ret_fusion, 'selpercatinib', 'RET fusion+ HCC; LIBRETTO-001 ORR 43.9%; NCCN Cat.2B', src([nccn], 'Treatment 4.7')).
molecular_targeted(ntrk_fusion,'entrectinib / larotrectinib / repotrectinib', 'NTRK1/2/3 fusion+ (<1% of HCC); response 50-75%; NCCN Useful', src([nccn], 'Treatment 4.7')).

% ---- 4.8  Antiviral therapy (absolute rule) --------------------------
% antiviral_rule(Situation, Action, Src)
antiviral_rule('HBsAg+ (standard)', 'start NAs immediately regardless of HBV-DNA: entecavir/TDF/TAF/tenofovir amibufenamide/besifovir (L1/Rec A)', src([nhc], 'Treatment 4.8')).
antiviral_rule('pre-op HBV-DNA high + ALT > 2xULN', 'antiviral + hepatoprotection first; operate after liver function improves', src([caca], 'Treatment 4.8')).
antiviral_rule('pre-op HBV-DNA high + ALT normal', 'operate promptly while starting effective antiviral therapy', src([caca], 'Treatment 4.8')).
antiviral_rule('monitoring', 'recheck HBV panel + HBV-DNA (high-sensitivity) + liver/renal function every 3-6 mo', src([nhc], 'Treatment 4.8')).
antiviral_rule('HCV-related HCC', 'HCV Ab/RNA+ -> DAAs; target SVR12 (>95% achievable) (L1/Rec A)', src([nhc], 'Treatment 4.8')).
antiviral_rule('DAA-HCC controversy', 'controversial data on DAA effect on HCC; NCCN advises physician-patient discussion; does not change SVR12 goal', src([nccn], 'Treatment 4.8')).
% Conflict N9: NHC absolute rule (start regardless of DNA) authoritative over NCCN consult-based.

% ---- 4.9  Traditional Chinese Medicine (China-specific) --------------
% tcm_agent(Agent, ApprovalStatus, Indication, Level, Src)
tcm_agent(icaritin_capsule,   'NMPA conditional', 'unresectable HCC unfit for standard tx; need >=2 of AFP>=400 + TNF-a<2.5 + IFN-g>=7.0', 'conditional', src([nhc], 'Treatment 4.9')).
tcm_agent(huaier_granule,     'NMPA', 'post-op adjuvant (prolongs RFS, multicentre RCT); advanced HCC', 'L1/Rec A (adjuvant)', src([nhc, caca], 'Treatment 4.9')).
tcm_agent(cinobufacini,       'NMPA', 'advanced HCC', 'reference', src([nhc, caca], 'Treatment 4.9')).
tcm_agent(marsdenia_prep,     'NMPA', 'advanced HCC', 'reference', src([nhc], 'Treatment 4.9')).
tcm_agent(elemene_injection,  'NMPA', 'liver cancer treatment', 'reference', src([nhc, caca], 'Treatment 4.9')).
tcm_agent(kanglaite_injection,'NMPA', 'liver cancer treatment', 'reference', src([nhc, caca], 'Treatment 4.9')).
tcm_agent(kangai_injection,   'NMPA', 'supportive care in advanced tumours', 'reference', src([nhc], 'Treatment 4.9')).
tcm_agent(ganfule_capsule,    'NMPA', 'advanced HCC', 'reference', src([nhc, caca], 'Treatment 4.9')).
tcm_agent(jinlong_capsule,    'NMPA', 'liver cancer treatment', 'reference', src([nhc], 'Treatment 4.9')).
tcm_agent(cidan_capsule,      'NMPA', 'advanced HCC', 'reference', src([nhc], 'Treatment 4.9')).
tcm_agent(aidi_injection,     'NMPA', 'mid-advanced HCC; combined with TACE', 'reference', src([caca], 'Treatment 4.9')).
tcm_agent(brucea_oil,         'NMPA', 'adjunct combined with TACE', 'reference', src([caca], 'Treatment 4.9')).

% TCM syndrome differentiation  tcm_syndrome(Stage, Syndrome, FormulaNHC, FormulaCACA, Src)
tcm_syndrome('Ia-Ib perioperative', 'liver-qi stagnation', 'Chaihu Shugan San modified', 'Qingfu Jindan modified [CACA]', src([nhc, caca], 'Treatment 4.9')).
tcm_syndrome('Ia-Ib perioperative', 'qi stagnation & blood stasis', 'Gexia Zhuyu Tang modified', 'Yigan Qingzheng Tang modified [CACA]', src([nhc, caca], 'Treatment 4.9')).
tcm_syndrome('IIa-IIIb mid-advanced', 'liver-depression spleen-deficiency', 'Xiaoyao San modified', 'similar to NHC', src([nhc, caca], 'Treatment 4.9')).
tcm_syndrome('IIa-IIIb mid-advanced', 'damp-heat toxin accumulation', 'Yinchenhao Tang + Wuling San', 'Yinchenhao Tang + Longdan Xiegan Tang [CACA]', src([nhc, caca], 'Treatment 4.9')).
tcm_syndrome('IV terminal', 'liver-kidney deficiency + qi-yin depletion', 'Yiguan Jian modified', 'same', src([nhc, caca], 'Treatment 4.9')).

% Acupuncture [CACA]  acupuncture(Use, MainPoints, AuxPoints, Src)
acupuncture(basic_regulation, 'BL-18 (Ganshu) + ST-36 (Zusanli)', 'GB-34, LR-14, LR-13, SP-6', src([caca], 'Treatment 4.9')).
acupuncture(pain_management,  'LR-13 (Zhangmen) + LR-14 (Qimen)', 'SJ-5, ST-36, GB-34', src([caca], 'Treatment 4.9')).
acupuncture(ascites_management,'CV-6 (Qihai) + SP-6 (Sanyinjiao)', 'SP-9', src([caca], 'Treatment 4.9')).

% ---- 4.10  PVTT management (typing in grading.pl) --------------------
% pvtt_management(Type, Strategy, Level, Src)
pvtt_management('I',   'consider resection + thrombectomy after MDT; post-op TACE/systemic', 'L2/Rec B', src([nhc], 'Treatment 4.10')).
pvtt_management('II',  'as type I', 'L2/Rec B', src([nhc], 'Treatment 4.10')).
pvtt_management('III', 'direct surgery NOT advised; TACE/HAIC + systemic therapy', 'L3/Rec B', src([nhc], 'Treatment 4.10')).
pvtt_management('IV',  'systemic therapy primary; TACE/HAIC when technically feasible', 'L3/Rec C', src([nhc], 'Treatment 4.10')).
% Conflict N4: NHC active surgery for type I/II authoritative over NCCN conservative stance.

% ---- 4.11  Spontaneous rupture  rupture_management(Phase, Principle, Src)
rupture_management(emergency_haemostasis, 'haemodynamically unstable -> TAE first choice; stable -> emergency resection possible', src([nhc], 'Treatment 4.11')).
rupture_management(after_stabilisation,   'after haemostasis & recovery, complete staging and plan curative treatment', src([nhc], 'Treatment 4.11')).
rupture_management(prognosis_note,        'spontaneous rupture is high-risk; increased peritoneal seeding/metastasis risk', src([nhc], 'Treatment 4.11')).

% ---- 4.12  Patient & family education [CACA] -------------------------
% patient_education(Topic, KeyMessage, Src)
patient_education(infectivity, 'HCC itself is not infectious; but >90% HBV-related; family should test HBV markers, vaccinate if uninfected, treat if infected', src([caca], 'Treatment 4.12')).
patient_education(heredity, 'HCC is not hereditary; 1st-degree relatives ~10x risk but absolute probability still <0.1%; family US+AFP every 6 mo', src([caca], 'Treatment 4.12')).
patient_education(work_activity, 'may resume work when stable post-curative; avoid late nights/heavy labour; moderate exercise (walking/taichi/qigong); intense activity may trigger rupture if active lesions', src([caca], 'Treatment 4.12')).
patient_education(diet, 'no tobacco/alcohol; light digestible diet; avoid high-protein/high-fat if cirrhosis; avoid spicy/coarse/pickled/fried; no over-restriction or over-supplementation', src([caca], 'Treatment 4.12')).
