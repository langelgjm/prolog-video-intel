:- module(libvid, [generate_thumbs/4]).

% call an external program to generate Thumbnails of the video at Path, between Start and End seconds
generate_thumbs(Path, Start, End, Thumbnails) :-
    EndOffset is End - Start,
    process_create('./generate_thumbs.sh', [Path, Start, EndOffset], [stdout(pipe(Stream))]), read_string(Stream, "\n", "\n", _, Thumbnails).