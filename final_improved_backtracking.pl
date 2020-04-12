:- dynamic([bestpath/1, beststeps/1]).

:- assert(beststeps(401)).
agent(0, 0).
listOfTouchdowns([[1,3],[2,0],[6,6]]).
world(6,6).
listOfOrcs([[0,6],[1,0],[2,1],[3,0]]).
listOfHumans([[0,2],[2,4],[2,5],[5,2],[5,4]]).

outX(X):-
    world(T, T),
    (X < 0; X > T).

outY(Y):-
    world(T, T),
    (Y < 0; Y > T).

isOut(X, Y):-  
    outX(X); outY(Y).

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

isTouchdown(Coord):-
  listOfTouchdowns(L), member(Coord, L).

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

action(CoordX, CoordY, NewX, NewY, A, Vis) :-
    %% если есть возможность кинуть, кидаем, иначе ходим
    (((count('P', Vis, Pass), Pass=:=0,  isHuman([HX, HY])),
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

add_to_path(CurrX, CurrY, Vis, Path):-
    isTouchdown([CurrX,CurrY]) -> (Path = Vis);
    action(CurrX, CurrY, NewX, NewY, A, Vis),
    (( A == 'M', isHuman([NewX, NewY]))->  NewA = 'H'; NewA = A), 
    calculateLenOfPath(Vis, L),beststeps(MinL),Len is L+1, (Len > MinL -> false; true),
    add_to_path(NewX, NewY, [[NewX,NewY], NewA|Vis], Path).

count(_, [], 0).
count(X, [X | T], N) :-
  !, count(X, T, N1),
  N is N1 + 1.
count(X, [_ | T], N) :-
  count(X, T, N).

start(CoordX, CoordY, Path):-
    add_to_path(CoordX, CoordY, [[CoordX, CoordY]], Path).

calculateLenOfPath(Path, Len):-
    count('M', Path, NumM),
    count('P', Path, NumP),
    Len is (NumM + NumP).

main:-
    (agent(StartX, StartY),isOrc([StartX, StartY])) -> (write('Ops... The orc caught us... AAAAA'), nl, statistics(walltime, [_ | [Runtime]]),write('Time: '), write(Runtime), writeln('ms.'));
    agent(StartX, StartY),
    start(StartX,StartY, Path),
    reverse(Path, Right_order),
    calculateLenOfPath(Path, Len),
    beststeps(MinLen), (Len < MinLen ->  retractall(beststeps(_)), assert(beststeps(Len)), retractall(bestpath(_)), assert(bestpath(Right_order));true),
    write('Number of steps: '), writeln(Len), write('Path: '), 
    write(Right_order), nl,nl, fail.

%improved
start:-
    write('Start the game'), nl,
    statistics(walltime, [_ | [_]]),
    main; beststeps(S),(S<401->(write('Best Solution is in '), write(S),
    write(' steps: '), bestpath(Path), writeln(Path)); writeln('Best Solution was not found')),
    statistics(walltime, [_ | [Runtime]]),write('Time: '), write(Runtime), writeln('ms.').