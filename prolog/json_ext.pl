:- module(
  json_ext,
  [
    atom_json_dict/2, % ?A, ?D
    atomize_json/2,   % +D, -AtomizedD
    json_read_any/2,  % +Source, -D
    json_read_any/3,  % +Source, -D, +Opts
    json_write_any/2, % +Sink,   +D
    json_write_any/3  % +Sink,   +D, +Opts
  ]
).

/** <module> JSON extensions

@author Wouter Beek
@version 2015/09-2015/11, 2016/01, 2016/03-2016/04
*/

:- use_module(library(apply)).
:- use_module(library(dict_ext)).
:- use_module(library(http/json)).
:- use_module(library(os/open_any2)).
:- use_module(library(yall)).





%! atom_json_dict(+A, -D) is det.
%! atom_json_dict(-A, +D) is det.

atom_json_dict(A, D) :-
  atom_json_dict(A, D, []).



%! atomize_json(+D, -AtomizedD) is det.

atomize_json(L1, L2):-
  is_list(L1), !,
  maplist(atomize_json, L1, L2).
atomize_json(D1, D2):-
  atomize_dict(D1, D2).



%! json_read_any(+Source, -D) is det.
%! json_read_any(+Source, -D, +Opts) is det.
% Read JSON from any source.

json_read_any(Source, D):-
  json_read_any(Source, D, []).


json_read_any(Source, D, Opts):-
  call_on_stream(Source, [In,_,_]>>json_read_dict(In, D, Opts), Opts).



%! json_write_any(+Sink, -D) is det.
%! json_write_any(+Sink, -D, +Opts) is det.
% Write JSON to any sink.

json_write_any(Sink, D):-
  json_write_any(Sink, D, []).


json_write_any(Sink, D, Opts):-
  call_to_stream(Sink, [Out,_,_]>>json_write_dict(Out, D, Opts), Opts).
