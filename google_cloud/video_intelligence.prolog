:- module(libjson, [clip_template/3, map_transform/3, struct_path/2]).

:- use_module(library(http/json)).
:- use_module(library(uri)).
:- use_module(library(open_dicts)).

:- use_module('../libhtml').


struct_path(Struct, Path) :-
    Struct = _{
        annotation_results: [
            _{
                input_uri: InputUri
            }+ | _ ]
    }+,
    split_string(InputUri, "/", "", PathComponents),
    last(PathComponents, Path).


% define templates of the JSON objects we wish to match, and specify the values we wish to extract
clip_template(Template, Start, End) :-
    Template = _{
        segment: _{
            start_time_offset: _{
                seconds: StartSeconds, nanos: StartNanos
            },
            end_time_offset: _{
                seconds: EndSeconds, nanos: EndNanos
            }
        }
    }+,
    Start = StartSeconds + StartNanos / 1e9,
    End = EndSeconds + EndNanos / 1e9.
% clip_template(Template, Start, -1) :-  % this won't work as-is
%     Template = _{
%         segment: _{
%             start_time_offset: _{
%                 seconds: StartSeconds, nanos: StartNanos
%             },
%             end_time_offset: _{}
%         }
%     }+,
%     Start = StartSeconds + StartNanos / 1e9.
% clip_template(Template, End, 0) :-
%     Template = _{
%         segment: _{
%             start_time_offset: _{},
%             end_time_offset: _{
%                 seconds: EndSeconds, nanos: EndNanos
%             }
%         }
%     }+,
%     End = EndSeconds + EndNanos / 1e9.

% Describe a relation between a dictionary we wish to transform, and its transformation
template_transform(In, Out, _) :- 
    clip_template(Template, _, _),
    dif(In, Template),
    In = Out.
template_transform(In, Out, Constant) :- 
    clip_template(Template, Start, End),
    In = Template,
    uri_encoded(path, Constant, UriEncodedConstant),
    format(string(Link), "http://127.0.0.1:8000/thumbnails?path=~w&start=~f&end=~f", [UriEncodedConstant, Start, End]),
    put_dict(link, In, Link, Out).

non_iterable_json_type(Var) :-
    string(Var) ; number(Var) ; atom(Var) -> true.

% Base case
map_transform(_, In, Out) :-
    non_iterable_json_type(In),
    In = Out.
% Empty list
map_transform(_, [], []).
% Empty dict
map_transform(_, _{}, _{}).
% Key-Value pair
map_transform(Constant, In, Out) :-
    Key-Value = In,
    map_transform(Constant, Value, OutValue),
    Out = Key-OutValue.
% A dict whose transform is different than itself
map_transform(Constant, In, Out) :-
    is_dict(In),
    template_transform(In, Out, Constant),
    dif(In, Out).
% A dict whose transform is the same as itself
map_transform(Constant, In, Out) :-
    is_dict(In),
    template_transform(In, In, _),
    dict_pairs(In, _, Pairs),
    maplist(map_transform(Constant), Pairs, OutPairs),
    dict_pairs(Out, _, OutPairs).
% Non-empty list
map_transform(Constant, In, Out) :-
    maplist(map_transform(Constant), In, Out).