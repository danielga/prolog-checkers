:- [board].
:- [alphabeta].

% iniciar como cruzes (joga primeiro)
startX(Board) :-
	abolish(human/1),
	abolish(computer/1),
	% definir humano como cruzes
	assert(human(x)),
	% definir computador como circunferências
	assert(computer(o)),
	boardInit(Board),
	!.

% iniciar como circunferências (joga depois do computador)
startO(Board) :-
	abolish(human/1),
	abolish(computer/1),
	% definir humano como circunferências
	assert(human(o)),
	% definir computador como cruzes
	assert(computer(x)),
	boardInit(Board),
	!.

playHuman(Board, FromL/FromC-ToL/ToC, NewBoard, Continue) :-
	boardCopy(Board, NewBoard),
	findall(Eat, boardValidEatMove(NewBoard, humano, Eat), ObligatoryMoves),
	length(ObligatoryMoves, OblMovesLen),
	(
		OblMovesLen > 0, member(FromL/FromC-Middle-ToL/ToC, ObligatoryMoves), boardSet(NewBoard, Middle, e);
		OblMovesLen = 0, boardValidJumpMove(NewBoard, humano, FromL/FromC-Middle-ToL/ToC)
	),
	boardMove(NewBoard, FromL/FromC, ToL/ToC),
	(
		Middle \= jump, boardValidEatMove(NewBoard, humano, ToL/ToC-_-_), Continue = true;
		Continue = false
	),
	!.

playComputer(Board, NewBoard, Continue) :-
	alphabeta(Board, computador, -100, 100, move(NewBoard, _-Middle-ToL/ToC), _, 2),
	(
		Middle \= jump, boardValidEatMove(NewBoard, computador, ToL/ToC-_-_), Continue = true;
		Continue = false
	),
	!.
