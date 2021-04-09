% Para el lexer

Definitions.

Digit	= [0-9]
Letter	= [a-zA-Z]
Letter_ = ({Letter}|_)

Rules.

{Letter_}({Letter_}|{Digit})*   :
    Atom = list_to_atom(TokenChars),
    {token,
        case reserved_word(Atom) of
            true -> {'RW', "<span class=\"RW\">" ++ TokenChars ++"</span>", TokenLine};
            false -> {'ID', "<span class=\"ID\">" ++ TokenChars ++"</span>", TokenLine}
        end}.

{Digit}+ : {token, {'INTEGER', "<span class=\"INTEGER\">" ++ TokenChars ++"</span>", TokenLine}}.

<       :   {token, {'LT', "<", TokenLine}}.
>       :   {token, {'GT', ">", TokenLine}}.
=       :   {token, {'AS', "=", TokenLine}}.
\n		:	{token, {'WS', "\n<br />", TokenLine}}.
\r		:	{token, {'WS', "\r", TokenLine}}.
\t		:	{token, {'WS', "\t&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", TokenLine}}.
\s		:	{token, {'WS', "&nbsp;", TokenLine}}.
#       :   {token, {'PUN', "#", TokenLine}}.
\{      :   {token, {'LB', "{", TokenLine}}.
\}      :   {token, {'RB', "}", TokenLine}}.
\(      :   {token, {'LP', "(", TokenLine}}.
\)      :   {token, {'RP', ")", TokenLine}}.
;       :   {token, {'SC', ";", TokenLine}}.
\.      :   {token, {'DOT', ".", TokenLine}}.
\,      :   {token, {'CON', ",", TokenLine}}.
\"      :   {token, {'CO', "\"", TokenLine}}.
\:      :   {token, {'DP', ":", TokenLine}}.

Erlang code.
-export([reserved_word/1]).

reserved_word('if')-> true;

reserved_word(_)-> false.
