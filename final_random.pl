:- dynamic([passing/1, rounds/1, bestpath/1, beststeps/1]).

:- assert(passing(1)).
:- assert(rounds(100)).
:- assert(beststeps(401)).

agent(0, 0).
listOfTouchdowns([[5,5]]).
world(5,5).
listOfOrcs([[0,1],[1,0],[1,2],[2,1],[2,3],[3,2]]).
listOfHumans([[2,2],[4,4]]).

newRound:-
    retractall(passing(_)), assert(passing(1)),
    rounds(X),
    retract(rounds(X)),
    Z is X - 1,
    assert(rounds(Z)),
    main.

checkRounds:-
    rounds(X), X > 0.

isOrc(Coord):-
    listOfOrcs(L), member(Coord, L).

isHuman(Coord):-
    listOfHumans(L), member(Coord, L).

isTouchdown(Coord):-
  listOfTouchdowns(L), member(Coord, L).

outX(X):-
    world(T, T),
    (X < 0; X > T).

outY(Y):-
    world(T, T),
    (Y < 0; Y > T).

isOut(X, Y):-  
    outX(X); outY(Y).

up(X, Y, X, Z) :-
    Z is Y + 1.

right(X, Y, Z, Y) :-
    Z is X + 1.

down(X, Y, X, Z) :-
    Z is Y - 1.

left(X, Y, Z, Y) :-
    Z is X - 1.

passup(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) ->  (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) ->  (AnsX is X, AnsY is Y);
    isOut(X, Y) ->   (writeln('Accidentally passed to wall:('), newRound);
    (YT is Y + 1, passup(X, YT, AnsX, AnsY)).
    
passdown(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) -> (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) -> (AnsX is X, AnsY is Y);
    isOut(X, Y) -> (writeln('Accidentally passed to wall:('), newRound);
    (YT is Y - 1, passdown(X, YT, AnsX, AnsY)).

passright(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) -> (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) -> (AnsX is X, AnsY is Y);
    isOut(X, Y) -> (writeln('Accidentally passed to wall:('), newRound);
    (XT is X + 1, passright(XT, Y, AnsX, AnsY)).

passleft(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) -> (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) -> (AnsX is X, AnsY is Y);
    isOut(X, Y) -> (writeln('Accidentally passed to wall:('), newRound);
    (XT is X - 1, passleft(XT, Y, AnsX, AnsY)).

passur(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) -> (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) -> (AnsX is X, AnsY is Y);
    isOut(X, Y) -> (writeln('Accidentally passed to wall:('), newRound);
    (XT is X + 1, YT is Y + 1, passur(XT, YT, AnsX, AnsY)).

passul(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) -> (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) -> (AnsX is X, AnsY is Y);
    isOut(X, Y) -> (writeln('Accidentally passed to wall:('), newRound);
    (XT is X - 1, YT is Y + 1, passul(XT, YT, AnsX, AnsY)).

passdr(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) -> (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) -> (AnsX is X, AnsY is Y);
    isOut(X, Y) -> (writeln('Accidentally passed to wall:('), newRound);
    (XT is X + 1, YT is Y - 1, passdr(XT, YT, AnsX, AnsY)).

passdl(X, Y, AnsX, AnsY):-
    isOrc([X, Y]) -> (writeln('Accidentally passed to orc:('), newRound);
    isHuman([X, Y]) -> (AnsX is X, AnsY is Y);
    isOut(X, Y) -> (writeln('Accidentally passed to wall:('), newRound);
    (XT is X - 1, YT is Y - 1, passdl(XT, YT, AnsX, AnsY)).

direct(X, Y, NewX, NewY, A):-
    Direction is random(4),(
    Direction == 0 -> (up(X, Y, NewX, NewY), A = 'M');
    Direction == 1 -> (right(X, Y, NewX, NewY), A = 'M');
    Direction == 2 -> (left(X, Y, NewX, NewY), A = 'M');
    Direction == 3 -> (down(X, Y, NewX, NewY), A = 'M')).
    

pass(X, Y, NewX, NewY, A):-
    Direction is random(8),(   
    Direction == 0 -> (YT is Y + 1,passup(X, YT, NewX, NewY));
    Direction == 1 -> (YT is Y - 1,passdown(X, YT, NewX, NewY));
    Direction == 2 -> (XT is X + 1,passright(XT, Y, NewX, NewY));
    Direction == 3 -> (XT is X - 1,passleft(XT, Y, NewX, NewY));
    Direction == 4 -> (XT is X + 1, YT is Y + 1, passur(XT, YT, NewX, NewY));
    Direction == 5 -> (XT is X - 1, YT is Y + 1, passul(XT, YT, NewX, NewY));
    Direction == 6 -> (XT is X + 1, YT is Y - 1, passdr(XT, YT, NewX, NewY));
    Direction == 7 -> (XT is X - 1, YT is Y - 1, passdl(XT, YT, NewX, NewY))
    ), A = 'P', retractall(passing(_)), assert(passing(0)).

trap(X, Y, Vis):-
    up(X, Y, XU, YU), member([XU, YU], Vis),
    down(X, Y, XD, YD), member([XD, YD], Vis),
    right(X, Y, XR, YR), member([XR, YR], Vis),
    left(X, Y, XL, YL), member([XL, YL], Vis).

action(X, Y, XF, YF, AF, Vis):-
    (passing(1) -> (   Direction is random(2),
    (Direction == 0 -> direct(X, Y, NewX, NewY, AF);
    Direction == 1 -> pass(X, Y, NewX, NewY,AF)));
    direct(X, Y, NewX, NewY, AF)),
    (member([NewX, NewY], Vis) ->(action(X, Y, X1, Y1, AK, Vis),XF is X1, YF is Y1, AF = AK); (XF is NewX, YF is NewY)).

addToPath(X, Y, Vis):-
    isOrc([X, Y]) -> (write('Bumped into orc: '), reverse(Vis, Path), writeln(Path), newRound);
    isTouchdown([X,Y]) ->(write('Reached the touchdown in '),calculateLenOfPath(Vis, Len), write(Len), 
    write(' steps: '),reverse(Vis, Path), writeln(Path),
    ((beststeps(S),(Len < S)) -> (retract(beststeps(S)), assert(beststeps(Len)), retractall(bestpath(_)), assert(bestpath(Path))); true), 
    newRound);
    trap(X, Y, Vis) -> (write('Accidentally in stalemate: '), reverse(Vis, Path), write(Path),nl,newRound);
    isOut(X, Y) -> (write('Bumped into wall: '), reverse(Vis, Path), write(Path),nl,newRound);
    (action(X, Y, NewX, NewY, A, Vis),(( A == 'M', isHuman([NewX, NewY]))->  NewA = 'H'; NewA = A),
    addToPath(NewX, NewY, [[NewX, NewY], NewA|Vis])).

%%count function was taken from the following site
%%https://www.tek-tips.com/viewthread.cfm?qid=1604418
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

main:-
    (checkRounds -> (rounds(X),
    nl, write('Start new round '), 
    Z is 101 - X, writeln(Z), 
    agent(StartX, StartY),
    addToPath(StartX, StartY, [[StartX, StartY]])));
    (nl, nl, beststeps(S), (S<401->(write('Best Solution is in '), write(S),
    write(' steps: '), bestpath(Path), writeln(Path)); 
    writeln('Best Solution was not found'))), statistics(walltime, [_ | [Runtime]]),write('Time: '), write(Runtime),
    writeln(' ms.').

start:-
    (write('Start the game'), nl,
    world(T, T),
    write('World is '), write(T), write('x'), write(T), nl,
    statistics(walltime, [_ | [_]]), main).