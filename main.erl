%Programa que recibe lee un archivo en lenguaje c (.c) y resalta las categorías léxicas en un HTML
%Yusdivia Molina Román A01653120
%Lidia Paola Díaz Ramírez A01369117
%Fecha de modificación: /2021

-module(main).
<<<<<<< Updated upstream
-export([corre/0,loop3/0, reunir/1, principal/2]).
=======
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
-export([scan/1,corre/0]).

corre() -> timer:tc(?MODULE, scan, [["a","b","c"]]).

%Función principal, recibe el nombre del archivo por leer y escribe la salida sobre "salida.html", usa el archivo "header.html" como base
scan([]) -> 0;
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
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
-export([corre/0,loop3/0, reunir/1, principal/2, corre2/0,scan/1]).
>>>>>>> Stashed changes

corre() -> timer:tc(?MODULE, principal, [["a","b","c"],3]).
%corre() -> principal(["a","b","c"],3).

principal([],N)-> reunir(N);
principal([H|T],N)->
  Pid = spawn(?MODULE,loop3,[]),
  Pid ! {sumado, self(), H},
  principal(T,N).

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
    file:close(Device2),
    Pid ! {listo}
    end.

  reunir(0) -> 0;
  reunir(N) ->
      receive
        {listo} ->
          reunir(N-1)
    end.

<<<<<<< Updated upstream

%Función de apoyo para scan, se encarga de escribir sobre el archivo dado
=======
  scan([]) -> 0;
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes


=======


>>>>>>> Stashed changes
=======


>>>>>>> Stashed changes
%Función de apoyo para scan y loop3, se encarga de escribir sobre el archivo dado
>>>>>>> Stashed changes
write([], _) -> true;
write([H | T], Device2) ->
  {_, Str, _} = H,
  io:format(Device2, "~s", [Str]), write(T, Device2).
