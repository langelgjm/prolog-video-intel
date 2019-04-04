:- use_module(libjson).

:- begin_tests(template).

test(template_link) :-
    Unlinked = _{startOffset: "1s", endOffset: "2s", foo: bar},
    template('foobar', Unlinked, Linked),
    Linked = _{startOffset: "1s", endOffset: "2s", foo: bar, link: "http://127.0.0.1:8000/thumbnails?path=foobar&start=1&end=2"}.

test(template_link) :-
    Unlinked = _{foo: bar},
    template('foobar', Unlinked, Linked),
    Linked = _{foo: bar}.

:- end_tests(template).


:- begin_tests(map_template).

test(map_template) :-
    Old = [_{startOffset: "1s", endOffset: "2s", foo: bar}],
    map_template(Old, New),
    New = [_{startOffset: "1s", endOffset: "2s", foo: bar, link: "http://127.0.0.1:8000/thumbnails?path=foobar&start=1&end=2"}].

test(map_template) :-
    Old = [
        _{startOffset: "1s", endOffset: "2s", foo: bar},
        _{startOffset: "3s", endOffset: "4s", foo: bar},
        _{foo: bar}
    ],
    map_template(Old, New),
    New = [
        _{startOffset: "1s", endOffset: "2s", foo: bar, link: "http://127.0.0.1:8000/thumbnails?path=foobar&start=1&end=2"},
        _{startOffset: "3s", endOffset: "4s", foo: bar, link: "http://127.0.0.1:8000/thumbnails?path=foobar&start=3&end=4"},
        _{foo: bar}
    ].

test(map_template) :-
        Old = _{a: _{foo: bar}},
        map_template(Old, New),
        New = _{a: _{foo: bar}}.

test(map_template) :-
    Old = _{a: _{startOffset: "1s", endOffset: "2s", foo: bar}},
    map_template(Old, New),
    New = _{a: _{startOffset: "1s", endOffset: "2s", foo: bar, link: "http://127.0.0.1:8000/thumbnails?path=foobar&start=1&end=2"}}.


test(map_template) :-
    Old = _{
        a: _{startOffset: "1s", endOffset: "2s", foo: bar},
        b: _{startOffset: "3s", endOffset: "4s", foo: bar},
        c: _{foo: bar}
    },
    map_template(Old, New),
    New = _{
        a: _{startOffset: "1s", endOffset: "2s", foo: bar, link: "http://127.0.0.1:8000/thumbnails?path=foobar&start=1&end=2"},
        b: _{startOffset: "3s", endOffset: "4s", foo: bar, link: "http://127.0.0.1:8000/thumbnails?path=foobar&start=3&end=4"},
        c: _{foo: bar}
    }.

:- end_tests(map_template).
