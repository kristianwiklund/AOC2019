-module(t).
-export([t/0,datan/0, datan2/0,sendprog/2,t2/0]).
-include_lib("../../cecho/_build/default/lib/cecho/include/cecho.hrl").

setup() ->
    
    code:add_patha("../../cecho/_build/default/lib/cecho/ebin"),
    application:start(cecho),
        % Set attributes
    cecho:cbreak(),
    cecho:noecho(),
    cecho:curs_set(?ceCURS_INVISIBLE),
    cecho:refresh(),
    cecho:erase(),
    cecho:refresh(),
    C = spawn(ic, run, [datan(), self()]),
        C.


getimage(Cam,X,Y, World) ->
    
    receive
	Result ->
	    Result
    after
	10000 ->
	    Result=-1
    end,
    if Result =/= 46 ->
	    NWorld= ic:setcol(World, X,Y, Result);
       true ->
	    NWorld = World
    end,

    case Result of 
	10 ->
	    NX=0,
	    NY=Y+1;
	_ -> 
	    NX=X+1,
	    NY=Y
    end,
    
    if 
	Result =/= -1 ->
	    
	    if 
		Result == 46 ->
		    cecho:mvaddch(Y+1,X+1, 32);
		true ->		    
		    cecho:mvaddch(Y+1,X+1, Result)
	    end,
					    
	    cecho:refresh(),
	    getimage(Cam,NX,NY,NWorld);
	true ->
	    NWorld
    end.




dirvector(Dir) ->
        case Dir of % {X,Y}
        78 ->
		{0,-1};
	     %N
        69 -> {1,0}; %E
        87 -> {-1,0}; %W
        83 -> {0,1}; %S
        1 -> {0,-1}; %N
        2 -> {1,0}; %E
        4 -> {-1,0}; %W
        3 -> {0,1} %S
    end. 

turnleft(Dir) ->
    if Dir == 1 ->
	    4;
       true ->
	    Dir - 1
    end.

turnright(Dir) ->
    if Dir == 4 ->
	    1;
       true ->
	    Dir + 1
    end.

emptyspaces(X,Y, World) ->
    L = lists:map(fun(P)->
			  dirvector(P) end, "NESW"),
    D = lists:map(fun({DX, DY}) ->
			  {DX+X,DY+Y} end, L),

    T = lists:map(fun({DX, DY}) ->
			  ic:getcol(World, DX,DY) end, D),
    lists:map(fun(TT)->
		      TT==0 end, T).
    
    

nremptyspaces(X,Y,World) ->
    T = emptyspaces(X,Y,World),
    lists:foldl(fun(P, Acc) ->
			if P -> Acc+1; true->Acc end end, 0, T).
	       	    

isex(World, Where) ->
    [X,Y]=Where,
    Char = ic:getcol(World, X,Y),
    Test = (nremptyspaces(X,Y,World)<2) and (Char==35),
    if
	Test ->
	    cecho:mvaddstr(Y+1,X+1,"O"),
	    cecho:refresh();
	true ->
	    ok
    end,
    Test.

findisex(World) ->
    Intersections = maps:filter(fun(Key, Value)->
					isex(World, Key) end, World),
    Intersections.

% 9250 too high
% 8538 too high
%7720 
    

sendprog(Bot, Prog) ->
    
    lists:foreach(fun(X)->
			  Bot ! X end, Prog).
    
sendprogA(Bot) ->
    sendprog(Bot,"L,10,R,10,L,10,L,10\n").

sendprogB(Bot) ->
    sendprog(Bot,"R,10,R,12,L,12\n").

sendprogC(Bot) ->
    sendprog(Bot, "R,12,L,12,R,6\n").

sendprogMain(Bot) ->
    sendprog(Bot, "A,B,A,B,C,C,B,A,B,C\n").

printerer(Y,X) ->
    receive
	Result ->
	    Result,
	    cecho:mvaddstr(Y, X, io_lib:format(">>~s<<~B>>",[[Result],Result])),
	    printerer(Y,X+1)
    after
	10000 ->
	    ok
    end.

findplayer(World) ->
    Player = maps:filter(fun(Key, Value)->
				 Value == 94 end, World),
    [[X,Y]]=maps:keys(Player),
    {X,Y}.




findpath(Maze,X,Y, Steps, Mode, Dir, LastTurn,S) ->


    Tile = ic:getcol(Maze, X,Y),
    timer:sleep(10),
    if Tile =/= 0 ->
	    {DX, DY} = dirvector(Dir),
						% move us to this location, continue searching ahead
						%	    cecho:mvaddstr(Y+1,X+1,"#"),
	    cecho:mvaddstr(Y+1,X+1, "@"),
	    cecho:mvaddstr(1, 0, io_lib:format("(~B,~B) ~B       ",[X,Y,Steps])),
	    cecho:refresh(),
	    {FP0, NM0} = findpath(Maze, DX+X, DY+Y, Steps+1, Mode, Dir, LastTurn, S),
	    

	    if not FP0 ->
		    io:format(S, "~s~B\n", [LastTurn,Steps]),

		    % try turning right, then left, then stop

		    {DXR,DYR} = dirvector(turnright(Dir)),
		    {DXL,DYL} = dirvector(turnleft(Dir)),
		    TileR = ic:getcol(Maze, X+DXR, Y+DYR),
		    TileL = ic:getcol(Maze, X+DXL, Y+DYL),
		    
		    if TileR =/= 0 ->
			    {FP, NM} = findpath(Maze, X, Y, 0, Mode, turnright(Dir),"R",S);
		       TileL =/= 0 ->
			    {FP, NM} = findpath(Maze, X, Y, 0, Mode, turnleft(Dir),"L",S);
		       true ->
			    {FP,NM} = {false, Maze},
			    cecho:mvaddstr(2, 0, "Out of scaffolding"),
			    throw(banana)
		    end,
		    {FP, NM};			
	       true ->
		    {FP0, NM0}
	    end;
       true ->
	    {false, Maze}
    end.


t() ->
    Cam = setup(),
    
    World = getimage(Cam,0,0,#{}),
    I = findisex(World),
    F = maps:fold(fun(Key, Value, AccIn) ->  [X,Y] = Key,X*Y+AccIn end, 0, I),
    cecho:mvaddstr(0, 0, io_lib:format("ISEX: ~B       ",[F])),
    cecho:refresh(),
    {X,Y}=findplayer(World),
    {ok, S} = file:open("fruit_count.txt", [write]),
    findpath (World, X-1, Y, 1, walktru, 4,"L",S). % start one step left of the playah

t2() ->
    code:add_patha("../../cecho/_build/default/lib/cecho/ebin"),
    application:start(cecho),
        % Set attributes
    cecho:cbreak(),
    cecho:noecho(),
    cecho:curs_set(?ceCURS_INVISIBLE),
    cecho:refresh(),
    cecho:erase(),
    cecho:refresh(),
    Bot = spawn(ic, run, [datan2(), self()]),
    
    World = getimage(Bot,0,0,#{}),
    sendprogMain(Bot),
    printerer(2,0),
    sendprogA(Bot),
    printerer(3,0),
    sendprogB(Bot),
    printerer(4,0),
    sendprogC(Bot),
    printerer(5,0),
    sendprog(Bot, "n\n"),
    printerer(6,0).


    


datan2() ->
    ic:setnth(1,datan(),2).



datan() ->
    [1,330,331,332,109,6690,1102,1,1182,16,1102,1,1505,24,102,1,0,570,1006,570,36,1002,571,1,0,1001,570,-1,570,1001,24,1,24,1106,0,18,1008,571,0,571,1001,16,1,16,1008,16,1505,570,1006,570,14,21102,58,1,0,1105,1,786,1006,332,62,99,21101,333,0,1,21102,73,1,0,1105,1,579,1102,0,1,572,1101,0,0,573,3,574,101,1,573,573,1007,574,65,570,1005,570,151,107,67,574,570,1005,570,151,1001,574,-64,574,1002,574,-1,574,1001,572,1,572,1007,572,11,570,1006,570,165,101,1182,572,127,1002,574,1,0,3,574,101,1,573,573,1008,574,10,570,1005,570,189,1008,574,44,570,1006,570,158,1106,0,81,21101,340,0,1,1106,0,177,21102,1,477,1,1106,0,177,21101,0,514,1,21102,1,176,0,1106,0,579,99,21101,0,184,0,1105,1,579,4,574,104,10,99,1007,573,22,570,1006,570,165,1001,572,0,1182,21101,375,0,1,21102,211,1,0,1106,0,579,21101,1182,11,1,21101,222,0,0,1105,1,979,21101,388,0,1,21101,0,233,0,1105,1,579,21101,1182,22,1,21102,1,244,0,1105,1,979,21101,401,0,1,21101,255,0,0,1105,1,579,21101,1182,33,1,21101,0,266,0,1105,1,979,21101,0,414,1,21101,277,0,0,1106,0,579,3,575,1008,575,89,570,1008,575,121,575,1,575,570,575,3,574,1008,574,10,570,1006,570,291,104,10,21101,1182,0,1,21102,1,313,0,1106,0,622,1005,575,327,1101,0,1,575,21101,327,0,0,1106,0,786,4,438,99,0,1,1,6,77,97,105,110,58,10,33,10,69,120,112,101,99,116,101,100,32,102,117,110,99,116,105,111,110,32,110,97,109,101,32,98,117,116,32,103,111,116,58,32,0,12,70,117,110,99,116,105,111,110,32,65,58,10,12,70,117,110,99,116,105,111,110,32,66,58,10,12,70,117,110,99,116,105,111,110,32,67,58,10,23,67,111,110,116,105,110,117,111,117,115,32,118,105,100,101,111,32,102,101,101,100,63,10,0,37,10,69,120,112,101,99,116,101,100,32,82,44,32,76,44,32,111,114,32,100,105,115,116,97,110,99,101,32,98,117,116,32,103,111,116,58,32,36,10,69,120,112,101,99,116,101,100,32,99,111,109,109,97,32,111,114,32,110,101,119,108,105,110,101,32,98,117,116,32,103,111,116,58,32,43,10,68,101,102,105,110,105,116,105,111,110,115,32,109,97,121,32,98,101,32,97,116,32,109,111,115,116,32,50,48,32,99,104,97,114,97,99,116,101,114,115,33,10,94,62,118,60,0,1,0,-1,-1,0,1,0,0,0,0,0,0,1,84,18,0,109,4,2101,0,-3,587,20102,1,0,-1,22101,1,-3,-3,21102,1,0,-2,2208,-2,-1,570,1005,570,617,2201,-3,-2,609,4,0,21201,-2,1,-2,1106,0,597,109,-4,2106,0,0,109,5,2102,1,-4,629,21001,0,0,-2,22101,1,-4,-4,21102,1,0,-3,2208,-3,-2,570,1005,570,781,2201,-4,-3,652,21001,0,0,-1,1208,-1,-4,570,1005,570,709,1208,-1,-5,570,1005,570,734,1207,-1,0,570,1005,570,759,1206,-1,774,1001,578,562,684,1,0,576,576,1001,578,566,692,1,0,577,577,21101,702,0,0,1106,0,786,21201,-1,-1,-1,1106,0,676,1001,578,1,578,1008,578,4,570,1006,570,724,1001,578,-4,578,21101,0,731,0,1106,0,786,1105,1,774,1001,578,-1,578,1008,578,-1,570,1006,570,749,1001,578,4,578,21102,756,1,0,1106,0,786,1106,0,774,21202,-1,-11,1,22101,1182,1,1,21102,1,774,0,1106,0,622,21201,-3,1,-3,1105,1,640,109,-5,2105,1,0,109,7,1005,575,802,20101,0,576,-6,21002,577,1,-5,1106,0,814,21102,0,1,-1,21102,0,1,-5,21102,1,0,-6,20208,-6,576,-2,208,-5,577,570,22002,570,-2,-2,21202,-5,85,-3,22201,-6,-3,-3,22101,1505,-3,-3,1201,-3,0,843,1005,0,863,21202,-2,42,-4,22101,46,-4,-4,1206,-2,924,21101,0,1,-1,1105,1,924,1205,-2,873,21101,0,35,-4,1105,1,924,2101,0,-3,878,1008,0,1,570,1006,570,916,1001,374,1,374,2102,1,-3,895,1102,1,2,0,2101,0,-3,902,1001,438,0,438,2202,-6,-5,570,1,570,374,570,1,570,438,438,1001,578,558,922,20101,0,0,-4,1006,575,959,204,-4,22101,1,-6,-6,1208,-6,85,570,1006,570,814,104,10,22101,1,-5,-5,1208,-5,61,570,1006,570,810,104,10,1206,-1,974,99,1206,-1,974,1101,0,1,575,21102,973,1,0,1105,1,786,99,109,-7,2106,0,0,109,6,21101,0,0,-4,21102,0,1,-3,203,-2,22101,1,-3,-3,21208,-2,82,-1,1205,-1,1030,21208,-2,76,-1,1205,-1,1037,21207,-2,48,-1,1205,-1,1124,22107,57,-2,-1,1205,-1,1124,21201,-2,-48,-2,1106,0,1041,21101,0,-4,-2,1105,1,1041,21101,0,-5,-2,21201,-4,1,-4,21207,-4,11,-1,1206,-1,1138,2201,-5,-4,1059,2101,0,-2,0,203,-2,22101,1,-3,-3,21207,-2,48,-1,1205,-1,1107,22107,57,-2,-1,1205,-1,1107,21201,-2,-48,-2,2201,-5,-4,1090,20102,10,0,-1,22201,-2,-1,-2,2201,-5,-4,1103,1202,-2,1,0,1105,1,1060,21208,-2,10,-1,1205,-1,1162,21208,-2,44,-1,1206,-1,1131,1106,0,989,21101,0,439,1,1106,0,1150,21102,477,1,1,1106,0,1150,21101,0,514,1,21101,1149,0,0,1106,0,579,99,21101,0,1157,0,1105,1,579,204,-2,104,10,99,21207,-3,22,-1,1206,-1,1138,1202,-5,1,1176,1202,-4,1,0,109,-6,2106,0,0,46,7,78,1,84,1,84,1,84,1,84,1,80,13,72,1,3,1,7,1,72,1,3,1,7,1,9,11,52,1,3,1,7,1,9,1,9,1,52,1,3,1,7,1,9,1,9,1,52,1,3,1,7,1,9,1,9,1,44,13,7,1,9,1,9,1,44,1,7,1,11,1,9,1,9,1,44,1,7,1,11,1,9,1,9,1,44,1,7,1,11,1,9,1,9,1,42,11,11,1,9,1,9,1,42,1,1,1,19,1,9,1,9,1,42,1,1,1,19,11,9,11,32,1,1,1,82,1,1,1,82,1,1,1,82,1,1,1,82,1,1,1,72,13,72,1,9,1,74,1,9,11,64,1,19,1,64,1,19,1,64,1,19,1,64,1,19,1,64,1,19,1,64,1,19,1,64,1,19,1,64,11,9,1,74,1,9,1,72,13,72,1,1,1,82,1,1,1,82,1,1,1,82,1,1,1,82,1,1,1,52,11,19,1,1,1,52,1,9,1,19,1,1,1,52,1,9,1,11,11,52,1,9,1,11,1,7,1,54,1,9,1,11,1,7,1,54,1,9,1,11,1,7,1,54,13,5,13,64,1,1,1,5,1,3,1,72,1,1,1,5,1,3,1,72,1,1,1,5,1,3,1,72,1,1,1,5,1,3,1,72,1,1,1,5,1,3,1,72,13,74,1,5,1,78,1,5,1,78,1,5,1,78,1,5,1,78,1,5,1,78,7,66].
