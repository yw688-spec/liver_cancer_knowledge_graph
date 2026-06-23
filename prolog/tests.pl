% =============================================================================
% tests.pl  --  Regression test suite for the HCC knowledge base
% =============================================================================
%
% Uses SWI-Prolog's plunit framework. Twenty assertions, simple -> complex,
% mirroring the 20 worked examples. Each test pins an EXACT expected value so a
% future edit that changes a fact, a source tag, or a count is caught.
%
% RUN (interactive):
%   ?- [tests].
%   ?- run_tests.
%
% RUN (CI gate - exits 0 on full pass, non-zero on any failure):
%   swipl -q -g "(run_tests -> halt(0) ; halt(1))" tests.pl
%
% On failure, plunit prints the failing test name, the file:line, and the
% expected-vs-actual values (e.g.  Assertion: '81%'=='80%'), and the explicit
% gate above turns that into a non-zero exit code suitable for CI.
% =============================================================================

:- ensure_loaded(hcc_kb).      % loads sources + all 5 modules + the interface
:- ensure_loaded(reasoning).   % classifier + Child-Pugh/ALBI scoring predicates

:- use_module(library(plunit)).

% -----------------------------------------------------------------------------
% Helpers used by assertions
% -----------------------------------------------------------------------------
contains(Hay, Needle) :-           % substring test tolerant of atom/string
    atom_string(Hay, HayS),
    sub_string(HayS, _, _, _, Needle).

% =============================================================================
% SIMPLE  (1-6) : single-fact retrieval
% =============================================================================
:- begin_tests(simple).

% 1. default cancer type
test(default_cancer_type) :-
    default_cancer_type(X),
    assertion(X == hcc).

% 2. HCC full name + share
test(cancer_type_hcc) :-
    cancer_type(hcc, Name, Pct, _),
    assertion(Name == 'Hepatocellular Carcinoma'),
    assertion(Pct == '80%').

% 3. Child-Pugh A score range
test(child_pugh_a) :-
    child_pugh('A', Range, _, _),
    assertion(Range == '5-6').

% 4. MVI M2b definition + risk
test(mvi_m2b) :-
    mvi_grade(m2b, Def, Risk, _),
    assertion(Risk == high),
    assertion(contains(Def, "> 1 cm")).

% 5. CNLC IIIa is the PVTT (tumour-thrombus) stage
test(cnlc_iiia_pvtt) :-
    cnlc_stage('IIIa', Desc, _),
    assertion(contains(Desc, "thrombus")).

% 6. PVTT Cheng type III
test(pvtt_type_iii) :-
    pvtt_type('III', Site, Mgmt, _),
    assertion(Site == 'invasion of the main portal trunk'),
    assertion(Mgmt == 'direct surgery NOT advised').

:- end_tests(simple).

% =============================================================================
% MEDIUM  (7-13) : provenance, mapping, cross-module shortcuts
% =============================================================================
:- begin_tests(medium).

% 7. generic provenance extraction
test(source_of_cancer_type) :-
    source_of(cancer_type(hcc,_,_,_), Src),
    assertion(Src == src([nhc], 'Ontology 1.1')).

% 8. citation source for a Child-Pugh fact
test(source_of_child_pugh_c) :-
    source_of(child_pugh('C',_,_,_), Src),
    assertion(Src == src([nhc], 'Grading 1.9')).

% 9. stage normalisation + CNLC->BCLC mapping (lowercase input accepted)
test(staging_ia_maps_bclc0) :-
    normalize_stage(ia, Canon),
    assertion(Canon == 'Ia'),
    stage_mapping('Ia', Bclc, _, _),
    assertion(Bclc == '0').

% 10. CNLC Ia first-line treatment
test(treatment_ia_firstline) :-
    stage_treatment('Ia', Line1, _, _, _),
    assertion(Line1 == 'resection or ablation').

% 11. diagnostic pathway for a 1-2 cm nodule
test(pathway_1_2cm) :-
    once(( diagnostic_pathway(P, Size, _, _, _), contains(Size, "1-2 cm") )),
    assertion(P == path2).

% 12. transplant criteria collected (China: UCSF authoritative, listed first)
test(transplant_criteria_set) :-
    findall(C, transplant_criterion(C,_,_,_), L),
    assertion(L == [ucsf, milan, hz_wx_sanya, unos]).

% 13. HBsAg+ antiviral rule: start immediately, NHC-sourced
test(antiviral_hbsag) :-
    antiviral_rule('HBsAg+ (standard)', Rule, Src),
    assertion(contains(Rule, "immediately")),
    assertion(Src == src([nhc], 'Treatment 4.8')).

:- end_tests(medium).

% =============================================================================
% COMPLEX  (14-20) : aggregation, conflict resolution, multi-condition reasoning
% =============================================================================
:- begin_tests(complex).

% 14. total sourced/registered facts in the KB
test(total_fact_count) :-
    aggregate_all(count,
        ( kb_fact_predicate(_, Name/Arity), functor(G, Name, Arity), call(G) ),
        Total),
    assertion(Total == 396).

% 15. ESMO-cited facts (primary or co-attribution)
test(esmo_fact_count) :-
    aggregate_all(count,
        ( fact_with_source(_, src(Gs,_)), memberchk(esmo, Gs) ),
        N),
    assertion(N == 44).

% 16. NCCN-cited facts
test(nccn_fact_count) :-
    aggregate_all(count,
        ( fact_with_source(_, src(Gs,_)), memberchk(nccn, Gs) ),
        N),
    assertion(N == 82).

% 17. HBV antiviral conflict ruling is NHC-anchored across NHC/NCCN/ESMO
test(conflict_hbv_antiviral) :-
    conflict_resolution(hbv_antiviral, Pos, Rule, Src),
    assertion(contains(Pos, "immediately")),
    assertion(contains(Rule, "absolute rule")),
    assertion(Src == src([nhc, nccn, esmo], 'Conflict 2.4')).

% 18. number of conflict-resolution entries
test(conflict_count) :-
    aggregate_all(count, conflict_resolution(_,_,_,_), N),
    assertion(N == 20).

% 19. first-line systemic regimens PRIMARILY attributed to NHC
%     (first element of the source list is nhc)
test(nhc_primary_first_line) :-
    findall(C, systemic_1l(C,_,_,_,src([nhc|_],_)), L),
    length(L, N),
    assertion(N == 13).

% 20. multi-condition reasoning: entries where NHC is authoritative / NMPA-backed
%     yet ESMO is involved (the China-vs-West divergences). Verifies the
%     conflict table supports cross-guideline divergence detection.
test(china_authoritative_vs_esmo) :-
    findall(T,
        ( conflict_resolution(T, _, Rule, src(Gs,_)),
          ( contains(Rule, "authoritative") ; contains(Rule, "NMPA") ),
          memberchk(esmo, Gs) ),
        Ts),
    sort(Ts, Sorted),
    assertion(Sorted == [stride, systemic_chemo_folfox4, transplant_criteria]).

:- end_tests(complex).

% =============================================================================
% SCORING  : Child-Pugh + ALBI computed from clinical inputs (reasoning.pl)
% =============================================================================
:- begin_tests(scoring).

% All-best inputs -> Child-Pugh A, score 5.
test(child_pugh_all_a) :-
    child_pugh_from_labs(20.0, 40.0, 1.0, none, none, Class, Score, _, _, _, _, _),
    assertion(Class == 'A'),
    assertion(Score =:= 5).

% Boundary: total score 6 stays A (bilirubin 2 pts, rest best -> 2+1+1+1+1=6).
test(child_pugh_boundary_a6) :-
    child_pugh_from_labs(40.0, 40.0, 1.0, none, none, Class, Score, _, _, _, _, _),
    assertion(Class == 'A'),
    assertion(Score =:= 6).

% One more point tips into B at score 7.
test(child_pugh_boundary_b7) :-
    child_pugh_from_labs(40.0, 40.0, 1.0, mild, none, Class, Score, _, _, _, _, _),
    assertion(Class == 'B'),
    assertion(Score =:= 7).

% Decompensated inputs -> C.
test(child_pugh_class_c) :-
    child_pugh_from_labs(60.0, 25.0, 2.5, moderate, grade3_4, Class, Score, _, _, _, _, _),
    assertion(Class == 'C'),
    assertion(Score =:= 15).

% Unrecognised ascites atom must fail (caller validates before calling).
test(child_pugh_bad_ascites, [fail]) :-
    child_pugh_from_labs(20.0, 40.0, 1.0, huge, none, _, _, _, _, _, _, _).

% ALBI grade 1 for good function (bilirubin 15 umol/L, albumin 45 g/L).
test(albi_grade_1) :-
    albi_from_labs(15.0, 45.0, Grade, Score),
    assertion(Grade == 1),
    assertion(Score =< -2.60).

% ALBI grade 3 for poor function.
test(albi_grade_3) :-
    albi_from_labs(80.0, 25.0, Grade, _),
    assertion(Grade == 3).

:- end_tests(scoring).

% -----------------------------------------------------------------------------
% Convenience entry point: run everything and report.
% -----------------------------------------------------------------------------
:- initialization((
       ( current_prolog_flag(argv, [run|_]) -> run_tests ; true )
   )).
