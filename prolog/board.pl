% inicializar campo
boardInit(
	b(
		i, x, i, x, i, x, i, x,
		x, i, x, i, x, i, x, i,
		i, x, i, x, i, x, i, x,
		e, i, e, i, e, i, e, i,
		i, e, i, e, i, e, i, e,
		o, i, o, i, o, i, o, i,
		i, o, i, o, i, o, i, o,
		o, i, o, i, o, i, o, i
	)
).

% situação de jogo com damas e últimos passos
/*boardInit(
	b(
		i, e, i, e, i, e, i, e,
		e, i, e, i, e, i, e, i,
		i, e, i, o, i, e, i, e,
		x, i, o, i, e, i, e, i,
		i, e, i, e, i, e, i, o,
		o, i, o, i, e, i, e, i,
		i, e, i, oo, i, e, i, x,
		o, i, e, i, e, i, o, i
	)
).*/

% copiar campo
boardCopy(Board, NewBoard) :-
	Board =.. [b | List],
	NewBoard =.. [b | List].

% diferenciar peões de damas
boardPawn(x).
boardPawn(o).
boardQueen(xx).
boardQueen(oo).

% dama de um peão
boardQueenOf(x, xx).
boardQueenOf(o, oo).

% números pares e ímpares
boardOdd(1).
boardOdd(3).
boardOdd(5).
boardOdd(7).

boardEven(2).
boardEven(4).
boardEven(6).
boardEven(8).

% converter símbolo do campo para visualização
boardSymbol(x, x). % peão do X
boardSymbol(o, o). % peão do O
boardSymbol(xx, 'X'). % dama do X
boardSymbol(oo, 'O'). % dama do O
boardSymbol(e, '.'). % caixa vazia
boardSymbol(i, '#'). % caixa inválida

% inimigos de algum peão/dama
boardEnemy(x, o).
boardEnemy(x, oo).
boardEnemy(xx, o).
boardEnemy(xx, oo).
boardEnemy(o, x).
boardEnemy(o, xx).
boardEnemy(oo, x).
boardEnemy(oo, xx).

% próximo jogador
boardNextPlayer(humano, computador).
boardNextPlayer(computador, humano).

% direções da peça
boardJumpDirection(x, 1/1).
boardJumpDirection(x, 1/(-1)).
boardJumpDirection(xx, 1/1).
boardJumpDirection(xx, 1/(-1)).
boardJumpDirection(xx, (-1)/1).
boardJumpDirection(xx, (-1)/(-1)).
boardJumpDirection(o, (-1)/1).
boardJumpDirection(o, (-1)/(-1)).
boardJumpDirection(oo, 1/1).
boardJumpDirection(oo, 1/(-1)).
boardJumpDirection(oo, (-1)/1).
boardJumpDirection(oo, (-1)/(-1)).

% máxima distância do salto que pode realizar
boardJumpDistanceValid(x, 1).
boardJumpDistanceValid(xx, 1).
boardJumpDistanceValid(xx, 2).
boardJumpDistanceValid(xx, 3).
boardJumpDistanceValid(xx, 4).
boardJumpDistanceValid(xx, 5).
boardJumpDistanceValid(xx, 6).
boardJumpDistanceValid(xx, 7).
boardJumpDistanceValid(o, 1).
boardJumpDistanceValid(oo, 1).
boardJumpDistanceValid(oo, 2).
boardJumpDistanceValid(oo, 3).
boardJumpDistanceValid(oo, 4).
boardJumpDistanceValid(oo, 5).
boardJumpDistanceValid(oo, 6).
boardJumpDistanceValid(oo, 7).

% validar coordenadas
boardValidCoords(Line/Col) :-
	(
		boardEven(Line), boardOdd(Col);
		boardOdd(Line), boardEven(Col)
	).

% símbolos do jogador
boardPlayerSymbol(humano, Sym) :-
	human(S), !, (Sym = S; boardQueenOf(S, QS), Sym = QS).

boardPlayerSymbol(computador, Sym) :-
	computer(S), !, (Sym = S; boardQueenOf(S, QS), Sym = QS).

% imprimir o campo
boardPrint(Board) :-
	write('  1 2 3 4 5 6 7 8  '), nl,
	boardPrintLines(Board, 1),
	write('  1 2 3 4 5 6 7 8  '), nl, nl,
	!.

boardPrintLines(_, 9).
boardPrintLines(Board, Line) :-
	write(Line), boardPrintLine(Board, Line, 1), write(' '), write(Line), nl,
	LineP is Line + 1,
	boardPrintLines(Board, LineP).

boardPrintLine(_, _, 9).
boardPrintLine(Board, Line, Col) :-
	write(' '), boardGetCheap(Board, Line/Col, Elem), boardSymbol(Elem, Sym), write(Sym),
	ColP is Col + 1,
	boardPrintLine(Board, Line, ColP).

% contar peças de um tipo
boardCountPlayer(Board, Player, Count) :-
	Board =.. [b | List],
	boardCountPlayer(List, Player, 0, Result),
	!,
	Count = Result.

boardCountPlayer([], _, Result, Result) :-
	!.

boardCountPlayer([Sym | Xs], Player, Counter, Result) :-
	boardPlayerSymbol(Player, Sym),
	Counter1 is Counter + 1,
	boardCountPlayer(Xs, Player, Counter1, Result).

boardCountPlayer([_ | Xs], Player, Counter, Result) :-
	boardCountPlayer(Xs, Player, Counter, Result).

% contar peças de um tipo
boardCount(Board, Sym, Count) :-
	Board =.. [b | List],
	boardCount(List, Sym, 0, Result),
	!,
	Count = Result.

boardCount([], _, Result, Result) :-
	!.

boardCount([Sym | Xs], Sym, Counter, Result) :-
	Counter1 is Counter + 1,
	boardCount(Xs, Sym, Counter1, Result).

boardCount([_ | Xs], Sym, Counter, Result) :-
	boardCount(Xs, Sym, Counter, Result).

% fim do jogo
boardGameOver(Board, Loser) :-
	(
		boardCountPlayer(Board, Loser, 0);
		findall(Eat, boardValidEatMove(Board, Loser, Eat), []),
		findall(Jump, boardValidJumpMove(Board, Loser, Jump), [])
	),
	!.

% obter peça nesta posição (sem verificação ou inferimento)
boardGetCheap(Board, Line/Col, Elem) :-
	Index is (Line - 1) * 8 + Col,
	arg(Index, Board, Elem).

% obter peça nesta posição
boardGet(Board, Line/Col, Elem) :-
	boardValidCoords(Line/Col),
	Index is (Line - 1) * 8 + Col,
	arg(Index, Board, Elem).

% definir peça nesta posição
boardSet(Board, Line/Col, E) :-
	E \= i,
	Index is (Line - 1) * 8 + Col,
	(boardPawn(E), (Line = 1; Line = 8), boardQueenOf(E, Elem); Elem = E),
	setarg(Index, Board, Elem),
	!.

% mover peça
boardMove(Board, FromL/FromC, ToL/ToC) :-
	boardGet(Board, FromL/FromC, Elem),
	boardSet(Board, FromL/FromC, e),
	boardSet(Board, ToL/ToC, Elem),
	!.

% verificar se caminho está vazio entre ponto 1 e 2
boardVerifyPath(_, _, ToL/ToC, ToL/ToC).
boardVerifyPath(Board, DirV/DirH, FromL/FromC, ToL/ToC) :-
	boardGet(Board, FromL/FromC, e),
	MidL is FromL + DirV,
	MidC is FromC + DirH,
	boardVerifyPath(Board, DirV/DirH, MidL/MidC, ToL/ToC).

% verificar que não existem peças entre partida e chegada
boardJumpValid(Board, Sym, DirV/DirH, FromL/FromC, ToL/ToC) :-
	boardJumpDirection(Sym, DirV/DirH),
	DistV is (ToL - FromL) * DirV,
	DistH is (ToC - FromC) * DirH,
	DistV = DistH,
	boardJumpDistanceValid(Sym, DistV),
	MidL is FromL + DirV,
	MidC is FromC + DirH,
	boardVerifyPath(Board, DirV/DirH, MidL/MidC, ToL/ToC).

% movimento com comer
boardValidEatMove(Board, Player, FromL/FromC-MidL/MidC-ToL/ToC) :-
	boardPlayerSymbol(Player, PSym),
	boardGet(Board, FromL/FromC, PSym),
	boardNextPlayer(Player, Enemy),
	boardPlayerSymbol(Enemy, ESym),
	boardGet(Board, MidL/MidC, ESym),
	boardGet(Board, ToL/ToC, e),
	boardJumpValid(Board, PSym, DirV/DirH, FromL/FromC, MidL/MidC),
	boardJumpValid(Board, PSym, DirV/DirH, MidL/MidC, ToL/ToC).

% movimento normal
boardValidJumpMove(Board, Player, FromL/FromC-jump-ToL/ToC) :-
	boardPlayerSymbol(Player, PSym),
	boardGet(Board, FromL/FromC, PSym),
	boardGet(Board, ToL/ToC, e),
	boardJumpValid(Board, PSym, _, FromL/FromC, ToL/ToC).
