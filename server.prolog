:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_unix_daemon)).

:- use_module(libhtml).


% sample structs
struct(X) :- X = [1, 2, 3].
struct(X) :- X = _{a: 1, b: 2, c: 3}.
struct(X) :- X = [a, [b, [c]]].
struct(X) :- X = _{a: _{b: _{c: d}}}.
struct(X) :- X = [_{a: b}].
struct(X) :- X = _{a: [b]}.
struct(X) :- X = _{a: [1, _{a: 1}]}.
struct(X) :- X = [1, _{a: [1]}].
struct(X) :- X = ["http://list_item_link", _{key: "http://object_value_item_link"}].

html_struct(Request) :-
    member(method(get), Request),
    findall(Struct, struct(Struct), Structs),
    findall(Html, (member(Elem, Structs), struct_to_html(Elem, Html)), All),
    reply_html_page([title('Sample JSON <-> HTML Relations')], All).
html_struct(Request) :-
    member(method(post), Request),
    http_read_json_dict(Request, Json, []),
    struct_to_html(Json, Html),
    reply_html_page([title('Json <-> HTML')], Html).

thumbnails(Request) :-
    member(method(get), Request),
    http_parameters(Request, [
            path(Path, [string]),
            start(Start, [number]),
            end(End, [number])
        ]
    ),
    generate_thumbs(Path, Start, End, Thumbnails),
    http_reply_file(Thumbnails, [unsafe(true)], Request),
    delete_file(Thumbnails).

:- http_handler('/html_struct', html_struct, []).
:- http_handler('/thumbnails', thumbnails, []).

:- initialization(http_daemon).
