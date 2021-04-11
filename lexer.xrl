% Para el lexer

Definitions.

Digit	= [0-9]
Letter	= [a-zA-Z]
Letter_ = ({Letter}|_)
Anything = ({Letter_}|{Digit}|\r|\t|\s|<|>|=|/|#|\{|\}|\(|\)|;|\.|\,|\"|\:|\-|%)*

Rules.
\~       :   {token, {'TILDE', "~", TokenLine}}.
\!       :   {token, {'EM', "!", TokenLine}}.
#{Letter_}({Letter_}|{Digit})* :
      {token, {'INC', "<span class=\"INC\">" ++ TokenChars ++"</span>", TokenLine}}.
\#       :   {token, {'NS', "#", TokenLine}}.
\$       :   {token, {'DOLL', "$", TokenLine}}.
\%      :   {token, {'PER', "%", TokenLine}}.
\^      :   {token, {'CARET', "^", TokenLine}}.
\&      :   {token, {'AMPER', "&", TokenLine}}.
\*      :   {token, {'AS', "*", TokenLine}}.
\(      :   {token, {'LP', "(", TokenLine}}.
\)      :   {token, {'RP', ")", TokenLine}}.
\_      :   {token, {'US', "_", TokenLine}}.
\+      :   {token, {'PS', "+", TokenLine}}.
\|      :   {token, {'VB', "|", TokenLine}}.
\\      :   {token, {'BS', "\\", TokenLine}}.
\-      :   {token, {'MIN', "-", TokenLine}}.
\=       :   {token, {'AS', "=", TokenLine}}.
\{      :   {token, {'LB', "{", TokenLine}}.
\}      :   {token, {'RB', "}", TokenLine}}.
\[      :   {token, {'LB', "[", TokenLine}}.
\]      :   {token, {'RB', "]", TokenLine}}.
\:      :   {token, {'DP', ":", TokenLine}}.
;       :   {token, {'SEMI', ";", TokenLine}}.
<       :   {token, {'LT', "<", TokenLine}}.
>       :   {token, {'GT', ">", TokenLine}}.
\?      :   {token, {'QM', "?", TokenLine}}.
\,      :   {token, {'COMMA', ",", TokenLine}}.
\.      :   {token, {'DOT', ".", TokenLine}}.
/       :   {token, {'SLASH', "/", TokenLine}}.


\n		:	{token, {'WS', "\n<br />", TokenLine}}.
\r		:	{token, {'WS', "\r", TokenLine}}.
\t		:	{token, {'WS', "\t&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", TokenLine}}.
\s		:	{token, {'WS', "&nbsp;", TokenLine}}.


{Letter_}({Letter_}|{Digit})*   :
    Atom = list_to_atom(TokenChars),

        case reserved_word(Atom) of
            true -> {token, {'RW', "<span class=\"RW\">" ++ TokenChars ++"</span>", TokenLine}};
            false -> pruebas(Atom, TokenChars, TokenLine)
        end.

{Digit}+ : {token, {'INTEGER', "<span class=\"NUMBER\">" ++ TokenChars ++"</span>", TokenLine}}.

(\+|-)?{Digit}*\.?{Digit}*[e|E](\+|-)?{Digit}* :
      {token, {'FLOAT', "<span class=\"NUMBER2\">" ++ TokenChars ++"</span>", TokenLine}}.

(\+|-)?{Digit}*\.{Digit}* :
      {token, {'FLOAT', "<span class=\"NUMBER1\">" ++ TokenChars ++"</span>", TokenLine}}.

//{Anything} :
      {token, {'DIAG', "<span class=\"COMM\">" ++ TokenChars ++"</span>", TokenLine}}.

/\*({Letter_}|{Digit}|\r|\t|\s|\n|<|>|=|/|#|\{|\}|\(|\)|;|\.|\,|\"|\:)*\*/ :
      {token, {'COMM', "<span class=\"COMM\">" ++ TokenChars ++"</span>", TokenLine}}.

\"{Anything}\" :
      {token, {'QM', "<span class=\"AA\">" ++ TokenChars ++"</span>", TokenLine}}.




Erlang code.
-export([reserved_word/1, reserved_word2/1, pruebas/3]).

reserved_word('if')-> true;
reserved_word('else')-> true;
reserved_word('for')-> true;
reserved_word('do')-> true;
reserved_word('printf')-> true;
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

reserved_word2('int') ->true;
reserved_word2('char') ->true;
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

pruebas(Atom, TokenChars, TokenLine)->
  case reserved_word2(Atom) of
      true -> {token, {'RW', "<span class=\"RW2\">" ++ TokenChars ++"</span>", TokenLine}};
      false -> {token,{'ID', "<span class=\"ID\">" ++ TokenChars ++"</span>", TokenLine}}
  end.
