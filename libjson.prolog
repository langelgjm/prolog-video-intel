:- module(libjson, [template/3, map_template/2]).

:- use_module(library(http/json)).
:- use_module(library(uri)).
:- use_module(library(open_dicts)).


% Describe a relation between a dictionary we wish to transform, and its transformation
template(_, Unlinked, Linked) :- 
    dif(Unlinked, _{startOffset: _, endOffset: _}+),
    Linked = Unlinked.
template(Path, Unlinked, Linked) :- 
    Unlinked = _{startOffset: StartString, endOffset: EndString}+,
    % these next two predicates are sufficient for this template to establish a terminal case
    string_concat(Start, "s", StartString),
    string_concat(End, "s", EndString),
    uri_encoded(path, Path, EncodedPath),
    format(string(Link), "http://127.0.0.1:8000/thumbnails?path=~w&start=~w&end=~w", [EncodedPath, Start, End]),
    put_dict(link, Unlinked, Link, Linked).

non_iterable_json_type(Var) :-
    string(Var) ; number(Var) ; atom(Var) -> true.

% base case
map_template(Old, New) :-
    non_iterable_json_type(Old),
    Old = New.
% Key-Value pair
map_template(Pair, NewPair) :-
    Key-Value = Pair,
    map_template(Value, NewValue),
    NewPair = Key-NewValue.
% Empty list
map_template([], []).
% Empty dict
map_template(_{}, _{}).
% A dict whose transformation is different than itself
map_template(Old, New) :-
    is_dict(Old),
    template('foobar', Old, New),
    dif(Old, New).
% A dict whose transformation is the same as itself
map_template(Old, New) :-
    is_dict(Old),
    template('foobar', Old, Unchanged),
    Old = Unchanged,
    dict_pairs(Unchanged, _, Pairs),
    maplist(map_template, Pairs, NewPairs),
    dict_pairs(New, _, NewPairs).
% Non-empty list
map_template(Old, New) :-
    [H|T] = Old,
    map_template(H, Nh),
    map_template(T, Nt),
    New = [Nh|Nt].