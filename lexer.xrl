
%Archivo donde se definen las categorías léxicas del lenguaje C
%Yusdivia Molina Román A01653120
%Lidia Paola Díaz Ramírez A01369117
%Fecha de modificación: 16/04/2021

Definitions.
%Definición general de dígitos, números y cualquier caracter para luego usarlas
Digit	= [0-9]
Letter	= [a-zA-Z]
Letter_ = ({Letter}|_)
Anything = ({Letter_}|{Digit}|\r|\t|\s|\\|\~|\!|\$|\^|\&|\*|\+|\||<|>|\=|\/|\#|\{|\}|\[|\]|\(|\)|\?|\;|\.|\,|\"|\:|\-|\%)*

Rules.
%Para los #include
#{Letter_}({Letter_}|{Digit})* :
      {token, {'INC', "<span class=\"INC\">" ++ TokenChars ++"</span>", TokenLine}}.

%Operadores
\-      :   {token, {'MIN', "<span class=\"MATH\">" ++ TokenChars ++"</span>", TokenLine}}.
\^      :   {token, {'CARET', "<span class=\"MATH\">" ++ TokenChars ++"</span>", TokenLine}}.
\+      :   {token, {'PS', "<span class=\"MATH\">" ++ TokenChars ++"</span>", TokenLine}}.
\*      :   {token, {'AS', "<span class=\"MATH\">" ++ TokenChars ++"</span>", TokenLine}}.
\%      :   {token, {'PER', "<span class=\"MATH\">" ++ TokenChars ++"</span>", TokenLine}}.
/       :   {token, {'SLASH', "<span class=\"MATH\">" ++ TokenChars ++"</span>", TokenLine}}.

%Delimitadores, terminadores
\(      :   {token, {'LP', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\)      :   {token, {'RP', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\{      :   {token, {'LB', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\}      :   {token, {'RB', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\[      :   {token, {'LB', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\]      :   {token, {'RB', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\:      :   {token, {'DP', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
;       :   {token, {'SEMI', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\,      :   {token, {'COMMA', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.
\.      :   {token, {'DOT', "<span class=\"DIV\">" ++ TokenChars ++"</span>", TokenLine}}.

%Comparadores
==       :   {token, {'ASAS', "<span class=\"COMP\">" ++ TokenChars ++"</span>", TokenLine}}.
\=       :   {token, {'AS', "<span class=\"COMP\">" ++ TokenChars ++"</span>", TokenLine}}.
<=       :   {token, {'LTA', "<span class=\"COMP\">" ++ TokenChars ++"</span>", TokenLine}}.
>=       :   {token, {'GTA', "<span class=\"COMP\">" ++ TokenChars ++"</span>", TokenLine}}.
!=       :   {token, {'DIFF', "<span class=\"COMP\">" ++ TokenChars ++"</span>", TokenLine}}.
<       :   {token, {'LT', "<span class=\"COMP\">" ++ TokenChars ++"</span>", TokenLine}}.
>       :   {token, {'GT', "<span class=\"COMP\">" ++ TokenChars ++"</span>", TokenLine}}.

%Espacios en blanco
\n		:	{token, {'WS', "\n<br />", TokenLine}}.
\r		:	{token, {'WS', "\r", TokenLine}}.
\t		:	{token, {'WS', "\t&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", TokenLine}}.
\s		:	{token, {'WS', "&nbsp;", TokenLine}}.

%Demás símbolos especiales
\~       :   {token, {'TILDE', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\!       :   {token, {'EM', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\#       :   {token, {'NS', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\$       :   {token, {'DOLL', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\&      :   {token, {'AMPER', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\_      :   {token, {'US', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\|      :   {token, {'VB', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\\      :   {token, {'BS', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.
\?      :   {token, {'QM', "<span class=\"CARACT\">" ++ TokenChars ++"</span>", TokenLine}}.

%Palabras reservadas o variables
{Letter_}({Letter_}|{Digit})*   :
    Atom = list_to_atom(TokenChars),

        case reserved_word(Atom) of
            true -> {token, {'RW', "<span class=\"RW\">" ++ TokenChars ++"</span>", TokenLine}};
            false -> diferenciador(Atom, TokenChars, TokenLine)
        end.

%Literales númericas
%Números notación científica
(-)?{Digit}*\.?{Digit}*[e|E](\+|-)?{Digit}* :
      {token, {'FLOAT', "<span class=\"NUMBER2\">" ++ TokenChars ++"</span>", TokenLine}}.
%Números decimales
(-)?{Digit}*\.{Digit}* :
      {token, {'FLOAT', "<span class=\"NUMBER1\">" ++ TokenChars ++"</span>", TokenLine}}.
%Números enteros
{Digit}+ : {token, {'INTEGER', "<span class=\"NUMBER\">" ++ TokenChars ++"</span>", TokenLine}}.

%Comentarios
//{Anything} :  skip_token.
/\*({Anything}|\n)*\*/ :  skip_token.

%Literales de cadena
\"{Anything}\" :
      {token, {'QM', "<span class=\"STRING\">" ++ TokenChars ++"</span>", TokenLine}}.
\'{Anything}\' :
      {token, {'QM', "<span class=\"STRING\">" ++ TokenChars ++"</span>", TokenLine}}.


Erlang code.
-export([reserved_word/1, reserved_word2/1, diferenciador/3]).

%Definición del primer grupo de palabras reservadas (estos tendrán el mismo color)
reserved_word('if')-> true;
reserved_word('else')-> true;
reserved_word('for')-> true;
reserved_word('do')-> true;
reserved_word('printf')-> true;
reserved_word('scanf')-> true;
reserved_word('main')-> true;
reserved_word('break')-> true;
reserved_word('switch')-> true;
reserved_word('enum')-> true;
reserved_word('return')-> true;
reserved_word('sizeof')-> true;
reserved_word('typedef')-> true;
reserved_word('while')-> true;
reserved_word('goto')-> true;
reserved_word('continue')-> true;
reserved_word('struct')-> true;
reserved_word('union')-> true;
reserved_word(_)-> false.

%Definición del segundo grupo de palabras reservadas (estos tendrán otro color)
reserved_word2('int') ->true;
reserved_word2('char') ->true;
reserved_word2('True') ->true;
reserved_word2('true') ->true;
reserved_word2('False') ->true;
reserved_word2('false') ->true;
reserved_word2('unsigned') ->true;
reserved_word2('signed') ->true;
reserved_word2('short') ->true;
reserved_word2('long') ->true;
reserved_word2('float') ->true;
reserved_word2('double') ->true;
reserved_word2('void')-> true;
reserved_word2('auto')-> true;
reserved_word2('const')-> true;
reserved_word2('register')-> true;
reserved_word2('extern')-> true;
reserved_word2('enum')-> true;
reserved_word2('volatile')-> true;
reserved_word2(_)-> false.

%Función que determina si la palabra corresponde al segundo grupo de palabras reservadas o es un identificador
diferenciador(Atom, TokenChars, TokenLine)->
  case reserved_word2(Atom) of
      true -> {token, {'RW', "<span class=\"RW2\">" ++ TokenChars ++"</span>", TokenLine}};
      false -> {token,{'ID', "<span class=\"ID\">" ++ TokenChars ++"</span>", TokenLine}}
  end.
