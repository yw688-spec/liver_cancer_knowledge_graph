% =====================================================================
%  references.pl  --  Real bibliographic coordinates for every src Section
% ---------------------------------------------------------------------
%  Each clinical fact in this KB carries src(Guidelines, Section), where
%  Section (e.g. 'Treatment 4.7') is an INTERNAL KB module locator. This
%  file maps each (Section, Guideline) pair to the REAL document location
%  in the published guideline, so a citation can be traced to "which
%  document, which section, which page".
%
%    guideline_doc(Guideline, FullCitation)
%    reference(Section, Guideline, SectionTitle, Locator)
%
%  Locator is the real page (or page range) in the source document.
%  Section titles are the guideline's own headings, verified against the
%  source PDFs. Coverage is filled guideline by guideline; a missing
%  (Section, Guideline) pair simply yields no real reference (the badge
%  still shows the guideline name).
% =====================================================================

% ---- source documents -----------------------------------------------
guideline_doc(nhc,  '《原发性肝癌诊疗指南（2026年版）》 国家卫生健康委员会医政司 · 协和医学杂志 2026;17(3):735-770').
guideline_doc(caca, '《中国肿瘤整合诊治指南（CACA指南）·肝癌》 中国抗癌协会 2022').
guideline_doc(nccn, 'NCCN Clinical Practice Guidelines in Oncology: Hepatocellular Carcinoma, Version 1.2026').
guideline_doc(esmo, 'ESMO Clinical Practice Guideline: Hepatocellular Carcinoma (Vogel et al., Annals of Oncology 2025)').

% ---- NHC (原发性肝癌诊疗指南 2026年版) -------------------------------
% Ontology / pathology basics
reference('Ontology 1.1', nhc, '概述（肝癌病理学类型）',            '期刊 p.736').
reference('Ontology 1.2', nhc, '病理学诊断 · 大体分型',            '期刊 p.742-743').
reference('Ontology 1.3', nhc, '病理学诊断 · 组织学亚型',          '期刊 p.743-744').
reference('Ontology 1.6', nhc, '预防、筛查与监测 · 高危人群',       '期刊 p.737').

% Grading / staging
reference('Grading 1.4',  nhc, '病理学诊断 · 组织学分化分级',       '期刊 p.743').
reference('Grading 1.5',  nhc, '病理学诊断 · 微血管侵犯（MVI）分级', '期刊 p.744').
reference('Grading 1.7',  nhc, '预防、筛查与监测 · 风险预测模型',    '期刊 p.737').
reference('Grading 1.8',  nhc, '治疗 · 体力状态（ECOG PS）评估',    '期刊 p.746-748').
reference('Grading 1.9',  nhc, '肝功能评估（Child-Pugh / ALBI）',   '期刊 p.746').
reference('Grading 4.10', nhc, '门静脉癌栓（PVTT）分型',            '期刊 p.749').
reference('Grading CNLC', nhc, '中国肝癌分期方案（CNLC）',          '期刊 p.747').

% Diagnosis
reference('Diagnosis 3.1', nhc, '预防、筛查与监测',                 '期刊 p.737-738').
reference('Diagnosis 3.2', nhc, '影像学检查',                       '期刊 p.738-740').
reference('Diagnosis 3.3', nhc, '实验室检查 · 肿瘤标志物',          '期刊 p.741').
reference('Diagnosis 3.4', nhc, '影像学诊断 · “快进快出”典型征象',   '期刊 p.740,747').
reference('Diagnosis 3.5', nhc, '病理学诊断 · 穿刺活检指征',        '期刊 p.742').
reference('Diagnosis 3.6', nhc, '病理学诊断 · 免疫组化与分型靶向',  '期刊 p.745').
reference('Diagnosis 3.7', nhc, '系统抗肿瘤治疗 · 疗效评价',        '期刊 p.767').
reference('Diagnosis 3.8', nhc, '影像学随访',                       '期刊 p.739').

% Evidence framework
reference('Evidence 2.1', nhc, '推荐分级的评估、制定与评价（GRADE/OCEBM）', '期刊 p.736').
reference('Evidence 2.2', nhc, '推荐强度分级',                      '期刊 p.736').
reference('Evidence 2.3', nhc, '系统抗肿瘤治疗（关键临床研究）',      '期刊 p.763-766').

% Cross-guideline conflict resolution (NHC as the final authority)
reference('Conflict 2.4', nhc, '本指南全文（作为最终权威的国家方案）', '期刊 p.735-770').
reference('Conflict 2.4 staging', nhc, '中国肝癌分期方案（CNLC）',   '期刊 p.747').

% Treatment
reference('Treatment 4.1',  nhc, '治疗总则（分期与 MDT）',          '期刊 p.748').
reference('Treatment 4.2',  nhc, '外科治疗 · 肝癌的手术切除',       '期刊 p.748-752').
reference('Treatment 4.3',  nhc, '外科治疗 · 肝移植',              '期刊 p.752').
reference('Treatment 4.4',  nhc, '消融治疗',                        '期刊 p.753-755').
reference('Treatment 4.5',  nhc, '介入治疗（TACE / HAIC）',         '期刊 p.756').
reference('Treatment 4.6',  nhc, '放射治疗',                        '期刊 p.761-763').
reference('Treatment 4.7',  nhc, '系统抗肿瘤治疗（一线 / 二线）',    '期刊 p.763-766').
reference('Treatment 4.8',  nhc, '系统抗肿瘤治疗 · 抗病毒治疗',     '期刊 p.768').
reference('Treatment 4.9',  nhc, '中医药治疗 / 保肝对症支持治疗',    '期刊 p.767-769').
reference('Treatment 4.10', nhc, '门静脉癌栓（PVTT）的治疗',        '期刊 p.749').
reference('Treatment 4.11', nhc, '肝癌自发破裂的治疗',              '期刊 p.769').

% ---- CACA (中国肿瘤整合诊治指南·肝癌 2022) --------------------------
reference('Conflict 2.4',         caca, '全文（防-筛-诊-治-康）',            'p.1-78').
reference('Conflict 2.4 staging', caca, '诊断 · 临床分期',                  'p.19-27').
reference('Diagnosis 3.1',        caca, '筛查 · 筛查方法',                  'p.12').
reference('Diagnosis 3.3',        caca, '诊断 · 血清学（甲胎蛋白 AFP）',    'p.17').
reference('Diagnosis 3.6',        caca, '病理学 · 免疫组织化学检查',        'p.23-24').
reference('Diagnosis 3.8',        caca, '康复 · 姑息治疗后的维持治疗',      'p.50').
reference('Evidence 2.1',         caca, '概述（CACA 证据与推荐说明）',       'p.2-3').
reference('Evidence 2.3',         caca, '治疗 · 系统治疗（一线/二线）',      'p.42-45').
reference('Evidence 2.3A',        caca, '治疗 · 系统治疗（一线/二线）',      'p.42-45').
reference('Ontology 1.6',         caca, '病因学 · 危险因素（一级预防）',     'p.7-8').
reference('Ontology 1.6A',        caca, '病因学 · 各因素间相互协同作用',     'p.8').
reference('Ontology 1.7A',        caca, '病理学 · 分子分型',                'p.21').
reference('Ontology 1.7B',        caca, '病理学 · 分子分型',                'p.21').
reference('Treatment 4.12',       caca, '康复 · 患者的生活指导',            'p.49-51').
reference('Treatment 4.2',        caca, '外科治疗 · 肝切除',                'p.28-32').
reference('Treatment 4.3',        caca, '外科治疗 · 肝移植 / 术后辅助治疗', 'p.32-33').
reference('Treatment 4.5',        caca, '介入治疗 · 动脉灌注化疗 / TACE',   'p.38').
reference('Treatment 4.8',        caca, '治疗 · 抗病毒治疗及其他保肝治疗',  'p.46').
reference('Treatment 4.9',        caca, '治疗 · 中国医药学治疗',            'p.45-46').

% ---- NCCN (Hepatocellular Carcinoma, Version 1.2026) ----------------
reference('Conflict 2.4',   nccn, 'Full guideline & Discussion',                'p.1-115').
reference('Diagnosis 3.2',  nccn, 'Principles of Imaging',                      'p.13-15').
reference('Diagnosis 3.3',  nccn, 'Principles of Biomarker Testing',           'p.29').
reference('Diagnosis 3.5',  nccn, 'Principles of Core Needle Biopsy',          'p.16').
reference('Diagnosis 3.6',  nccn, 'Principles of Pathology',                   'p.19').
reference('Diagnosis 3.7',  nccn, 'Principles of Systemic Therapy',            'p.27-28').
reference('Diagnosis 3.8',  nccn, 'Surveillance (HCC-1)',                      'p.8').
reference('Evidence 2.1',   nccn, 'NCCN Categories of Evidence and Consensus', 'p.33').
reference('Evidence 2.3',   nccn, 'Principles of Systemic Therapy',            'p.27-28').
reference('Evidence 2.3A',  nccn, 'Principles of Systemic Therapy',            'p.27-28').
reference('Grading 1.9',    nccn, 'Principles of Liver Functional Assessment', 'p.20').
reference('Ontology 1.1',   nccn, 'Principles of Pathology',                   'p.19').
reference('Ontology 1.6',   nccn, 'Surveillance / Risk Factors (HCC-1)',       'p.7-8').
reference('Treatment 4.2',  nccn, 'Principles of Resection and Transplant',    'p.22').
reference('Treatment 4.3',  nccn, 'Principles of Resection and Transplant',    'p.22').
reference('Treatment 4.5',  nccn, 'Principles of Locoregional Therapy',        'p.23-24').
reference('Treatment 4.6',  nccn, 'Principles of Radiation Therapy',           'p.25').
reference('Treatment 4.7',  nccn, 'Principles of Systemic Therapy',            'p.27-28').
reference('Treatment 4.8',  nccn, 'Discussion · Viral hepatitis management',   'p.36').

% ---- ESMO (Hepatocellular Carcinoma CPG, Ann Oncol 2025) -----------
reference('Conflict 2.4',   esmo, 'Full guideline',                            'p.1-14').
reference('Diagnosis 3.1',  esmo, 'Surveillance',                              'p.1-2').
reference('Diagnosis 3.3A', esmo, 'Staging · portal hypertension (Baveno VII)', 'p.3-4').
reference('Diagnosis 3.5',  esmo, 'Diagnosis, pathology and molecular biology', 'p.2-3').
reference('Diagnosis 3.8',  esmo, 'Response assessment and follow-up',         'p.11').
reference('Evidence 2.1B',  esmo, 'Methodology',                               'p.12').
reference('Evidence 2.1C',  esmo, 'Methodology',                               'p.12').
reference('Evidence 2.3',   esmo, 'Systemic treatment (first / second-line)',  'p.8-11').
reference('Evidence 2.3A',  esmo, 'Systemic treatment (first / second-line)',  'p.8-11').
reference('Grading 1.6B',   esmo, 'Incidence and epidemiology · PAGE-B score', 'p.1-2').
reference('Ontology 1.6',   esmo, 'Incidence and epidemiology',               'p.1-2').
reference('Treatment 4.3',  esmo, 'Liver transplantation',                     'p.7').
reference('Treatment 4.5',  esmo, 'Transarterial therapies',                   'p.6').
reference('Treatment 4.7',  esmo, 'Systemic treatment (first / second-line)',  'p.8-11').
