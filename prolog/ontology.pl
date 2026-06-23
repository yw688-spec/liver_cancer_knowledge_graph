% =====================================================================
%  ontology.pl  --  MODULE 1: ONTOLOGY
%  Concept system & classification (grading/staging live in grading.pl).
%  Source: v4 "Module 1 - Ontology". Every fact ends in src/2.
% =====================================================================

:- multifile kb_fact_predicate/2.
:- discontiguous
       cancer_type/4, default_cancer_type/1, gross_type/4,
       histo_architecture/3, hcc_subtype/4, icc_subtype/4,
       risk_factor/4, etiology_synergy/3, molecular_subtype_cn/3,
       genetic_susceptibility/4.

kb_fact_predicate(ontology, cancer_type/4).
kb_fact_predicate(ontology, gross_type/4).
kb_fact_predicate(ontology, histo_architecture/3).
kb_fact_predicate(ontology, hcc_subtype/4).
kb_fact_predicate(ontology, icc_subtype/4).
kb_fact_predicate(ontology, risk_factor/4).
kb_fact_predicate(ontology, etiology_synergy/3).
kb_fact_predicate(ontology, molecular_subtype_cn/3).
kb_fact_predicate(ontology, genetic_susceptibility/4).

% ---- 1.1  Cancer types -----------------------------------------------
% cancer_type(Id, FullName, ChinaProportion, Src)
cancer_type(hcc,      'Hepatocellular Carcinoma',        '80%',   src([nhc], 'Ontology 1.1')).
cancer_type(icc,      'Intrahepatic Cholangiocarcinoma', '14.9%', src([nhc], 'Ontology 1.1')).
cancer_type(chcc_cca, 'Combined HCC-CCA',                '~5%',   src([nhc], 'Ontology 1.1')).

% Database default: all rules apply to HCC unless ICC/cHCC-CCA stated.
default_cancer_type(hcc).

% ---- 1.2  Gross morphology (Appendix 6, China Pathology Group) -------
% gross_type(Id, Label, Criterion, Src)
gross_type(diffuse,       'Diffuse type',        'diffuse small nodules throughout the whole liver', src([nhc], 'Ontology 1.2')).
gross_type(massive,       'Massive type',        'single/multiple tumours, largest diameter >= 10 cm', src([nhc], 'Ontology 1.2')).
gross_type(large_nodular, 'Large nodular type',  'single/multiple tumours, largest diameter 5-10 cm', src([nhc], 'Ontology 1.2')).
gross_type(nodular,       'Nodular type',        'single/multiple tumours, largest diameter <= 5 cm', src([nhc], 'Ontology 1.2')).
gross_type(small_hcc,     'Small HCC',           'single nodular HCC <= 3 cm (key node of biological evolution)', src([nhc], 'Ontology 1.2')).

% ---- 1.3  Histologic types -------------------------------------------
% Common HCC architectural patterns
histo_architecture(thin_trabecular,  'Thin trabecular',  src([nhc], 'Ontology 1.3')).
histo_architecture(thick_trabecular, 'Thick trabecular', src([nhc], 'Ontology 1.3')).
histo_architecture(pseudoglandular,  'Pseudoglandular',  src([nhc], 'Ontology 1.3')).
histo_architecture(compact,          'Compact/solid',    src([nhc], 'Ontology 1.3')).

% HCC special subtypes  hcc_subtype(Id, Name, MarkerOrSignificance, Src)
hcc_subtype(fibrolamellar,   'Fibrolamellar',   'DNAJB1-PRKACA gene fusion; young patients; no cirrhosis', src([nhc], 'Ontology 1.3')).
hcc_subtype(scirrhous,       'Scirrhous',       'TSC1/2 mutation', src([nhc], 'Ontology 1.3')).
hcc_subtype(macrotrabecular, 'Macrotrabecular', 'TP53 mutation + FGF19 amplification; aggressive', src([nhc], 'Ontology 1.3')).
hcc_subtype(biphenotypic,    'Biphenotypic',    'co-expresses HCC + cholangio markers; aggressive; may respond to regorafenib', src([nhc], 'Ontology 1.3')).
hcc_subtype(clear_cell,      'Clear cell',      'no specific marker', src([nhc], 'Ontology 1.3')).
hcc_subtype(steatohepatitic, 'Steatohepatitic', 'no specific marker', src([nhc], 'Ontology 1.3')).
hcc_subtype(chromophobe,     'Chromophobe',     'no specific marker', src([nhc], 'Ontology 1.3')).
hcc_subtype(neutrophil_rich, 'Neutrophil-rich', 'no specific marker', src([nhc], 'Ontology 1.3')).
hcc_subtype(lymphocyte_rich, 'Lymphocyte-rich', 'no specific marker', src([nhc], 'Ontology 1.3')).
hcc_subtype(undifferentiated,'Undifferentiated','worst prognosis', src([nhc], 'Ontology 1.3')).
% FLHCC variant as flagged by NCCN (rare; resection only cure).
hcc_subtype(flhcc_nccn, 'Fibrolamellar HCC (FLHCC) [NCCN]',
            'rare; young; no cirrhosis; AFP usually normal; DNAJB1::PRKACA fusion 79-100%; complete resection only potential cure',
            src([nccn], 'Ontology 1.1')).

% ICC subtypes  icc_subtype(Id, Name, TargetableMarkers, Src)
icc_subtype(large_duct,   'Large duct',  'ERBB2 amp, BRAF/KRAS mut, NTRK/RET fusion, MSI-H, high TMB', src([nhc], 'Ontology 1.3')).
icc_subtype(small_duct,   'Small duct',  'FGFR2 rearrangement/fusion, IDH1 mutation', src([nhc], 'Ontology 1.3')).
icc_subtype(ductular,     'Ductular',    'none specified', src([nhc], 'Ontology 1.3')).
icc_subtype(ductal_plate, 'Ductal plate malformation type', 'ARID1A mutation / loss of expression', src([nhc], 'Ontology 1.3')).

% ---- 1.6  Risk factors  risk_factor(Id, Category, Description, Src) --
risk_factor(hbv_infection,      viral,        'chronic HBV infection - leading cause in China (HBsAg+ in >90% of HCC)', src([nhc], 'Ontology 1.6')).
risk_factor(hcv_infection,      viral,        'chronic HCV infection', src([nhc], 'Ontology 1.6')).
risk_factor(liver_cirrhosis,    structural,   'cirrhosis of any cause (80-90% of HCC have cirrhosis)', src([nhc], 'Ontology 1.6')).
risk_factor(mafld,              metabolic,    'metabolic dysfunction-associated fatty liver disease', src([nhc], 'Ontology 1.6')).
risk_factor(aflatoxin_b1,       environmental,'aflatoxin B1 / cyanotoxin exposure (warm humid regions)', src([nhc], 'Ontology 1.6')).
risk_factor(drinking_water,     environmental,'ditch/pond drinking water (organics / blue-green algae)', src([caca], 'Ontology 1.6')).
risk_factor(alcohol_use,        lifestyle,    'long-term heavy alcohol use', src([nhc], 'Ontology 1.6')).
risk_factor(diabetes_mellitus,  metabolic,    'type 2 diabetes mellitus', src([nhc], 'Ontology 1.6')).
risk_factor(family_history,     hereditary,   'family history (1st-degree cumulative risk 5.37%, 2nd-degree 2.61%)', src([caca], 'Ontology 1.6')).
risk_factor(hbcab_positive,     viral,        'HBsAg-negative but HBcAb-positive - moderate/high-risk screening', src([nhc], 'Ontology 1.6')).
risk_factor(smoking,            lifestyle,    'smoking; dose-response interaction with alcohol', src([caca], 'Ontology 1.6')).
risk_factor(hdv_coinfection,    viral,        'HDV co-infection with HBV: higher HCC risk than HBV alone', src([nccn], 'Ontology 1.6')).
risk_factor(masld_no_cirrhosis, metabolic,    'MASLD-related HCC can arise without cirrhosis; harder to diagnose', src([esmo], 'Ontology 1.6')).
risk_factor(hcv_svr_f3f4,       viral,        'HCV advanced fibrosis (F3-F4) retains HCC risk even after SVR', src([esmo], 'Ontology 1.6')).

% ---- 1.6A  Etiologic synergy rules [CACA] ----------------------------
% etiology_synergy(Combination, Effect, Src)
etiology_synergy([hbv, aflatoxin_b1],             'HBV initiator, AFB1 promoter; clear synergy', src([caca], 'Ontology 1.6A')).
etiology_synergy([hcv, alcohol_use],              'alcohol doubles HCC risk in HCV; faster progression, younger onset', src([caca], 'Ontology 1.6A')).
etiology_synergy([hbv_or_hcv, diabetes_or_fatty], 'relative risk markedly elevated', src([caca], 'Ontology 1.6A')).
etiology_synergy([hbsag, alcohol_use, smoking],   'HCC risk far above any single factor; dose-response present', src([caca], 'Ontology 1.6A')).
etiology_synergy([alcohol_gt_80g_for_10y],        'daily alcohol >80 g for >10 years: 5-fold HCC risk', src([caca], 'Ontology 1.6A')).

% ---- 1.7B  Chinese HCC molecular subtypes [CACA] ---------------------
molecular_subtype_cn(metabolism_driven,     'metabolic reprogramming dominant; better prognosis; metabolic enzymes targetable', src([caca], 'Ontology 1.7B')).
molecular_subtype_cn(microenv_dysregulated, 'immune exclusion/exhaustion; ICI-responsive; TLS-related', src([caca], 'Ontology 1.7B')).
molecular_subtype_cn(proliferation_driven,  'cell-cycle/proliferation dominant; worst prognosis; targetable', src([caca], 'Ontology 1.7B')).

% ---- 1.7A  Genetic susceptibility markers [CACA] ---------------------
% genetic_susceptibility(Id, Method, Significance, Src)
genetic_susceptibility(sce, 'sister chromatid exchange (lymphocytes after AFB1 challenge)',
                       'HCC-family members show higher SCE - genetic susceptibility evidence', src([caca], 'Ontology 1.7A')).
genetic_susceptibility(uds, 'unscheduled DNA synthesis (DNA repair capacity)',
                       'elevated in HCC patients and 1st-degree relatives; HBV also impairs repair', src([caca], 'Ontology 1.7A')).
