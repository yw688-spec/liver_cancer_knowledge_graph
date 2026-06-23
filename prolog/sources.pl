% =====================================================================
%  sources.pl  --  Guideline source registry & provenance backbone
% ---------------------------------------------------------------------
%  HCC Integrated Clinical Knowledge Base (built from modular-knowledge v4.0)
%
%  PROVENANCE CONVENTION (applies to EVERY clinical fact in this KB):
%    The LAST argument of every knowledge fact is a term:
%
%        src(Guidelines, Section)
%
%    - Guidelines : non-empty list of guideline codes, e.g. [nhc],
%                   [nhc,caca,nccn]. The FIRST element is the primary
%                   attributing guideline.
%    - Section    : atom giving the document location, e.g. 'Ontology 1.1'.
%
%  This uniform rule lets the integration layer cite any fact's source
%  and enumerate every fact originating from a given guideline.
% =====================================================================

:- module(sources,
          [ guideline/5, authority_rank/2, guideline_name/2,
            higher_authority/2, src_guidelines/2, src_section/2,
            primary_source/2 ]).

% guideline(Code, ShortName, FullName, Version, Role)
guideline(nhc,  'NHC',  'National Health Commission of China',         2026, primary_authority).
guideline(caca, 'CACA', 'China Anti-Cancer Association',               2026, china_supplement).
guideline(nccn, 'NCCN', 'National Comprehensive Cancer Network (USA)', 2026, western_reference).
guideline(esmo, 'ESMO', 'European Society for Medical Oncology',       2025, western_reference).

% authority_rank(Code, Rank) -- higher rank wins on conflict.
% NHC 2026 is the final authority for all rules (v4 core principle).
authority_rank(nhc,  5).
authority_rank(caca, 4).
authority_rank(nccn, 3).
authority_rank(esmo, 3).

guideline_name(Code, Full) :- guideline(Code, _, Full, _, _).

% higher_authority(A, B): guideline A outranks guideline B.
higher_authority(A, B) :-
    authority_rank(A, Ra), authority_rank(B, Rb), Ra > Rb.

% Helpers to read a src/2 provenance term.
src_guidelines(src(Gs, _), Gs).
src_section(src(_, Section), Section).
primary_source(src([G|_], _), G).
