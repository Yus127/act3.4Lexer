%Programa que recibe lee un archivo en lenguaje c (.c) y resalta las categorías léxicas en un HTML
%Yusdivia Molina Román A01653120
%Lidia Paola Díaz Ramírez A01369117
%Fecha de modificación: 16/04/2021

-module(main).
-export([corre/0,loop3/0]).

%corre() -> timer:tc(?MODULE, principal, [["a","b","c"]]).
corre() -> principal(["a","b","c"]).

%Función principal, recibe el nombre del archivo por leer y escribe la salida sobre "salida.html", usa el archivo "header.html" como base
scan([]) -> ok;
scan([H|T]) ->
  %{ok} = file:cd(Dir),
  {ok, Content} = file:read_file(filename:join([H, "main.c"])),
  Lst = binary_to_list(Content),
  {ok, Lst2, _} = lexer:string(Lst),
  {ok,Device2} = file:open(filename:join([H, "salida.html"]), write),
  {ok, Content2} = file:read_file("header.html"),
  io:format(Device2, "~s", [binary_to_list(Content2)]),
  io:format(Device2,"~s~n", ["<body>"]),
  write(Lst2, Device2),
  io:format(Device2,"~n~s~n~s~n", ["</body>", "</html>"]),
  file:close(Device2),
  scan(T).

principal([])-> ok;
principal([H|T])->
  Pid = spawn(?MODULE,loop3,[]),
  Pid ! {sumado, self(), H},
  principal(T).

loop3() ->
  receive
    {sumado, Pid, FileN} ->
    {ok, Content} = file:read_file(filename:join([FileN, "main.c"])),
    Lst = binary_to_list(Content),
    {ok, Lst2, _} = lexer:string(Lst),
    {ok,Device2} = file:open(filename:join([FileN, "salida.html"]), write),
    {ok, Content2} = file:read_file("header.html"),
    io:format(Device2, "~s", [binary_to_list(Content2)]),
    io:format(Device2,"~s~n", ["<body>"]),
    write(Lst2, Device2),
    io:format(Device2,"~n~s~n~s~n", ["</body>", "</html>"]),
    file:close(Device2)
    end.


%Función de apoyo para scan, se encarga de escribir sobre el archivo dado
write([], _) -> true;
write([H | T], Device2) ->
  {_, Str, _} = H,
  io:format(Device2, "~s", [Str]), write(T, Device2).
