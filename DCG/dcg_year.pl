:- module(
  dcg_year,
  [
    year//2, % ?Lang:atom
             % ?Year:oneof([integer,pair(integer)])
    year_point//2, % ?Lang:atom
                   % ?Year:integer
    year_interval//2 % ?Lang:atom
                     % ?Interval:pair(integer)
  ]
).

/** <module> DCG_YEAR

DCGs for parsing/generating year information.

@author Wouter Beek
@version 2013/05
*/

:- use_module(dcg(dcg_ascii)).
:- use_module(dcg(dcg_century)).
:- use_module(dcg(dcg_generic)).
:- use_module(library(dcg/basics)).



pre(en) --> "after".
pre(en) --> "before".
pre(nl) --> "na".
pre(nl) --> "voor".
pre(nl) --> "vóór".

question_marks(1) -->
  question_mark.
question_marks(N) -->
  question_mark,
  question_marks(M),
  {N is M + 1}.

xs(1) -->
  x.
xs(N) -->
  x,
  xs(M),
  {N is M + 1}.

% Between round brackets.
year(Lang, Year) -->
  opening_bracket,
  year(Lang, Year),
  closing_bracket.
year(Lang, Year) -->
  year_point(Lang, Year).
year(Lang, Interval) -->
  year_interval(Lang, Interval).
year(Lang, Year) -->
  pre(Lang), blank,
  year(Lang, Year).

%! year_interval(?Lang:atom, ?Interval:pair(integer))//
% A year interval, i.e. an interval delimited by a first and a last year.
%
% Note that the meaning of uncertainty notation can be context-dependent.
% For example =|1917-19??|= means =|1917-1999|=,
% whereas =|19??-1917|= means =|1900-1917|=.

year_interval(Lang, Year1-Year2) -->
  year_point(Lang, Year1),
  year_separator,
  year_point(Lang, Year2).
year_interval(Lang, Year11-Year2) -->
  year_uncertainty(Year11-_Year12),
  year_separator,
  year_point(Lang, Year2).
year_interval(Lang, Year1-Year22) -->
  year_point(Lang, Year1),
  year_separator,
  year_uncertainty(_Year21-Year22).
year_interval(Lang, Interval) -->
  century_interval(Lang, Interval).
year_interval(_Lang, Interval) -->
  year_uncertainty(Interval).
% Example: 'tussen 1608 en 1618' means '1608-1618'.
year_interval(Lang, Year1-Year2) -->
  year_interval_preposition(Lang), blank,
  year_point(Lang, Year1), blanks,
  conj(Lang), blank,
  year_point(Lang, Year2).
% Example: 'tussen 1530/1545' means '1530-1545'.
year_interval(Lang, Interval) -->
  year_interval_preposition(Lang), blanks,
  year_interval(Lang, Interval).
year_interval(Lang, Year1-Year2) -->
  year_point(Lang, Year1), blank,
  disj(Lang), blank,
  year_point(Lang, Year2).

year_interval_preposition(en) --> "between".
year_interval_preposition(nl) --> "tussen".

year_point(_Lang, Year) -->
  integer(Year).
% Uncertainty w.r.t. the end of an interval.
% Open interval interpreted as a single year.
year_point(Lang, Year) -->
  integer(Year),
  year_separator,
  uncertainty(Lang).
year_point(Lang, Year) -->
  uncertainty(Lang),
  blanks,
  year_point(Lang, Year).
year_point(_Lang, Year) -->
  integer(Year),
  year_separator.

year_separator -->
  blank,
  year_separator,
  blank.
year_separator --> equals_sign.
year_separator --> forward_slash.
year_separator --> hyphen_minus.

% Uncertainty widening, e.g. 19?? means 1900-1999.
year_uncertainty(Year1-Year2) -->
  digits(Ds),
  {Ds \== []},
  (question_marks(N) ; xs(N)),
  {number_codes(X, Ds)},
  {Multiplier is 10**N},
  {Year1 is X * Multiplier},
  {Y is X + 1},
  {Z is Y * Multiplier},
  {Year2 is Z - 1}.

