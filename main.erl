%Programa que recibe lee un archivo en lenguaje c (.c) y resalta las categorías léxicas en un HTML
%Yusdivia Molina Román A01653120
%Lidia Paola Díaz Ramírez A01369117
%Fecha de modificación: /2021

-module(main).
-export([paralela/1, loop3/0, reunir/1, principal/2, secuencial/1, scan/1]).

paralela(L) -> timer:tc(?MODULE, principal, [L,length(L)]).
secuencial(L) -> timer:tc(?MODULE, scan, [L]).

%Función que manda los treads según el número de carpetas por analizar, recibe la lista de carpetas y su longitud.
principal([],N)-> reunir(N);
principal([H|T],N)->
  Pid = spawn(?MODULE,loop3,[]),
  Pid ! {sumado, self(), H},
  principal(T,N).

%Función de apoyo que lee los .c y genera los html con el resaltado
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

%Función final que revisa que todos los hilos ya hayan terminado su ejecución
  reunir(0) -> 0;
  reunir(N) ->
      receive
        {listo} ->
          reunir(N-1)
    end.

%Función para hacer la lectura y escritura de los archivos de forma secuencial
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


%Función de apoyo para scan y loop3, se encarga de escribir sobre el archivo dado
write([], _) -> true;
write([H | T], Device2) ->
  {_, Str, _} = H,
  io:format(Device2, "~s", [Str]), write(T, Device2).
