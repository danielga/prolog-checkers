:- [board].
:- [alphabeta].

% iniciar como cruzes (joga primeiro)
startX :-
	abolish(human/1),
	abolish(computer/1),
	% definir humano como cruzes
	assert(human(x)),
	% definir computador como circunferências
	assert(computer(o)),
	boardInit(Board),
	boardPrint(Board),
	play(Board, humano).

% iniciar como circunferências (joga depois do computador)
startO :-
	abolish(human/1),
	abolish(computer/1),
	% definir humano como circunferências
	assert(human(o)),
	% definir computador como cruzes
	assert(computer(x)),
	boardInit(Board),
	boardPrint(Board),
	play(Board, computador).

play(Board, Player) :-
	boardGameOver(Board, Player),
	boardNextPlayer(Player, Winner),
	write('O vencedor e '), write(Winner), nl,
	!.

play(Board, humano) :-
	write('Escreva o seu movimento na forma DeLinha/DeColuna-ParaLinha/ParaColuna e um ponto final: '), nl,
	read(FromL/FromC-ToL/ToC),
	findall(Eat, boardValidEatMove(Board, humano, Eat), ObligatoryMoves),
	length(ObligatoryMoves, OblMovesLen),
	(
		OblMovesLen > 0, member(FromL/FromC-Middle-ToL/ToC, ObligatoryMoves), boardSet(Board, Middle, e);
		OblMovesLen = 0, boardValidJumpMove(Board, humano, FromL/FromC-Middle-ToL/ToC)
	),
	boardMove(Board, FromL/FromC, ToL/ToC),
	boardPrint(Board),
	(
		Middle \= jump, boardValidEatMove(Board, humano, ToL/ToC-_-_), play(Board, humano);
		play(Board, computador)
	).

play(Board, humano) :-
	nl, write('O seu movimento foi inserido incorretamente ou era invalido. Tente novamente.'), nl,
	play(Board, humano).

play(Board, computador) :-
	write('O computador esta a jogar.'), nl,
	alphabeta(Board, computador, -100, 100, move(NewBoard, _-Middle-ToL/ToC), _, 2),
	boardPrint(NewBoard),
	(
		Middle \= jump, boardValidEatMove(NewBoard, computador, ToL/ToC-_-_), play(NewBoard, computador);
		play(NewBoard, humano)
	).
