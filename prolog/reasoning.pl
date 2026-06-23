% =============================================================================
% reasoning.pl  --  Clinical reasoning layer ON TOP of the HCC knowledge base
% =============================================================================
%
% This file adds *inference* predicates that combine base facts. It is loaded
% AFTER hcc_kb.pl, so all module facts (cnlc_stage/3, stage_treatment/5,
% stage_mapping/4, ...) are visible. The core knowledge base is NOT modified.
%
% Main entry point:
%   cnlc_classify(+PS, +ChildPugh, +TumorNum, +MaxDiam, +Vascular, +Extrahepatic, -Stage)
%     PS           : integer 0..4   (ECOG performance status)
%     ChildPugh    : 'A' | 'B' | 'C'
%     TumorNum     : integer >= 1
%     MaxDiam      : number (cm)
%     Vascular     : present | absent   (macrovascular invasion / PVTT)
%     Extrahepatic : present | absent   (extrahepatic / lymph-node metastasis)
%     Stage        : 'Ia'|'Ib'|'IIa'|'IIb'|'IIIa'|'IIIb'|'IV'  (CNLC)
%
% The clause order encodes the CNLC decision logic; the first matching clause
% wins (cuts make it deterministic), which also gives an explainable chain.
% =============================================================================

:- multifile kb_fact_predicate/2.

% --- CNLC staging classifier -------------------------------------------------
cnlc_classify(PS, CP, _N, _D, _V, _E, 'IV') :-
    ( PS >= 3 ; CP == 'C' ), !.
cnlc_classify(_PS, _CP, _N, _D, _V, present, 'IIIb') :- !.
cnlc_classify(_PS, _CP, _N, _D, present, _E, 'IIIa') :- !.
cnlc_classify(_PS, _CP, N, _D, _V, _E, 'IIb') :-
    N >= 4, !.
cnlc_classify(_PS, _CP, N, D, _V, _E, 'IIa') :-
    N >= 2, N =< 3, D > 3, !.
cnlc_classify(_PS, _CP, 1, D, _V, _E, 'Ib') :-
    D > 5, !.
cnlc_classify(_PS, _CP, N, D, _V, _E, 'Ib') :-
    N >= 2, N =< 3, D =< 3, !.
cnlc_classify(_PS, _CP, _N, _D, _V, _E, 'Ia').

% --- Child-Pugh scoring from clinical inputs ---------------------------------
% Canonical units: bilirubin umol/L, albumin g/L. Each item scores 1..3 points.
% Cutoffs are the standard Child-Pugh table (bilirubin 34.2/51.3 umol/L =
% 2/3 mg/dL; albumin 35/28 g/L = 3.5/2.8 g/dL; INR 1.7/2.3).
cp_bilirubin_points(B, 1) :- B < 34.2, !.
cp_bilirubin_points(B, 2) :- B =< 51.3, !.
cp_bilirubin_points(_, 3).

cp_albumin_points(A, 1) :- A > 35, !.
cp_albumin_points(A, 2) :- A >= 28, !.
cp_albumin_points(_, 3).

cp_inr_points(I, 1) :- I < 1.7, !.
cp_inr_points(I, 2) :- I =< 2.3, !.
cp_inr_points(_, 3).

cp_ascites_points(none,     1).
cp_ascites_points(mild,     2).
cp_ascites_points(moderate, 3).

cp_enceph_points(none,     1).
cp_enceph_points(grade1_2, 2).
cp_enceph_points(grade3_4, 3).

cp_class(Score, 'A') :- Score =< 6, !.
cp_class(Score, 'B') :- Score =< 9, !.
cp_class(_, 'C').

%% child_pugh_from_labs(+Bili, +Alb, +INR, +Ascites, +Enceph,
%%                      -Class, -Score, -PB, -PA, -PI, -PAsc, -PEn) is semidet.
%  Fails on an unrecognised Ascites/Enceph atom (caller validates first).
child_pugh_from_labs(Bili, Alb, INR, Ascites, Enceph, Class, Score, PB, PA, PI, PAsc, PEn) :-
    cp_bilirubin_points(Bili, PB),
    cp_albumin_points(Alb, PA),
    cp_inr_points(INR, PI),
    cp_ascites_points(Ascites, PAsc),
    cp_enceph_points(Enceph, PEn),
    Score is PB + PA + PI + PAsc + PEn,
    cp_class(Score, Class).

% --- ALBI grade from labs ----------------------------------------------------
% ALBI = 0.66*log10(bilirubin umol/L) - 0.085*(albumin g/L). Cutoffs -2.60/-1.39.
albi_class(Score, 1) :- Score =< -2.60, !.
albi_class(Score, 2) :- Score =< -1.39, !.
albi_class(_, 3).

%% albi_from_labs(+Bili, +Alb, -Grade, -Score) is semidet.
albi_from_labs(Bili, Alb, Grade, Score) :-
    Bili > 0,
    Score is 0.66 * (log(Bili) / log(10)) - 0.085 * Alb,
    albi_class(Score, Grade).

% --- Explainable chain (which rule fired + why) ------------------------------
% Returns a short reason atom alongside the stage, for the "reasoning chain"
% demonstration. Mirrors the clause order above.
cnlc_classify_explained(PS, CP, N, D, V, E, Stage, Reason) :-
    ( ( PS >= 3 ; CP == 'C' )    -> Stage = 'IV',   Reason = 'PS>=3 or Child-Pugh C'
    ; E == present               -> Stage = 'IIIb', Reason = 'extrahepatic/nodal metastasis'
    ; V == present               -> Stage = 'IIIa', Reason = 'macrovascular invasion (PVTT)'
    ; N >= 4                      -> Stage = 'IIb',  Reason = '>=4 tumours'
    ; ( N >= 2, N =< 3, D > 3 )  -> Stage = 'IIa',  Reason = '2-3 tumours, at least one >3cm'
    ; ( N =:= 1, D > 5 )         -> Stage = 'Ib',   Reason = 'single tumour >5cm'
    ; ( N >= 2, N =< 3, D =< 3 ) -> Stage = 'Ib',   Reason = '2-3 tumours each <=3cm'
    ;                               Stage = 'Ia',   Reason = 'single tumour <=5cm'
    ).
