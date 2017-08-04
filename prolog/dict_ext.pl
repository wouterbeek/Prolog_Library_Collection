:- module(
  dict_ext,
  [
    dict_delete_or_default/5, % +Key, +Dict1, +Default, -Value, -Dict2
    dict_get/3,               % ?Key, +Dict, -Value
    dict_get/4,               % +Key, +Dict, +Default, -Value
    dict_inc/2,               % +Key, +Dict
    dict_inc/3,               % +Key, +Dict, -Value
    dict_inc/4,               % +Key, +Dict, +Diff, -Value
    dict_key/2,               % +Dict, ?Key
    dict_pairs/2,             % ?Dict, ?Pairs
    dict_put/3,               % +Dict1, +Dict2, -Dict3
    dict_put/4,               % +Key, +Dict1, +Value, -Dict2
    dict_tag/2,               % +Dict, ?Tag
    merge_dicts/3             % +Dict1, +Dict2, -Dict3
  ]
).

/** <module> Dictionary extension

@author Wouter Beek
@version 2017/04-2017/07
*/

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).





%! dict_delete_or_default(+Key, +Dict1, +Default, -Value, -Dict2) is det.
%
% Either delete the Value for Key from Dict1 resulting in Dict2, or
% return the Default value and leave the dictionary unchanged.

dict_delete_or_default(Key, Dict1, _, Value, Dict2) :-
  del_dict(Key, Dict1, Value, Dict2), !.
dict_delete_or_default(_, Dict, Default, Default, Dict).



%! dict_get(?Key, +Dict, -Value) is nondet.

dict_get(Key, Dict, Value) :-
  get_dict(Key, Dict, Value).



%! dict_get(+Key, +Dict, +Default, -Value) is semidet.

dict_get(Key, Dict, _, Value) :-
  get_dict(Key, Dict, Value), !.
dict_get(_, _, Default, Default).



%! dict_inc(+Key, +Dict) is det.
%! dict_inc(+Key, +Dict, -Value) is det.
%! dict_inc(+Key, +Dict, +Diff, -Value) is det.

dict_inc(Key, Dict) :-
  dict_inc(Key, Dict, _).


dict_inc(Key, Dict, Value) :-
  dict_inc(Key, Dict, 1, Value).


dict_inc(Key, Dict, Diff, Value2) :-
  get_dict(Key, Dict, Value1),
  Value2 is Value1 + Diff,
  nb_set_dict(Key, Dict, Value2).



%! dict_key(+Dict, +Key) is semidet.
%! dict_key(+Dict, -Key) is nondet.

dict_key(Dict, Key) :-
  dict_get(Key, Dict, _).



%! dict_pairs(+Dict, +Pairs) is semidet.
%! dict_pairs(+Dict, -Pairs) is det.
%! dict_pairs(-Dict, +Pairs) is det.

dict_pairs(Dict, Pairs):-
  dict_pairs(Dict, _, Pairs).



%! dict_put(+Dict1, +Dict2, -Dict3) is det.

dict_put(Dict1, Dict2, Dict3) :-
  Dict3 = Dict1.put(Dict2).



%! dict_put(+Key, +DictIn, +Value, -DictOut) is det.

dict_put(Key, Dict1, Value, Dict2) :-
  put_dict(Key, Dict1, Value, Dict2).



%! dict_tag(+Dict, +Tag) is semidet.
%! dict_tag(+Dict, -Tag) is det.

dict_tag(Dict, Tag) :-
  dict_pairs(Dict, Tag, _).



%! merge_dicts(+NewDict, +OldDict, -Dict) is det.
%
% Merges two dictionaries into one new dictionary, similar to
% merge_options/3 from library(option).
%
% If NewDict and OldDict contain the same key then the value from
% NewDict is used.

merge_dicts(NewDict, OldDict, Dict):-
  dict_pairs(NewDict, Tag, NewPairs),
  dict_pairs(OldDict, Tag, OldPairs),
  pairs_keys(NewPairs, NewKeys),
  exclude(key_in_keys0(NewKeys), OldPairs, OnlyOldPairs),
  append(OnlyOldPairs, NewPairs, Pairs),
  dict_pairs(Dict, Tag, Pairs).

key_in_keys0(Keys, Key-_) :-
  memberchk(Key, Keys).
