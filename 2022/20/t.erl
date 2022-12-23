-module(t).
-export([t/0,move/2,calcmove/3,index_of/2, run/2, tst/0]).
-include_lib("stdlib/include/assert.hrl").

index_of(Item, List) -> index_of(Item, List, 1).

index_of(_, [], _)  -> not_found;
index_of(Item, [Item|_], Index) -> Index;
index_of(Item, [_|Tl], Index) -> index_of(Item, Tl, Index+1).



fixzor(A,B) when A<0 ->
    fixzor(A+B,B);
fixzor(A,B) when A>=B ->
    fixzor(A-B,B);

fixzor(A,_) ->
    A.

calcmove(XP,I,B) when B<0 ->
    V=(I+B),
    fixzor(V, length(XP));
calcmove(XP,I,B) when B>=0 ->
    fixzor((I+B), length(XP)).

move(X,B) ->
    L = abs(length(X)-1),
    if 
	(L==B) or (L==B) ->
	    X;
	true ->
	    I = index_of(B,X),
	    {X1,[_|X2]}=lists:split(I-1,X),
	    XP1=X1++X2,
    
	    TO=calcmove(XP1,I-1,B),

	    {Y1,Y2} = lists:split(TO,XP1),

	    if 
		Y1==[] ->
		    Y2++[B];
		Y2==[] ->
		    [B]++Y1;
		true ->
		    Y1++[B]++Y2
	    end
    end.

run(X,0)->
    X;

run(X,[Y|YS]) ->
    io:format("Moving ~p ~n",[Y]),
    V=move(X,Y),
    run(V,YS);

run(X,_) ->
    X.

test1() ->
    D=[1, 2, -3, 3, -2, 0, 4],
    R = run(D,D),
    ?assert(R==[1, 2, -3, 4, 0, 3, -2]),
    ?assert(run([1, 2, -2, -3, 0, 3, 4],[-2])==[1, 2, -3, 0, 3, 4, -2]),
    ?assert(run([1, 2, -3, 0, 3, 4, -2],[0])==[1, 2, -3, 0, 3, 4, -2]),
    ?assert(run([1, 2, -3, 0, 3, 4, -2],[4])==[1, 2, -3, 4, 0, 3, -2]),
    ?assert(run([1, 2, -3, 0, 3, -4, -2],[-4])==[1, -4, 2, -3, 0, 3, -2]),
    ?assert(run([1, -4, 2, -3, 0, 3, -2],[-4])==[1, 2, -3, -4, 0, 3, -2]).

tst()->
    D = [1,2,4,3],
    R = run(D,[4]),
    R.

test3()->
    D = [1,2,4,3],
    R = run(D,[4]),
    ?assert(R==[1,2,3,4]),
    R.


test2() ->
    D = [1,4,2,3],
    R = run(D,[2]),
    ?assert(R==[1,2,4,3]),
    R.

test4() ->
    ?assert(run([4, 5, 6, 1, 7, 8, 9],[1])==[4, 5, 6, 7, 1, 8, 9]),
    ?assert(run([4, -2, 5, 6, 7, 8, 9],[-2])==[4, 5, 6, 7, 8, -2, 9]).

tests() ->
    test1(),
    test2(),
    test3(),
    test4().

magic(RX) -> 
    io:format("R is ~p long~n",[length(RX)]),
    I = index_of(0,RX),
    {R1,R2}=lists:split(I,RX),
    R = R2++R1,
    I2 = index_of(0,R),
    io:format("I2 is ~p ~n",[I2]),
    A = lists:nth((1000) rem length(R),R),
    B =	lists:nth((2000) rem length(R),R),
    C =	lists:nth((3000) rem length(R),R),
    {A,B,C,A+B+C}.

readfile(FileName) ->
    {ok, Binary} = file:read_file(FileName),
    Lines = string:tokens(erlang:binary_to_list(Binary), "\n"),
    lists:map(fun(X)->
		      list_to_integer(X)
	      end, 
	      Lines).


t()->
    tests(),
    D = readfile("input.txt"),
    R = run(D,D),
    magic(R).
