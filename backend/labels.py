# -*- coding: utf-8 -*-
"""
labels.py -- Chinese localization layer for the HCC knowledge base.

The Prolog KB is intentionally English (the authoritative source of facts and
provenance). This module maps the KB's English atoms/keys to Chinese display
strings. It is also the term bank the future natural-language layer will use to
map Chinese input back to KB atoms.

Lookup helpers fall back to the English value when a Chinese label is missing,
so the API never returns an empty label.
"""

# --- Guideline Chinese names (codes match sources.pl) ---
GUIDELINE_CN = {
    "nhc":  "国家卫健委 2026",
    "caca": "中国抗癌协会 CACA 2026",
    "nccn": "NCCN（美国）2026",
    "esmo": "ESMO（欧洲）2025",
}
GUIDELINE_SHORT_CN = {"nhc": "卫健委", "caca": "抗癌协会", "nccn": "NCCN", "esmo": "ESMO"}

# --- Systemic regimens: atom -> Chinese name ---
SYSTEMIC_CN = {
    "atezolizumab_bevacizumab": "阿替利珠单抗 + 贝伐珠单抗",
    "nivolumab_ipilimumab": "纳武利尤单抗 + 伊匹木单抗",
    "camrelizumab_apatinib": "卡瑞利珠单抗 + 阿帕替尼",
    "sintilimab_bev_biosimilar": "信迪利单抗 + 贝伐类似物",
    "penpulimab_bevacizumab": "派安普利单抗 + 贝伐珠单抗",
    "toripalimab_bevacizumab": "特瑞普利单抗 + 贝伐珠单抗",
    "anlotinib_penpulimab": "安罗替尼 + 派安普利单抗",
    "donafenib": "多纳非尼",
    "lenvatinib": "仑伐替尼",
    "tislelizumab": "替雷利珠单抗",
    "sorafenib": "索拉非尼",
    "folfox4": "FOLFOX4 化疗",
    "stride_durva_treme": "STRIDE：度伐利尤单抗 + 替西木单抗",
    "durvalumab_mono": "度伐利尤单抗单药",
    "regorafenib": "瑞戈非尼",
    "apatinib": "阿帕替尼",
    "ramucirumab": "雷莫西尤单抗",
    "pembrolizumab": "帕博利珠单抗",
    "cabozantinib": "卡博替尼",
    "camrelizumab": "卡瑞利珠单抗（二线）",
    "tislelizumab_2l": "替雷利珠单抗（二线）",
    "post_ici_failure": "ICI 失败后",
    "nivolumab_mono": "纳武利尤单抗单药",
}

# --- Risk factor categories: atom -> Chinese ---
RISK_CATEGORY_CN = {
    "viral": "病毒",
    "structural": "结构",
    "metabolic": "代谢",
    "environmental": "环境",
    "lifestyle": "生活方式",
    "hereditary": "遗传",
}
# Risk factor: atom -> Chinese name (the KB description stays available as English detail)
RISK_CN = {
    "hbv_infection": "慢性 HBV 感染",
    "hcv_infection": "慢性 HCV 感染",
    "liver_cirrhosis": "肝硬化（任何病因）",
    "mafld": "代谢相关脂肪性肝病（MAFLD）",
    "aflatoxin_b1": "黄曲霉毒素 B1 暴露",
    "drinking_water": "沟塘饮用水",
    "alcohol_use": "长期大量饮酒",
    "diabetes_mellitus": "2 型糖尿病",
    "family_history": "肝癌家族史",
    "hbcab_positive": "HBsAg 阴性但 HBcAb 阳性",
    "smoking": "吸烟",
    "hdv_coinfection": "HDV 合并 HBV 感染",
    "masld_no_cirrhosis": "MASLD 相关（可无肝硬化）",
    "hcv_svr_f3f4": "HCV 进展期纤维化（F3–F4）",
}

# --- Imaging modalities: atom -> Chinese name ---
IMAGING_CN = {
    "ultrasound": "超声（US）",
    "ceus": "超声造影（CEUS）",
    "dynamic_ct": "动态增强 CT",
    "dynamic_mri_ecf": "动态增强 MRI（细胞外对比剂）",
    "gd_eob_dtpa_mri": "钆塞酸（Gd-EOB-DTPA）增强 MRI",
    "dsa_cbct": "DSA / 锥束 CT",
    "pet_ct_fdg": "PET/CT（FDG）",
    "pet_ct_acetate": "PET/CT（乙酸盐）",
    "y90_spect_ct": "Y90 SPECT/CT",
}

# --- MVI ---
MVI_CN = {
    "m0": ("M0", "未见微血管侵犯", "无"),
    "m1": ("M1", "≤5 个 MVI，均位于癌旁肝组织（≤1cm）", "低危"),
    "m2a": ("M2a", ">5 个 MVI，均位于癌旁肝组织（≤1cm）", "高危"),
    "m2b": ("M2b", "MVI 位于远癌肝组织（>1cm）", "高危"),
}
MVI_RISK_CN = {"none": "无", "low": "低危", "high": "高危"}

# --- IHC category: English key -> Chinese ---
IHC_CN = {
    "hepatocyte origin (positive)": "肝细胞起源（阳性）",
    "benign vs malignant HCC": "良恶性鉴别",
    "microvessel density/pattern": "微血管密度 / 模式",
    "ICC targetable (large duct)": "ICC 可靶向（大胆管型）",
    "ICC targetable (small duct)": "ICC 可靶向（小胆管型）",
    "FLHCC molecular dx": "纤维板层型 HCC 分子诊断",
    "TLS (tertiary lymphoid structures)": "三级淋巴结构（TLS）",
}

# --- CNLC stage Chinese labels + BCLC mapping note (label only; data from KB) ---
STAGE_CN = {
    "Ia": "CNLC Ia 期", "Ib": "CNLC Ib 期",
    "IIa": "CNLC IIa 期", "IIb": "CNLC IIb 期",
    "IIIa": "CNLC IIIa 期", "IIIb": "CNLC IIIb 期", "IV": "CNLC IV 期",
}
# Chinese rendering of the (English) stage_treatment line phrases
STAGE_LINE_CN = {
    "resection or ablation": "手术切除 或 消融",
    "transplant (if unresectable)": "肝移植（不可切除时）",
    "resection": "手术切除",
    "ablation; TACE; transplant": "消融；TACE；肝移植",
    "TACE; ablation": "TACE；消融",
    "TACE +/- systemic therapy": "TACE ± 系统治疗",
    "surgery (same lobe); HAIC": "手术（同叶）；HAIC",
    "TACE/HAIC + systemic therapy": "TACE/HAIC + 系统治疗",
    "surgery (type I/II PVTT); radiotherapy": "手术（I/II 型癌栓）；放疗",
    "systemic therapy": "系统治疗",
    "TACE/HAIC; radiotherapy": "TACE/HAIC；放疗",
    "best supportive care + TCM": "最佳支持治疗 + 中医药",
    "systemic therapy (if it improves PS)": "系统治疗（如能改善体能状态）",
}
# Chinese rendering of stage_treatment notes (keyed by CNLC stage)
STAGE_NOTE_CN = {
    "Ia": "≤3cm 时切除与消融总生存相近，切除局部复发更低",
    "Ib": "2–3 个 ≤3cm 或肝功能不足时可选消融",
    "IIa": "标准术式为手术；TACE 作为备选",
    "IIb": "手术非首选，经 MDT 评估后可行",
    "IIIa": "主干癌栓不建议直接手术",
    "IIIb": "孤立转移灶可考虑 SBRT",
    "IV": "以生活质量为核心",
}
# BCLC label by stage (from stage_mapping in KB; here for Chinese display)
BCLC_CN = {
    "Ia": "BCLC 0（极早期）", "Ib": "BCLC A（早期）",
    "IIa": "BCLC A/B", "IIb": "BCLC B（中期）",
    "IIIa": "BCLC C（晚期·大血管侵犯）", "IIIb": "BCLC C（晚期·肝外转移）",
    "IV": "BCLC D（终末期）",
}

# --- Molecular: KB subtype atom -> (group, groupCn, Chinese marker text) ---
# Built from icc_subtype / hcc_subtype / molecular_subtype_cn entries we surface.
MOLECULAR = [
    # (predicate, key, group, groupCn, marker_cn)
    ("icc_subtype", "small_duct", "small_duct", "小胆管型 ICC", "FGFR2 重排/融合、IDH1 突变（靶向靶点）"),
    ("icc_subtype", "large_duct", "large_duct", "大胆管型 ICC", "ERBB2(HER2) 扩增、BRAF/KRAS 突变、NTRK/RET 融合、MSI-H、高 TMB"),
    ("hcc_subtype", "fibrolamellar", "hcc", "HCC 特殊亚型", "DNAJB1-PRKACA 融合（纤维板层型；年轻、无肝硬化）"),
    ("hcc_subtype", "scirrhous", "hcc", "HCC 特殊亚型", "TSC1/2 突变（硬化型）"),
    ("hcc_subtype", "macrotrabecular", "hcc", "HCC 特殊亚型", "TP53 突变 + FGF19 扩增（粗梁型，侵袭性）"),
    ("molecular_subtype_cn", "metabolism_driven", "caca", "CACA 分子分型", "代谢驱动型：代谢重编程为主，预后较好，代谢酶可靶向"),
    ("molecular_subtype_cn", "microenv_dysregulated", "caca", "CACA 分子分型", "微环境失调型：免疫排斥/耗竭，对 ICI 应答，TLS 相关"),
    ("molecular_subtype_cn", "proliferation_driven", "caca", "CACA 分子分型", "增殖驱动型：细胞周期/增殖为主，预后最差，可靶向"),
]

# --- Evidence framework Chinese ---
OCEBM_CN = {
    1: "RCT 的系统评价，或大效应量单项 RCT（最高）",
    2: "单项 RCT，或前瞻性队列研究",
    3: "非随机对照队列 / 随访研究",
    4: "病例系列、病例对照、历史对照",
    5: "基于机制的推理；专家意见（最低）",
}
GRADE_CN = {
    "A": "强推荐：高度确信，多数患者应采用（对应 NCCN Cat.1 / Preferred）",
    "B": "中等推荐：中度确信，需共同决策（Cat.2A / Other）",
    "C": "弱推荐：确信有限，有条件、需共同决策（Cat.2B / Useful）",
}


def cn(mapping, key, fallback=None):
    """Look up a Chinese label, falling back to the English key (or given fallback)."""
    return mapping.get(key, fallback if fallback is not None else key)

# CNLC stage criteria (Chinese) keyed by stage atom
STAGE_CRITERIA_CN = {
    "Ia": "单发肿瘤 ≤5cm；PS 0–2；Child-Pugh A/B；无血管侵犯及肝外转移",
    "Ib": "单发 >5cm，或 2–3 个均 ≤3cm；PS 0–2；CP A/B；无侵犯/转移",
    "IIa": "2–3 个肿瘤，至少一个 >3cm；PS 0–2；CP A/B；无侵犯/转移",
    "IIb": "≥4 个肿瘤（任意大小）；PS 0–2；CP A/B；无侵犯/转移",
    "IIIa": "任意肿瘤伴门静脉/肝静脉/下腔静脉癌栓（PVTT）；PS 0–2；CP A/B",
    "IIIb": "任意肿瘤伴肝外/淋巴结转移；PS 0–2；CP A/B",
    "IV": "PS 3–4，或 Child-Pugh C",
}

# Systemic regimen Chinese efficacy notes keyed by atom
SYSTEMIC_NOTE_CN = {
    "atezolizumab_bevacizumab": "mOS 19.2 vs 13.4 月；中国亚组 HR 0.53",
    "nivolumab_ipilimumab": "mOS 23.7 vs 20.6 月；注意早期死亡率偏高",
    "camrelizumab_apatinib": "mOS 23.8 vs 15.2 月；毒性最高（G3–4 AE 81%）",
    "sintilimab_bev_biosimilar": "mOS 未达 vs 10.4 月（HR 0.57）",
    "penpulimab_bevacizumab": "mOS 22.1 vs 14.2 月（HR 0.60）",
    "toripalimab_bevacizumab": "mOS 20.0 vs 14.5 月（HR 0.76）",
    "anlotinib_penpulimab": "PFS 风险 −47%；OS 风险 −31%",
    "donafenib": "优于索拉非尼（死亡 −17%）",
    "lenvatinib": "OS 非劣，PFS 优于索拉非尼",
    "tislelizumab": "OS 非劣于索拉非尼",
    "sorafenib": "CP-A 获益更明确",
    "folfox4": "NMPA：不适合手术/局部治疗的局部晚期或转移",
    "stride_durva_treme": "HR 0.78；HBV+ 亚组 HR 0.66；中国待 NMPA",
    "durvalumab_mono": "NCCN Cat.1 / ESMO I,A；中国未批准",
    "regorafenib": "索拉非尼进展且可耐受后；死亡 −37%",
    "apatinib": "≥1 线系统治疗后（NMPA）；mOS 8.7 vs 6.8 月",
    "ramucirumab": "索拉非尼后且 AFP ≥400 ng/mL；死亡 −29%",
    "pembrolizumab": "mOS 14.6 vs 13.0 月",
    "cabozantinib": "NCCN Cat.1；mOS 10.2 vs 8.0 月（HR 0.76）",
    "camrelizumab": "索拉非尼/仑伐替尼/奥沙利铂化疗后（NMPA）",
    "tislelizumab_2l": "mOS 13.2 月",
    "post_ici_failure": "换用未用过的一线方案；强烈建议入组临床试验",
    "nivolumab_mono": "FDA 2021 撤销二线适应症 · 不推荐",
}

# Risk-factor Chinese notes keyed by atom
RISK_NOTE_CN = {
    "hbv_infection": "中国首要病因（HCC 中 HBsAg+ >90%）",
    "hcv_infection": "",
    "liver_cirrhosis": "80–90% 的 HCC 合并肝硬化",
    "mafld": "",
    "aflatoxin_b1": "温暖潮湿地区",
    "drinking_water": "有机物 / 蓝藻毒素",
    "alcohol_use": "",
    "diabetes_mellitus": "",
    "family_history": "一级亲属累积风险 5.37%，二级 2.61%",
    "hbcab_positive": "中/高危筛查人群",
    "smoking": "与饮酒存在剂量-反应协同",
    "hdv_coinfection": "风险高于单纯 HBV",
    "masld_no_cirrhosis": "可无肝硬化即发生，更难诊断",
    "hcv_svr_f3f4": "SVR 后仍保留 HCC 风险",
}

# Imaging-modality Chinese use keyed by atom
IMAGING_USE_CN = {
    "ultrasound": "初筛与监测",
    "ceus": "鉴别诊断；消融引导与即刻评估",
    "dynamic_ct": "诊断、分期、疗效；TACE 碘油评估",
    "dynamic_mri_ecf": "首选影像；≤2cm 诊断优于 CT",
    "gd_eob_dtpa_mri": "亚厘米 HCC；肝功能差；癌前鉴别",
    "dsa_cbct": "TACE 前必查；三维血管解剖",
    "pet_ct_fdg": "全身分期、再分期；高摄取提示侵袭性",
    "pet_ct_acetate": "高分化 HCC 的补充",
    "y90_spect_ct": "放射栓塞前剂量学与疗效评估",
}

# --- Staging reason: English atom from reasoning.pl -> Chinese ---
REASON_CN = {
    'PS>=3 or Child-Pugh C':            'PS≥3 或 Child-Pugh C 级',
    'extrahepatic/nodal metastasis':     '存在肝外转移或淋巴结转移',
    'macrovascular invasion (PVTT)':     '存在大血管侵犯（门静脉/肝静脉/下腔静脉癌栓）',
    '>=4 tumours':                       '肿瘤数目 ≥4 个',
    '2-3 tumours, at least one >3cm':   '2–3 个肿瘤，至少一个直径 >3cm',
    'single tumour >5cm':               '单发肿瘤，直径 >5cm',
    '2-3 tumours each <=3cm':           '2–3 个肿瘤，均 ≤3cm',
    'single tumour <=5cm':              '单发肿瘤，直径 ≤5cm',
}
