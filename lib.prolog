:- module(lib, [struct_to_html/2, transform_struct/2, generate_thumbs/4]).

:- use_module(library(http/json)).


wrap(Html, Wrapped) :-
    li(_) = Html,
    Wrapped = Html.
wrap(Html, Wrapped) :-
    li(_) \= Html,
    Wrapped = li(Html).

% items that are strings beginning with http:// should be made into links
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


% this need to bind in the "Rest" of the dict that is not selected
struct_offset_link(Struct, NewAnnotations) :-
    select_dict(_{inputUri: InputUri, segmentLabelAnnotations: Annotations}, Struct, _),
    member(Annotation, Annotations),
    select_dict(_{segments: Segments}, Annotation, _),
    member(Segment, Segments),
    select_dict(_{segment: SegmentDescription}, Segment, _),
    select_dict(_{startTimeOffset: StartTimeOffset, endTimeOffset: EndTimeOffset}, SegmentDescription, _),
    string_concat(Start, "s", StartTimeOffset),
    string_concat(End, "s", EndTimeOffset),
    format(atom(Link), 'http://127.0.0.1:8000/thumbnails?path=~w&start=~w&end=~w', [InputUri, Start, End]),
    findall(_{segment: NewSegmentDescription}, put_dict(thumbNails, SegmentDescription, Link, NewSegmentDescription), NewSegments),
    findall(NewAnnotation, put_dict(_{segments: NewSegments}, _{}, NewAnnotation), NewAnnotations).


transform_struct(Struct, NewStruct) :-
    select_dict(_{inputUri: InputUri}, Struct, _),
    findall(NewAnnotations, struct_offset_link(Struct, NewAnnotations), Annotations),
    NewStruct = _{inputUri: InputUri, segmentLabelAnnotations: Annotations}.


% call an external program to generate Thumbnails of the video at Path, between Start and End seconds
generate_thumbs(Path, Start, End, Thumbnails) :-
    EndOffset is End - Start,
    process_create('./generate_thumbs.sh', [Path, Start, EndOffset], [stdout(pipe(Stream))]), read_string(Stream, "\n", "\n", _, Thumbnails).
