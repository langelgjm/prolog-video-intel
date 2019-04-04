:- use_module(video_intelligence).


:- begin_tests(struct_path).

test(struct_path) :-
    Input = _{
        annotation_results: [
            _{
                input_uri: "/foo/bar/baz",
                foo: bar
            },
            2
        ]
    },
    struct_path(Input, Path),
    Path = "baz".

:- end_tests(struct_path).