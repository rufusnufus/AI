:- dynamic([start/1, stop/1, bestpath/1, beststeps/1]).
:- assert(beststeps(401)).


%world(2,2).
%agent predicate shows where the agent starts, by assignment task it is 
%tiuchdown predicate shows the coordinates of the touchdown
%world predicate shows the size of the world, here it is square n by n.
agent(0, 0).
touchdown(1, 1).

world(1,1).
listOfOrcs([]).
listOfHumans([[0,1]]).

%check bounds of the world
outX(X):-
    world(T, T),
    (X < 0; X > T).

outY(Y):-
    world(T, T),
    (Y < 0; Y > T).

isOut(X, Y):-  
    outX(X); outY(Y).

%moves
up(X, Y, X, Z):-
    Z is Y + 1.

right(X, Y, Z, Y):-
    Z is X + 1.

down(X, Y, X, Z):-
    Z is Y - 1.

left(X, Y, Z, Y):-
    Z is X - 1.

isOrc(Coord):-
  listOfOrcs(L), member(Coord, L).

isHuman(Coord):-
  listOfHumans(L), member(Coord, L).

%passing the ball function
pass(CoordX, CoordY, HX, HY, NewX, NewY):-
    isOrc([OX, OY]),
    (
    (CoordX =:= OX , CoordY =< OY , OY =< HY);
    (CoordX =:= OX , HY =< OY , OY =< CoordY);
    (CoordY =:= OY , CoordX =< OX , OX =< HX);  
    (CoordY =:= OY , HX =< OX , OX =< CoordX);
    (OY - CoordY =:= OX - CoordX, HY - CoordY =:= HX - CoordX);
    (OY - CoordY =:= CoordX - OX, HY - CoordY =:= CoordX - HX)
    )->false;
    NewX is HX, NewY is HY.

%action function: movement somewhere or pass
action(CoordX, CoordY, NewX, NewY, A, Vis) :-
    %% если есть возможность кинуть, кидаем, иначе ходим
    (((count('P', Vis, Pass), Pass=:=0,  isHuman([HX, HY]), not(member([HX, HY], Vis))),
    (   HX =:= CoordX -> pass(CoordX, CoordY, HX, HY, NewX, NewY); 
        HY =:= CoordY -> pass(CoordX, CoordY, HX, HY, NewX, NewY);
        HY - CoordY =:= HX - CoordX -> pass(CoordX, CoordY, HX, HY, NewX, NewY);
        HY - CoordY =:= HX - CoordX -> pass(CoordX, CoordY, HX, HY, NewX, NewY)
    ), A = 'P');
    %% либо вверх,либо вправо,либо налево,но не по парням,либо вниз
    (up(CoordX, CoordY, NewX, NewY);
    right(CoordX, CoordY, NewX, NewY);
    left(CoordX, CoordY, NewX, NewY);
    down(CoordX, CoordY, NewX, NewY)), A = 'M'),
    %% чекаем что новая координата не стена, не орк, не была посещена
    not(isOut(NewX, NewY)),
    not(isOrc([NewX, NewY])),
    not(member([NewX, NewY], Vis)).

%if the movement is valid, then adds to path.
add_to_path(CurrX, CurrY, Vis, Path):-
    touchdown(CurrX,CurrY) -> (Path = Vis);
    action(CurrX, CurrY, NewX, NewY, A, Vis),
    ((A == 'M', isHuman([NewX, NewY]))->  NewA = 'H'; NewA = A), 
    add_to_path(NewX, NewY, [[NewX,NewY], NewA|Vis], Path).

count(_, [], 0).
count(X, [X | T], N) :-
  !, count(X, T, N1),
  N is N1 + 1.
count(X, [_ | T], N) :-
  count(X, T, N).

calculateLenOfPath(Path, Len):-
    count('M', Path, NumM),
    count('P', Path, NumP),
    Len is (NumM + NumP).

start(CoordX, CoordY, Path):-
    add_to_path(CoordX, CoordY, [[CoordX, CoordY]], Path).

main:-
    (agent(StartX, StartY),isOrc([StartX, StartY])) -> (write('Ops... The orc caught us... AAAAA'), nl, 
    writeln(Path),statistics(walltime, [_ | [Runtime]]),write('Time: '), write(Runtime), writeln('ms.'));
    agent(StartX, StartY),
    start(StartX,StartY, Path), reverse(Path, Right_order),
    calculateLenOfPath(Path, Len),
    ((beststeps(S),(Len < S)) -> (retract(beststeps(S)), assert(beststeps(Len)), retractall(bestpath(_)), assert(bestpath(Right_order))); true),
    write('Number of steps: '), writeln(Len), write('Path: '), 
    write(Right_order), nl,nl, fail.

start:-
    write('Start the game'), nl,
    statistics(walltime, [_ | [_]]),
    main;write('Best Solution is in '), beststeps(S),write(S),
    write(' steps: '), bestpath(Path), writeln(Path),statistics(walltime, [_ | [Runtime]]),write('Time: '), write(Runtime), writeln('ms.').