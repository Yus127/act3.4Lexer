-file("/usr/local/Cellar/erlang/23.3/lib/erlang/lib/parsetools-2.2/include/leexinc.hrl", 0).
%% The source of this file is part of leex distribution, as such it
%% has the same Copyright as the other files in the leex
%% distribution. The Copyright is defined in the accompanying file
%% COPYRIGHT. However, the resultant scanner generated by leex is the
%% property of the creator of the scanner and is not covered by that
%% Copyright.

-module(lexer).

-export([string/1,string/2,token/2,token/3,tokens/2,tokens/3]).
-export([format_error/1]).

%% User code. This is placed here to allow extra attributes.
-file("./lexer.xrl", 63).
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

-file("/usr/local/Cellar/erlang/23.3/lib/erlang/lib/parsetools-2.2/include/leexinc.hrl", 14).

format_error({illegal,S}) -> ["illegal characters ",io_lib:write_string(S)];
format_error({user,S}) -> S.

string(String) -> string(String, 1).

string(String, Line) -> string(String, Line, String, []).

%% string(InChars, Line, TokenChars, Tokens) ->
%% {ok,Tokens,Line} | {error,ErrorInfo,Line}.
%% Note the line number going into yystate, L0, is line of token
%% start while line number returned is line of token end. We want line
%% of token start.

string([], L, [], Ts) ->                     % No partial tokens!
    {ok,yyrev(Ts),L};
string(Ics0, L0, Tcs, Ts) ->
    case yystate(yystate(), Ics0, L0, 0, reject, 0) of
        {A,Alen,Ics1,L1} ->                  % Accepting end state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {A,Alen,Ics1,L1,_S1} ->              % Accepting transistion state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {reject,_Alen,Tlen,_Ics1,L1,_S1} ->  % After a non-accepting state
            {error,{L0,?MODULE,{illegal,yypre(Tcs, Tlen+1)}},L1};
        {A,Alen,Tlen,_Ics1,L1,_S1} ->
            Tcs1 = yysuf(Tcs, Alen),
            L2 = adjust_line(Tlen, Alen, Tcs1, L1),
            string_cont(Tcs1, L2, yyaction(A, Alen, Tcs, L0), Ts)
    end.

%% string_cont(RestChars, Line, Token, Tokens)
%% Test for and remove the end token wrapper. Push back characters
%% are prepended to RestChars.

-dialyzer({nowarn_function, string_cont/4}).

string_cont(Rest, Line, {token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, {end_token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, skip_token, Ts) ->
    string(Rest, Line, Rest, Ts);
string_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, Ts);
string_cont(_Rest, Line, {error,S}, _Ts) ->
    {error,{Line,?MODULE,{user,S}},Line}.

%% token(Continuation, Chars) ->
%% token(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {token,State,CurrLine,TokenChars,TokenLen,TokenLine,AccAction,AccLen}

token(Cont, Chars) -> token(Cont, Chars, 1).

token([], Chars, Line) ->
    token(yystate(), Chars, Line, Chars, 0, Line, reject, 0);
token({token,State,Line,Tcs,Tlen,Tline,Action,Alen}, Chars, _) ->
    token(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Action, Alen).

%% token(State, InChars, Line, TokenChars, TokenLen, TokenLine,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% The argument order is chosen to be more efficient.

token(S0, Ics0, L0, Tcs, Tlen0, Tline, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{token,S1,L1,Tcs,Alen1,Tline,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{token,S1,L1,Tcs,Tlen1,Tline,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     true -> {eof,L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,Ics1,L1,_S1} ->    % No token match
            Error = {Tline,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            {done,{error,Error,L1},Ics1};
        {A1,Alen1,Tlen1,_Ics1,L1,_S1} ->       % Use last accept match
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            token_cont(Tcs1, L2, yyaction(A1, Alen1, Tcs, Tline))
    end.

%% token_cont(RestChars, Line, Token)
%% If we have a token or error then return done, else if we have a
%% skip_token then continue.

-dialyzer({nowarn_function, token_cont/3}).

token_cont(Rest, Line, {token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, {end_token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {end_token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, skip_token) ->
    token(yystate(), Rest, Line, Rest, 0, Line, reject, 0);
token_cont(Rest, Line, {skip_token,Push}) ->
    NewRest = Push ++ Rest,
    token(yystate(), NewRest, Line, NewRest, 0, Line, reject, 0);
token_cont(Rest, Line, {error,S}) ->
    {done,{error,{Line,?MODULE,{user,S}},Line},Rest}.

%% tokens(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Tokens,AccAction,AccLen}
%% {skip_tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Error,AccAction,AccLen}

tokens(Cont, Chars) -> tokens(Cont, Chars, 1).

tokens([], Chars, Line) ->
    tokens(yystate(), Chars, Line, Chars, 0, Line, [], reject, 0);
tokens({tokens,State,Line,Tcs,Tlen,Tline,Ts,Action,Alen}, Chars, _) ->
    tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Ts, Action, Alen);
tokens({skip_tokens,State,Line,Tcs,Tlen,Tline,Error,Action,Alen}, Chars, _) ->
    skip_tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Error, Action, Alen).

%% tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Ts, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Alen1,Tline,Ts,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Tlen1,Tline,Ts,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error, no need to skip here.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     Ts == [] -> {eof,L1};
                     true -> {ok,yyrev(Ts),L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            %% Skip rest of tokens.
            Error = {L1,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,Tlen1,_Ics1,L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            tokens_cont(Tcs1, L2, Token, Ts)
    end.

%% tokens_cont(RestChars, Line, Token, Tokens)
%% If we have an end_token or error then return done, else if we have
%% a token then save it and continue, else if we have a skip_token
%% just continue.

-dialyzer({nowarn_function, tokens_cont/4}).

tokens_cont(Rest, Line, {token,T}, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {end_token,T}, Ts) ->
    {done,{ok,yyrev(Ts, [T]),Line},Rest};
tokens_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    {done,{ok,yyrev(Ts, [T]),Line},NewRest};
tokens_cont(Rest, Line, skip_token, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {error,S}, _Ts) ->
    skip_tokens(Rest, Line, {Line,?MODULE,{user,S}}).

%%skip_tokens(InChars, Line, Error) -> {done,{error,Error,Line},Ics}.
%% Skip tokens until an end token, junk everything and return the error.

skip_tokens(Ics, Line, Error) ->
    skip_tokens(yystate(), Ics, Line, Ics, 0, Line, Error, reject, 0).

%% skip_tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

skip_tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Error, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        {A1,Alen1,Ics1,L1} ->                  % Accepting end state
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,[],L1,S1} ->                 % After an accepting state
            {more,{skip_tokens,S1,L1,Tcs,Alen1,Tline,Error,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,Tlen1,[],L1,S1} ->           % After a non-accepting state
            {more,{skip_tokens,S1,L1,Tcs,Tlen1,Tline,Error,A1,Alen1}};
        {reject,_Alen1,_Tlen1,eof,L1,_S1} ->
            {done,{error,Error,L1},eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,Tlen1,_Ics1,L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            skip_cont(Tcs1, L2, Token, Error)
    end.

%% skip_cont(RestChars, Line, Token, Error)
%% Skip tokens until we have an end_token or error then return done
%% with the original rror.

-dialyzer({nowarn_function, skip_cont/4}).

skip_cont(Rest, Line, {token,_T}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {end_token,_T}, Error) ->
    {done,{error,Error,Line},Rest};
skip_cont(Rest, Line, {end_token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    {done,{error,Error,Line},NewRest};
skip_cont(Rest, Line, skip_token, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {skip_token,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {error,_S}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0).

-compile({nowarn_unused_function, [yyrev/1, yyrev/2, yypre/2, yysuf/2]}).

yyrev(List) -> lists:reverse(List).
yyrev(List, Tail) -> lists:reverse(List, Tail).
yypre(List, N) -> lists:sublist(List, N).
yysuf(List, N) -> lists:nthtail(N, List).

%% adjust_line(TokenLength, AcceptLength, Chars, Line) -> NewLine
%% Make sure that newlines in Chars are not counted twice.
%% Line has been updated with respect to newlines in the prefix of
%% Chars consisting of (TokenLength - AcceptLength) characters.

-compile({nowarn_unused_function, adjust_line/4}).

adjust_line(N, N, _Cs, L) -> L;
adjust_line(T, A, [$\n|Cs], L) ->
    adjust_line(T-1, A, Cs, L-1);
adjust_line(T, A, [_|Cs], L) ->
    adjust_line(T-1, A, Cs, L).

%% yystate() -> InitialState.
%% yystate(State, InChars, Line, CurrTokLen, AcceptAction, AcceptLen) ->
%% {Action, AcceptLen, RestChars, Line} |
%% {Action, AcceptLen, RestChars, Line, State} |
%% {reject, AcceptLen, CurrTokLen, RestChars, Line, State} |
%% {Action, AcceptLen, CurrTokLen, RestChars, Line, State}.
%% Generated state transition functions. The non-accepting end state
%% return signal either an unrecognised character or end of current
%% input.

-file("./lexer.erl", 320).
yystate() -> 29.

yystate(32, [47|Ics], Line, Tlen, Action, Alen) ->
    yystate(28, Ics, Line, Tlen+1, Action, Alen);
yystate(32, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,32};
yystate(31, Ics, Line, Tlen, _, _) ->
    {13,Tlen,Ics,Line};
yystate(30, [125|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [123|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [95|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [62|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [61|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [60|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [59|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [58|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [47|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [46|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [45|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [44|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [41|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [40|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [37|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [35|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [34|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [32|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [13|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [9|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(30, Ics, Line, Tlen+1, 4, Tlen);
yystate(30, Ics, Line, Tlen, _, _) ->
    {4,Tlen,Ics,Line,30};
yystate(29, [125|Ics], Line, Tlen, Action, Alen) ->
    yystate(25, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [124|Ics], Line, Tlen, Action, Alen) ->
    yystate(21, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [123|Ics], Line, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [101|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [69|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [62|Ics], Line, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [61|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [60|Ics], Line, Tlen, Action, Alen) ->
    yystate(10, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [59|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [58|Ics], Line, Tlen, Action, Alen) ->
    yystate(18, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [47|Ics], Line, Tlen, Action, Alen) ->
    yystate(26, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [46|Ics], Line, Tlen, Action, Alen) ->
    yystate(20, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [45|Ics], Line, Tlen, Action, Alen) ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [44|Ics], Line, Tlen, Action, Alen) ->
    yystate(12, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [43|Ics], Line, Tlen, Action, Alen) ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [41|Ics], Line, Tlen, Action, Alen) ->
    yystate(4, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [40|Ics], Line, Tlen, Action, Alen) ->
    yystate(0, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [37|Ics], Line, Tlen, Action, Alen) ->
    yystate(3, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [35|Ics], Line, Tlen, Action, Alen) ->
    yystate(7, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [32|Ics], Line, Tlen, Action, Alen) ->
    yystate(19, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [13|Ics], Line, Tlen, Action, Alen) ->
    yystate(23, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(27, Ics, Line+1, Tlen+1, Action, Alen);
yystate(29, [9|Ics], Line, Tlen, Action, Alen) ->
    yystate(31, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(22, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 68 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [C|Ics], Line, Tlen, Action, Alen) when C >= 70, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 100 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(29, [C|Ics], Line, Tlen, Action, Alen) when C >= 102, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(29, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,29};
yystate(28, Ics, Line, Tlen, _, _) ->
    {5,Tlen,Ics,Line};
yystate(27, Ics, Line, Tlen, _, _) ->
    {11,Tlen,Ics,Line};
yystate(26, [47|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 10, Tlen);
yystate(26, [42|Ics], Line, Tlen, _, _) ->
    yystate(24, Ics, Line, Tlen+1, 10, Tlen);
yystate(26, Ics, Line, Tlen, _, _) ->
    {10,Tlen,Ics,Line,26};
yystate(25, Ics, Line, Tlen, _, _) ->
    {17,Tlen,Ics,Line};
yystate(24, [125|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [123|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [62|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [61|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [60|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [59|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [58|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [47|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [46|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [44|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [42|Ics], Line, Tlen, Action, Alen) ->
    yystate(32, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [41|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [40|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [35|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [32|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [13|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line+1, Tlen+1, Action, Alen);
yystate(24, [9|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(24, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,24};
yystate(23, Ics, Line, Tlen, _, _) ->
    {12,Tlen,Ics,Line};
yystate(22, [124|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 1, Tlen);
yystate(22, [101|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 1, Tlen);
yystate(22, [69|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 1, Tlen);
yystate(22, [46|Ics], Line, Tlen, _, _) ->
    yystate(20, Ics, Line, Tlen+1, 1, Tlen);
yystate(22, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(22, Ics, Line, Tlen+1, 1, Tlen);
yystate(22, Ics, Line, Tlen, _, _) ->
    {1,Tlen,Ics,Line,22};
yystate(21, [45|Ics], Line, Tlen, _, _) ->
    yystate(17, Ics, Line, Tlen+1, 2, Tlen);
yystate(21, [43|Ics], Line, Tlen, _, _) ->
    yystate(17, Ics, Line, Tlen+1, 2, Tlen);
yystate(21, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(17, Ics, Line, Tlen+1, 2, Tlen);
yystate(21, Ics, Line, Tlen, _, _) ->
    {2,Tlen,Ics,Line,21};
yystate(20, [124|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 3, Tlen);
yystate(20, [101|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 3, Tlen);
yystate(20, [69|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 3, Tlen);
yystate(20, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(20, Ics, Line, Tlen+1, 3, Tlen);
yystate(20, Ics, Line, Tlen, _, _) ->
    {3,Tlen,Ics,Line,20};
yystate(19, Ics, Line, Tlen, _, _) ->
    {14,Tlen,Ics,Line};
yystate(18, Ics, Line, Tlen, _, _) ->
    {24,Tlen,Ics,Line};
yystate(17, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(17, Ics, Line, Tlen+1, 2, Tlen);
yystate(17, Ics, Line, Tlen, _, _) ->
    {2,Tlen,Ics,Line,17};
yystate(16, [124|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 23, Tlen);
yystate(16, [101|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 23, Tlen);
yystate(16, [69|Ics], Line, Tlen, _, _) ->
    yystate(21, Ics, Line, Tlen+1, 23, Tlen);
yystate(16, [46|Ics], Line, Tlen, _, _) ->
    yystate(20, Ics, Line, Tlen+1, 23, Tlen);
yystate(16, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(8, Ics, Line, Tlen+1, 23, Tlen);
yystate(16, Ics, Line, Tlen, _, _) ->
    {23,Tlen,Ics,Line,16};
yystate(15, [125|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [123|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [62|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [61|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [60|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [59|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [58|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [47|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [46|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [45|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [44|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [41|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [40|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [37|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [35|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(11, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [32|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [13|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [9|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,15};
yystate(14, Ics, Line, Tlen, _, _) ->
    {20,Tlen,Ics,Line};
yystate(13, Ics, Line, Tlen, _, _) ->
    {16,Tlen,Ics,Line};
yystate(12, Ics, Line, Tlen, _, _) ->
    {22,Tlen,Ics,Line};
yystate(11, [125|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [123|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [95|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [62|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [61|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [60|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [59|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [58|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [47|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [46|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [45|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [44|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [41|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [40|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [37|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [35|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [34|Ics], Line, Tlen, _, _) ->
    yystate(11, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [32|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [13|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [9|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(15, Ics, Line, Tlen+1, 6, Tlen);
yystate(11, Ics, Line, Tlen, _, _) ->
    {6,Tlen,Ics,Line,11};
yystate(10, Ics, Line, Tlen, _, _) ->
    {7,Tlen,Ics,Line};
yystate(9, [95|Ics], Line, Tlen, _, _) ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(9, Ics, Line, Tlen, _, _) ->
    {0,Tlen,Ics,Line,9};
yystate(8, [124|Ics], Line, Tlen, Action, Alen) ->
    yystate(21, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [101|Ics], Line, Tlen, Action, Alen) ->
    yystate(21, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [69|Ics], Line, Tlen, Action, Alen) ->
    yystate(21, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [46|Ics], Line, Tlen, Action, Alen) ->
    yystate(20, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,8};
yystate(7, Ics, Line, Tlen, _, _) ->
    {15,Tlen,Ics,Line};
yystate(6, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line};
yystate(5, [95|Ics], Line, Tlen, _, _) ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(5, [45|Ics], Line, Tlen, _, _) ->
    yystate(17, Ics, Line, Tlen+1, 0, Tlen);
yystate(5, [43|Ics], Line, Tlen, _, _) ->
    yystate(17, Ics, Line, Tlen+1, 0, Tlen);
yystate(5, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(1, Ics, Line, Tlen+1, 0, Tlen);
yystate(5, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(5, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(5, Ics, Line, Tlen, _, _) ->
    {0,Tlen,Ics,Line,5};
yystate(4, Ics, Line, Tlen, _, _) ->
    {19,Tlen,Ics,Line};
yystate(3, Ics, Line, Tlen, _, _) ->
    {25,Tlen,Ics,Line};
yystate(2, Ics, Line, Tlen, _, _) ->
    {8,Tlen,Ics,Line};
yystate(1, [95|Ics], Line, Tlen, _, _) ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(1, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(1, Ics, Line, Tlen+1, 0, Tlen);
yystate(1, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(1, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(1, Ics, Line, Tlen, _, _) ->
    {0,Tlen,Ics,Line,1};
yystate(0, Ics, Line, Tlen, _, _) ->
    {18,Tlen,Ics,Line};
yystate(S, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,S}.

%% yyaction(Action, TokenLength, TokenChars, TokenLine) ->
%% {token,Token} | {end_token, Token} | skip_token | {error,String}.
%% Generated action function.

yyaction(0, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_0(TokenChars, TokenLine);
yyaction(1, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_1(TokenChars, TokenLine);
yyaction(2, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_2(TokenChars, TokenLine);
yyaction(3, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_3(TokenChars, TokenLine);
yyaction(4, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_4(TokenChars, TokenLine);
yyaction(5, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_5(TokenChars, TokenLine);
yyaction(6, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_6(TokenChars, TokenLine);
yyaction(7, _, _, TokenLine) ->
    yyaction_7(TokenLine);
yyaction(8, _, _, TokenLine) ->
    yyaction_8(TokenLine);
yyaction(9, _, _, TokenLine) ->
    yyaction_9(TokenLine);
yyaction(10, _, _, TokenLine) ->
    yyaction_10(TokenLine);
yyaction(11, _, _, TokenLine) ->
    yyaction_11(TokenLine);
yyaction(12, _, _, TokenLine) ->
    yyaction_12(TokenLine);
yyaction(13, _, _, TokenLine) ->
    yyaction_13(TokenLine);
yyaction(14, _, _, TokenLine) ->
    yyaction_14(TokenLine);
yyaction(15, _, _, TokenLine) ->
    yyaction_15(TokenLine);
yyaction(16, _, _, TokenLine) ->
    yyaction_16(TokenLine);
yyaction(17, _, _, TokenLine) ->
    yyaction_17(TokenLine);
yyaction(18, _, _, TokenLine) ->
    yyaction_18(TokenLine);
yyaction(19, _, _, TokenLine) ->
    yyaction_19(TokenLine);
yyaction(20, _, _, TokenLine) ->
    yyaction_20(TokenLine);
yyaction(21, _, _, TokenLine) ->
    yyaction_21(TokenLine);
yyaction(22, _, _, TokenLine) ->
    yyaction_22(TokenLine);
yyaction(23, _, _, TokenLine) ->
    yyaction_23(TokenLine);
yyaction(24, _, _, TokenLine) ->
    yyaction_24(TokenLine);
yyaction(25, _, _, TokenLine) ->
    yyaction_25(TokenLine);
yyaction(_, _, _, _) -> error.

-compile({inline,yyaction_0/2}).
-file("./lexer.xrl", 11).
yyaction_0(TokenChars, TokenLine) ->
     Atom = list_to_atom (TokenChars),
     { token,
     case reserved_word (Atom) of
     true -> { 'RW', "<span class=\"RW\">" ++ TokenChars ++ "</span>", TokenLine } ;
     false -> { 'ID', "<span class=\"ID\">" ++ TokenChars ++ "</span>", TokenLine }
     end } .

-compile({inline,yyaction_1/2}).
-file("./lexer.xrl", 18).
yyaction_1(TokenChars, TokenLine) ->
     { token, { 'INTEGER', "<span class=\"NUMBER\">" ++ TokenChars ++ "</span>", TokenLine } } .

-compile({inline,yyaction_2/2}).
-file("./lexer.xrl", 21).
yyaction_2(TokenChars, TokenLine) ->
     { token, { 'FLOAT', "<span class=\"NUMBER2\">" ++ TokenChars ++ "</span>", TokenLine } } .

-compile({inline,yyaction_3/2}).
-file("./lexer.xrl", 24).
yyaction_3(TokenChars, TokenLine) ->
     { token, { 'FLOAT', "<span class=\"NUMBER1\">" ++ TokenChars ++ "</span>", TokenLine } } .

-compile({inline,yyaction_4/2}).
-file("./lexer.xrl", 27).
yyaction_4(TokenChars, TokenLine) ->
     { token, { 'DIAG', "<span class=\"COMM\">" ++ TokenChars ++ "</span>", TokenLine } } .

-compile({inline,yyaction_5/2}).
-file("./lexer.xrl", 30).
yyaction_5(TokenChars, TokenLine) ->
     { token, { 'COMM', "<span class=\"COMM\">" ++ TokenChars ++ "</span>", TokenLine } } .

-compile({inline,yyaction_6/2}).
-file("./lexer.xrl", 33).
yyaction_6(TokenChars, TokenLine) ->
     { token, { 'QM', "<span class=\"AA\">" ++ TokenChars ++ "</span>", TokenLine } } .

-compile({inline,yyaction_7/1}).
-file("./lexer.xrl", 35).
yyaction_7(TokenLine) ->
     { token, { 'LT', "<", TokenLine } } .

-compile({inline,yyaction_8/1}).
-file("./lexer.xrl", 36).
yyaction_8(TokenLine) ->
     { token, { 'GT', ">", TokenLine } } .

-compile({inline,yyaction_9/1}).
-file("./lexer.xrl", 37).
yyaction_9(TokenLine) ->
     { token, { 'AS', "=", TokenLine } } .

-compile({inline,yyaction_10/1}).
-file("./lexer.xrl", 39).
yyaction_10(TokenLine) ->
     { token, { 'DIAG', "/", TokenLine } } .

-compile({inline,yyaction_11/1}).
-file("./lexer.xrl", 40).
yyaction_11(TokenLine) ->
     { token, { 'WS', "\n<br />", TokenLine } } .

-compile({inline,yyaction_12/1}).
-file("./lexer.xrl", 41).
yyaction_12(TokenLine) ->
     { token, { 'WS', "\r", TokenLine } } .

-compile({inline,yyaction_13/1}).
-file("./lexer.xrl", 42).
yyaction_13(TokenLine) ->
     { token, { 'WS', "\t&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", TokenLine } } .

-compile({inline,yyaction_14/1}).
-file("./lexer.xrl", 43).
yyaction_14(TokenLine) ->
     { token, { 'WS', "&nbsp;", TokenLine } } .

-compile({inline,yyaction_15/1}).
-file("./lexer.xrl", 44).
yyaction_15(TokenLine) ->
     { token, { 'PUN', "#", TokenLine } } .

-compile({inline,yyaction_16/1}).
-file("./lexer.xrl", 45).
yyaction_16(TokenLine) ->
     { token, { 'LB', "{", TokenLine } } .

-compile({inline,yyaction_17/1}).
-file("./lexer.xrl", 46).
yyaction_17(TokenLine) ->
     { token, { 'RB', "}", TokenLine } } .

-compile({inline,yyaction_18/1}).
-file("./lexer.xrl", 47).
yyaction_18(TokenLine) ->
     { token, { 'LP', "(", TokenLine } } .

-compile({inline,yyaction_19/1}).
-file("./lexer.xrl", 48).
yyaction_19(TokenLine) ->
     { token, { 'RP', ")", TokenLine } } .

-compile({inline,yyaction_20/1}).
-file("./lexer.xrl", 49).
yyaction_20(TokenLine) ->
     { token, { 'SEMI', ";", TokenLine } } .

-compile({inline,yyaction_21/1}).
-file("./lexer.xrl", 50).
yyaction_21(TokenLine) ->
     { token, { 'DOT', ".", TokenLine } } .

-compile({inline,yyaction_22/1}).
-file("./lexer.xrl", 51).
yyaction_22(TokenLine) ->
     { token, { 'COMMA', ",", TokenLine } } .

-compile({inline,yyaction_23/1}).
-file("./lexer.xrl", 52).
yyaction_23(TokenLine) ->
     { token, { 'MIN', "-", TokenLine } } .

-compile({inline,yyaction_24/1}).
-file("./lexer.xrl", 53).
yyaction_24(TokenLine) ->
     { token, { 'DP', ":", TokenLine } } .

-compile({inline,yyaction_25/1}).
-file("./lexer.xrl", 54).
yyaction_25(TokenLine) ->
     { token, { 'PER', "%", TokenLine } } .

-file("/usr/local/Cellar/erlang/23.3/lib/erlang/lib/parsetools-2.2/include/leexinc.hrl", 313).
