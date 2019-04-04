:- module(libhtml, [struct_to_html/2]).

:- use_module(library(http/json)).


wrap(Html, Wrapped) :-
    li(_) = Html,
    Wrapped = Html.
wrap(Html, Wrapped) :-
    li(_) \= Html,
    Wrapped = li(Html).

% items that are strings beginning with http should be made into links
make_link(Item, Html) :-
    string_concat('http', _, Item),
    Html = a(href=Item, Item).
make_link(Item, Html) :-
    \+ string_concat('http', _, Item),
    Html = Item.

% base case for terminal item in a list, or value of a key-value pair
struct_to_html(Item, Html) :-
    _-_ \= Item,
    \+ is_list(Item),
    \+ is_dict(Item),
    make_link(Item, NewItem),
    Html = li(NewItem).
% key-value pair whose value is a terminal item
struct_to_html(Pair, Html) :-
    Key-Value = Pair,
    \+ is_list(Value),
    \+ is_dict(Value),
    struct_to_html(Value, InnerHtml),
    Html = li([i(Key), ul([InnerHtml])]).
% key-value pair whose value is a dict
struct_to_html(Pair, Html) :-
    Key-Value = Pair,
    is_dict(Value),
    struct_to_html(Value, InnerHtml),
    Html = li([i(Key), InnerHtml]).
% key-value pair whose value is a list
struct_to_html(Pair, Html) :-
    Key-Value = Pair,
    is_list(Value),
    struct_to_html(Value, InnerHtml),
    Html = li([i(Key), ul(li([InnerHtml]))]).
% recursive case for a list
struct_to_html(List, Html) :-
    is_list(List),
    maplist(struct_to_html, List, InnerHtml),
    maplist(wrap, InnerHtml, WrappedHtml),
    Html = ol(WrappedHtml).
% recursive case for a dict
struct_to_html(Dict, Html) :-
    is_dict(Dict),
    dict_pairs(Dict, _, Pairs),
    maplist(struct_to_html, Pairs, InnerHtml),
    Html = ul(InnerHtml).