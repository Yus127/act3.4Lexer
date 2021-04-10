% Para el lexer

Definitions.

Digit	= [0-9]
Letter	= [a-zA-Z]
Letter_ = ({Letter}|_)
Anything = ({Letter_}|{Digit}|\r|\t|\s|<|>|=|/|#|\{|\}|\(|\)|;|\.|\,|\"|\:|\-|%)*

Rules.

{Letter_}({Letter_}|{Digit})*   :
    Atom = list_to_atom(TokenChars),
    {token,
        case reserved_word(Atom) of
            true -> {'RW', "<span class=\"RW\">" ++ TokenChars ++"</span>", TokenLine};
            false -> {'ID', "<span class=\"ID\">" ++ TokenChars ++"</span>", TokenLine}
        end}.

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

<       :   {token, {'LT', "<", TokenLine}}.
>       :   {token, {'GT', ">", TokenLine}}.
=       :   {token, {'AS', "=", TokenLine}}.

/       :   {token, {'DIAG', "/", TokenLine}}.
\n		:	{token, {'WS', "\n<br />", TokenLine}}.
\r		:	{token, {'WS', "\r", TokenLine}}.
\t		:	{token, {'WS', "\t&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", TokenLine}}.
\s		:	{token, {'WS', "&nbsp;", TokenLine}}.
#       :   {token, {'PUN', "#", TokenLine}}.
\{      :   {token, {'LB', "{", TokenLine}}.
\}      :   {token, {'RB', "}", TokenLine}}.
\(      :   {token, {'LP', "(", TokenLine}}.
\)      :   {token, {'RP', ")", TokenLine}}.
;       :   {token, {'SEMI', ";", TokenLine}}.
\.      :   {token, {'DOT', ".", TokenLine}}.
\,      :   {token, {'COMMA', ",", TokenLine}}.
\-      :   {token, {'MIN', "-", TokenLine}}.
\:      :   {token, {'DP', ":", TokenLine}}.
\%      :   {token, {'PER', "%", TokenLine}}.






Erlang code.
-export([reserved_word/1, reserved_word2/1]).

reserved_word('if')-> true;
reserved_word('else')-> true;
reserved_word('printf')-> true;
reserved_word('main')-> true;
reserved_word('break')-> true;
reserved_word('switch')-> true;

reserved_word(_)-> false.

reserved_word2('int') ->true;
reserved_word2(_)-> false.
