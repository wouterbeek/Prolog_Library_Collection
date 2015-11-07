:- module(
  dcg_pl,
  [
    pl_pair//1, % +Pair:pair
    pl_pair//2, % :Name_2
                % :Value_2
    pl_predicate//1, % +Predicate:compound
    pl_stream_position//1, % +Stream:compound
    pl_term//1, % @Term
    pl_term//2 % @Term
               % +Indent:nonneg
  ]
).

/** <module> DCG Prolog term

DCG rules for printing SWI-Prolog 7 terms.

@author Wouter Beek
@version 2015/08, 2015/10-2015/11
*/

:- use_module(library(dcg/basics)).
:- use_module(library(dcg/dcg_bracketed)).
:- use_module(library(dcg/dcg_call)).
:- use_module(library(dcg/dcg_cardinal)).
:- use_module(library(dcg/dcg_collection)).
:- use_module(library(dcg/dcg_content)).
:- use_module(library(dcg/dcg_unicode)).
:- use_module(library(pl/pl_term)).

:- meta_predicate(pl_pair(//,//,?,?)).
:- meta_predicate(term_entries(4,+,+,?,?)).





%! pl_pair(+Pair:pair)// is det.

pl_pair(N-V) -->
  pl_pair(pl_term(N), pl_term(V)).


%! pl_pair(:Name_2, :Value_2)// is det.

pl_pair(N_2, V_2) -->
  N_2,
  "-",
  V_2.



%! pl_predicate(+Predicate:compound)// is det.

pl_predicate(Mod:PredLet/Arity) -->
  atom(Mod),
  ":",
  atom(PredLet),
  "/",
  integer(Arity).



%! pl_stream_position(+Position:compound)// is det.

pl_stream_position(stream(_,Row,Col,_)) -->
  "[",
  row(Row),
  ", ",
  column(Col),
  "]".

row(N) -->
  "Row: ",
  thousands_integer(N).

column(N) -->
  "Col: ",
  thousands_integer(N).



%! pl_term(@Term)// is det.
% Wrapper around pl_term//2 with no indentation.

pl_term(Term) -->
  pl_term(Term, 0).


%! pl_term(@Term, +Indent:nonneg)// is det.

% 1. Dictionary.
pl_term(Dict, I1) -->
  {is_dict(Dict), dict_pairs(Dict, _, Pairs)}, !,
  % The empty dictionary does not use lusious spacing.
  (   {Pairs == []}
  ->  indent(I1, bracketed(curly, dcg_void))
  ;   indent(I1, opening_curly_bracket),
      nl,
      {I2 is I1 + 1},
      term_entries(dict_entry, Pairs, I2),
      indent(I1, closing_curly_bracket)
  ).
% 2. List.
% The empty list and singleton lists do not use lusious spacing.
pl_term(List, I1) -->
  {is_list(List)}, !,
  (   {length(List, Length), Length =< 1}
  ->  indent(I1, list(List))
  ;   indent(I1, opening_square_bracket),
      nl,
      {I2 is I1 + 1},
      term_entries(pl_term, List, I2),
      indent(I1, closing_square_bracket)
  ).
% 3. Other term.
pl_term(Term, I) -->
  indent(I, nondict(Term)).


%! term_entries(:Dcg_4, +Entries:list, +Indent:nonneg)// is det.

term_entries(_, [], _) --> !, "".
term_entries(Dcg_4, [H], I) --> !,
  dcg_call(Dcg_4, H, I),
  nl.
term_entries(Dcg_4, [H|T], I) -->
  dcg_call(Dcg_4, H, I),
  ",",
  nl,
  term_entries(Dcg_4, T, I).


%! dict_entry(+Pair:pair, +Indent:nonneg)// is det.

dict_entry(Key-Val, I1) -->
  indent(I1, nondict(Key)),
  ": ",
  % Newline and additional indentation before dictionary or list values
  % that contain more that one entry.
  {(  is_dict(Val)
  ->  dict_pairs(Val, _, Pairs),
      length(Pairs, Length)
  ;   is_list(Val)
  ->  length(Val, Length)
  ;   Length = 1
  )},
  ({Length > 1} -> {I2 is I1 + 1}, nl ; {I2 = 0}),
  pl_term(Val, I2).


%! nondict(@Term)// is det.

nondict(T) -->
  {with_output_to(codes(Cs), write_term(T))},
  Cs.
