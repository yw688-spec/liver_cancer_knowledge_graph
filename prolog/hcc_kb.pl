% =============================================================================
% hcc_kb.pl  --  HCC Clinical Knowledge Base : INTEGRATION INTERFACE
% =============================================================================
%
% This is the single entry point for the modular HCC (hepatocellular carcinoma)
% clinical knowledge base. Load THIS file; it pulls in every module.
%
%   ?- [hcc_kb].
%   ?- help.
%
% -----------------------------------------------------------------------------
% MODULE MAP
% -----------------------------------------------------------------------------
%   sources.pl     Guideline registry + authority ranking + provenance helpers
%   ontology.pl    Module 1  -- Ontology (cancer types, morphology, subtypes,
%                              risk factors, molecular classes, genetics)
%   grading.pl     "Grading / Staging" -- differentiation, MVI, ECOG, Child-Pugh,
%                              ALBI, CNLC<->BCLC mapping, risk models, transplant
%                              criteria, PVTT typing
%   diagnosis.pl   Module 3  -- Diagnosis (screening, imaging, serum markers,
%                              pathways, biopsy, IHC, response, follow-up)
%   treatment.pl   Module 4  -- Treatment (staged roadmap, surgery, transplant,
%                              ablation, TACE/HAIC/TARE, RT, systemic, antiviral,
%                              TCM, PVTT mgmt, rupture, patient education)
%   evidence.pl    Module 2  -- Evidence system (levels, recommendation strength,
%                              trials, ESMO-MCBS, conflict_resolution)
%
% -----------------------------------------------------------------------------
% PROVENANCE CONVENTION  (this is how "every entry is sourced" is enforced)
% -----------------------------------------------------------------------------
%   The LAST argument of every clinical fact is:  src(Guidelines, Section)
%     - Guidelines : non-empty list of guideline codes; the FIRST element is the
%                    primary attributing guideline.   e.g. [nhc] , [nhc,caca,nccn]
%     - Section    : an atom locating the entry in the source document
%                    e.g. 'Ontology 1.1' , 'Treatment 4.2' , 'Conflict 2.4'
%
%   Guideline codes:  nhc  (NHC China 2026, PRIMARY AUTHORITY, rank 5)
%                     caca (CACA China 2026, rank 4)
%                     nccn (NCCN USA 2026, rank 3)
%                     esmo (ESMO Europe 2025, rank 3)
%
%   Two facts carry their meaning string in the last slot instead, and keep the
%   src in a companion fact (still fully enumerable):
%     sampling_method/1  <->  sampling_src/1
%     esmo_mcbs/3        <->  esmo_mcbs_src/1
%
% -----------------------------------------------------------------------------
% QUICK API  (see help/0 for the full list)
% -----------------------------------------------------------------------------
%   cite(Goal)                  pretty-print a matching fact + its source
%   source_of(Goal, Src)        unify Src with a fact's src(Guidelines,Section)
%   facts_from(Guideline)       list every fact attributed to a guideline code
%   modules                     list the loaded modules and their predicates
%   conflict(Topic)             show conflict_resolution entries (NHC ruling)
%   treatment_for(Stage)        treatment roadmap for a CNLC stage
%   staging(Stage)              CNLC stage definition + BCLC mapping
%   pathway_for(SizeDesc)       diagnostic pathway by nodule-size description
%   kb_stats                    count facts per module
% =============================================================================

:- use_module(sources).

% --- load every knowledge module into the user module (plain consult) --------
:- ensure_loaded(ontology).
:- ensure_loaded(grading).
:- ensure_loaded(diagnosis).
:- ensure_loaded(treatment).
:- ensure_loaded(evidence).

% kb_fact_predicate/2 is defined across all modules
:- multifile kb_fact_predicate/2.

:- discontiguous help/0.

% =============================================================================
% GENERIC PROVENANCE ENGINE
% =============================================================================

%% kb_goal(?Module, ?Name/?Arity, -Goal) is nondet.
%  Build a callable Goal (with fresh variables) for a registered fact predicate.
kb_goal(Module, Name/Arity, Goal) :-
    kb_fact_predicate(Module, Name/Arity),
    functor(Goal, Name, Arity).

%% last_arg(+Goal, -Last) is semidet.
last_arg(Goal, Last) :-
    Goal =.. [_|Args],
    Args \== [],
    last(Args, Last).

%% fact_with_source(-Goal, -Src) is nondet.
%  Enumerate every stored fact whose last argument is a src(_,_) term,
%  yielding the fact and its provenance. Facts whose last arg is not a
%  src term (sampling_method/1, esmo_mcbs/3) are skipped here -- their
%  provenance is reachable via their companion *_src fact, which IS picked up.
fact_with_source(Goal, Src) :-
    kb_goal(_Module, _PI, Goal),
    call(Goal),
    last_arg(Goal, Src),
    Src = src(_, _).

%% source_of(+Goal, -Src) is nondet.
%  For a (possibly partially instantiated) Goal matching a registered predicate,
%  unify Src with its provenance.
source_of(Goal, Src) :-
    callable(Goal),
    functor(Goal, Name, Arity),
    kb_fact_predicate(_, Name/Arity),
    call(Goal),
    last_arg(Goal, Src),
    Src = src(_, _).

% =============================================================================
% CITATION / PRETTY PRINTING
% =============================================================================

%% cite(+Goal) is det.
%  Print every solution of Goal together with a human-readable citation.
cite(Goal) :-
    ( \+ source_of(Goal, _)
    -> format("No sourced fact matches: ~q~n", [Goal])
    ;  forall(source_of(Goal, Src),
              ( cite_string(Src, S),
                format("~q~n    [~w]~n", [Goal, S]) ))
    ).

%% cite_string(+Src, -String) is det.
%  Render src([G1,G2,...], Section) as  "NHC China 2026 (+CACA,NCCN) | Section".
cite_string(src([Primary|Rest], Section), String) :-
    ( guideline_name(Primary, PName) -> true ; PName = Primary ),
    ( Rest == []
    -> Extra = ""
    ;  findall(U, ( member(C, Rest), upcase_atom(C, U) ), Us),
       atomic_list_concat(Us, ',', UJoined),
       format(atom(Extra), " (+~w)", [UJoined])
    ),
    format(atom(String), "~w~w | ~w", [PName, Extra, Section]).

% =============================================================================
% ENUMERATION BY SOURCE
% =============================================================================

%% facts_from(+Guideline) is det.
%  Print every fact that lists Guideline anywhere in its source list.
facts_from(Guideline) :-
    ( guideline_name(Guideline, GName) -> true ; GName = Guideline ),
    format("Facts citing ~w (~w):~n", [Guideline, GName]),
    ( forall(( fact_with_source(Goal, src(Gs, Sec)),
               memberchk(Guideline, Gs) ),
             format("  ~q   [~w]~n", [Goal, Sec]))
    -> true ; true ).

%% primary_facts_from(+Guideline) is det.
%  Only facts whose PRIMARY (first) attribution is Guideline.
primary_facts_from(Guideline) :-
    format("Facts PRIMARILY attributed to ~w:~n", [Guideline]),
    forall(( fact_with_source(Goal, src([Guideline|_], Sec)) ),
           format("  ~q   [~w]~n", [Goal, Sec])).

% =============================================================================
% STRUCTURE INTROSPECTION
% =============================================================================

%% modules is det.   List loaded modules and their registered predicates.
modules :-
    setof(M, P^kb_fact_predicate(M, P), Ms),
    forall(member(M, Ms),
           ( format("~n[~w]~n", [M]),
             forall(kb_fact_predicate(M, PI),
                    format("    ~w~n", [PI])) )).

%% kb_stats is det.   Count stored facts per module and in total.
kb_stats :-
    setof(M, P^kb_fact_predicate(M, P), Ms),
    format("~nFact counts per module:~n"),
    foldl(report_module_count, Ms, 0, Total),
    format("  ---------------------------~n  TOTAL: ~w facts~n", [Total]).

report_module_count(M, Acc, Acc1) :-
    aggregate_all(count, module_fact(M, _), N),
    format("  ~w~t~20|~w~n", [M, N]),
    Acc1 is Acc + N.

module_fact(M, Goal) :-
    kb_fact_predicate(M, Name/Arity),
    functor(Goal, Name, Arity),
    call(Goal).

% =============================================================================
% CROSS-MODULE CONVENIENCE QUERIES
% =============================================================================

%% conflict(+Topic) is det.
%  Show cross-guideline conflict resolution (NHC-anchored ruling). Topic may be
%  left unbound to list all.
conflict(Topic) :-
    ( var(Topic)
    -> format("All conflict-resolution entries (NHC = final authority):~n")
    ;  format("Conflict resolution for ~w:~n", [Topic])
    ),
    forall(conflict_resolution(Topic, Position, Rule, src(Gs, Sec)),
           ( atomic_list_concat(Gs, ',', GJ),
             format("  ~w~n    position : ~w~n    ruling   : ~w~n    sources  : [~w] ~w~n",
                    [Topic, Position, Rule, GJ, Sec]) )).

%% normalize_stage(+In, -Canonical) is det.
%  Map casual stage input (ia, IA, 'Ia', iiia ...) to the canonical CNLC atom
%  as stored ('Ia','Ib','IIa','IIb','IIIa','IIIb','IV'). Falls back to In.
normalize_stage(In, Canon) :-
    upcase_atom(In, Up),
    ( cnlc_canonical(Up, Canon) -> true ; Canon = In ).

cnlc_canonical('IA',   'Ia').
cnlc_canonical('IB',   'Ib').
cnlc_canonical('IIA',  'IIa').
cnlc_canonical('IIB',  'IIb').
cnlc_canonical('IIIA', 'IIIa').
cnlc_canonical('IIIB', 'IIIb').
cnlc_canonical('IV',   'IV').

%% treatment_for(+Stage) is det.
%  Treatment roadmap entries for a CNLC stage atom. Accepts ia / Ia / IA etc.
treatment_for(Stage0) :-
    normalize_stage(Stage0, Stage),
    format("Treatment options for CNLC stage ~w:~n", [Stage]),
    ( forall(stage_treatment(Stage, Line, Modality, Note, src(Gs, Sec)),
             ( atomic_list_concat(Gs, ',', GJ),
               format("  (~w) ~w~n      ~w~n      [~w ~w]~n",
                      [Line, Modality, Note, GJ, Sec]) ))
    -> true ; true ),
    ( stage_treatment(Stage, _, _, _, _) -> true
    ; format("  (no stage_treatment entries; check staging/1 for valid stages)~n") ).

%% staging(+Stage) is det.   CNLC stage definition + BCLC mapping. Accepts ia/Ia/IA.
staging(Stage0) :-
    normalize_stage(Stage0, Stage),
    ( cnlc_stage(Stage, Desc, src(Gs1, Sec1))
    -> atomic_list_concat(Gs1, ',', GJ1),
       format("CNLC ~w: ~w   [~w ~w]~n", [Stage, Desc, GJ1, Sec1])
    ;  format("No CNLC stage named ~w~n", [Stage])
    ),
    ( stage_mapping(Stage, Bclc, MapNote, src(Gs2, Sec2))
    -> atomic_list_concat(Gs2, ',', GJ2),
       format("  CNLC->BCLC: ~w   (~w)   [~w ~w]~n", [Bclc, MapNote, GJ2, Sec2])
    ;  true
    ).

%% pathway_for(+SizeDesc) is det.
%  Diagnostic pathway(s) matching a nodule size description substring.
pathway_for(SizeDesc) :-
    format("Diagnostic pathways matching \"~w\":~n", [SizeDesc]),
    ( forall(( diagnostic_pathway(Size, Imaging, Marker, Action, src(Gs, Sec)),
               sub_string_atom(Size, SizeDesc) ),
             ( atomic_list_concat(Gs, ',', GJ),
               format("  size: ~w~n    imaging: ~w~n    marker : ~w~n    action : ~w~n    [~w ~w]~n",
                      [Size, Imaging, Marker, Action, GJ, Sec]) ))
    -> true ; true ).

% case-insensitive substring test tolerant of atom/string
sub_string_atom(Hay, Needle) :-
    atom_string(Hay, HayS),
    atom_string(Needle, NeedleS),
    string_lower(HayS, HayL),
    string_lower(NeedleS, NeedleL),
    sub_string(HayL, _, _, _, NeedleL).

% =============================================================================
% HELP / DEMO
% =============================================================================

help :-
    format("~n=== HCC Knowledge Base -- query interface ===~n~n"),
    format("PROVENANCE~n"),
    format("  cite(Goal)             print matching fact(s) with readable citation~n"),
    format("  source_of(Goal, Src)   unify Src = src(Guidelines, Section)~n"),
    format("  fact_with_source(G,S)  enumerate every sourced fact~n~n"),
    format("BY SOURCE~n"),
    format("  facts_from(nhc)        facts citing a guideline (nhc|caca|nccn|esmo)~n"),
    format("  primary_facts_from(G)  facts whose PRIMARY attribution is G~n~n"),
    format("STRUCTURE~n"),
    format("  modules                list modules + their predicates~n"),
    format("  kb_stats               fact counts per module~n~n"),
    format("CLINICAL SHORTCUTS~n"),
    format("  staging(ia)            CNLC stage def + BCLC mapping~n"),
    format("  treatment_for(ia)      treatment roadmap for a CNLC stage~n"),
    format("  pathway_for('2 cm')    diagnostic pathway by nodule size~n"),
    format("  conflict(Topic)        cross-guideline conflict ruling (Topic var = all)~n~n"),
    format("EXAMPLES~n"),
    format("  ?- cite(cancer_type(hcc, Name, Pct, _)).~n"),
    format("  ?- facts_from(esmo).~n"),
    format("  ?- conflict(_).~n~n").

%% demo is det.   Run a short tour proving the interface works end-to-end.
demo :-
    format("~n----- DEMO 1: cite an ontology fact -----~n"),
    cite(cancer_type(hcc, _, _, _)),
    format("~n----- DEMO 2: staging + treatment for CNLC Ia (lowercase input accepted) -----~n"),
    ignore(staging(ia)),
    ignore(treatment_for(ia)),
    format("~n----- DEMO 3: a conflict-resolution ruling -----~n"),
    ignore(conflict(hbv_antiviral)),
    format("~n----- DEMO 4: fact counts -----~n"),
    kb_stats.

% -----------------------------------------------------------------------------
:- initialization((
       format("~nHCC knowledge base loaded. Type  help.  for the query interface.~n")
   )).
