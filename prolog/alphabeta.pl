% alphabeta
% do livro Prolog Programming for Artificial Intelligence

alphabeta(Board, _, _, _, _, Val, 0) :-
	staticval(Board, Val).

alphabeta(Board, Player, Alpha, Beta, GoodBoard, Val, Depth) :-
	moves(Board, Player, Boards),
	(
		% se não existirem quaisquer movimentos possíveis
		% chegamos a um impasse e alguém pode ter ganho/houve empate
		length(Boards, 0), staticval(Board, Val);
		boardNextPlayer(Player, Enemy),
		!,
		boundedbest(Boards, Enemy, Alpha, Beta, GoodBoard, Val, Depth)
	).

boundedbest([move(Board, Move) | Boards], Player, Alpha, Beta, move(GoodBoard, Move), GoodVal, Depth) :-
	DepthP is Depth - 1,
	alphabeta(Board, Player, Alpha, Beta, _, Val, DepthP),
	goodenough(Boards, Player, Alpha, Beta, Board, Val, GoodBoard, GoodVal, Depth).

goodenough([], _, _, _, Board, Val, Board, Val, _) :-
	!.
goodenough(_, humano, _, Beta, Board, Val, Board, Val, _) :-
	Val > Beta, !.
goodenough(_, computador, Alpha, _, Board, Val, Board, Val, _) :-
	Val < Alpha, !.
goodenough(Boards, Player, Alpha, Beta, Board, Val, GoodBoard, GoodVal, Depth) :-
	newbounds(Alpha, Player, Beta, Board, Val, NewAlpha, NewBeta),
	boundedbest(Boards, Player, NewAlpha, NewBeta, move(Board1, _), Val1, Depth),
	betterof(Board, Player, Val, Board1, Val1, GoodBoard, GoodVal).

newbounds(Alpha, humano, Beta, _, Val, Val, Beta) :-
	Val > Alpha, !.
newbounds(_, computador, Beta, _, Val, Val, Beta) :-
	Val < Beta, !.
newbounds(Alpha, _, Beta, _, _, Alpha, Beta).

betterof(Board, humano, Val, _, Val1, Board, Val) :-
	Val > Val1, !.
betterof(Board, computador, Val, _, Val1, Board, Val) :-
	Val < Val1, !.
betterof(_, _, _, Board, Val1, Board, Val1).

moves(Board, Player, Boards) :-
	(
		findall(Eat, boardValidEatMove(Board, Player, Eat), Moves), length(Moves, Len), Len > 0;
		findall(Jump, boardValidJumpMove(Board, Player, Jump), Moves)
	),
	movesL(Board, Moves, Boards).

movesL(_, [], []).
movesL(Board, [FromL/FromC-jump-ToL/ToC | Moves], [move(NBoard, FromL/FromC-jump-ToL/ToC) | Boards]) :-
	boardCopy(Board, NBoard),
	boardMove(NBoard, FromL/FromC, ToL/ToC),
	movesL(Board, Moves, Boards).
movesL(Board, [FromL/FromC-MidL/MidC-ToL/ToC | Moves], [move(NBoard, FromL/FromC-MidL/MidC-ToL/ToC) | Boards]) :-
	boardCopy(Board, NBoard),
	boardMove(NBoard, FromL/FromC, ToL/ToC),
	boardSet(NBoard, MidL/MidC, e),
	movesL(Board, Moves, Boards).

% avaliar tabuleiro
staticval(Board, Res) :-
	computer(Comp),
	human(Human),
	boardCount(Board, Comp, Res1),
	boardCount(Board, Human, Res2),
	boardQueenOf(Comp, CompK),
	boardQueenOf(Human, HumanK),
	boardCount(Board, CompK, Res1k),
	boardCount(Board, HumanK, Res2k),
	king_bonus(Board, CompK, Bonus),
	Res is (Res1 + (Res1k * 1.4)) - (Res2 + (Res2k * 1.4)) + Bonus.

% bónus das damas (king em inglês)
king_bonus(Board, Sym, Bonus) :-
	findall(L/C, boardGet(Board, L/C, Sym), List),
	!,
	king_bonusL(List, Bonus, 0).

king_bonusL([], Bonus, Bonus).
king_bonusL([L/C | Xs], Bonus, Agg) :-
	(
		L > 2, L < 7, B1 is 0.4, !;
		B1 is 0
	),
	(
		C > 2, C < 7, B2 is 0.2, !;
		B2 is 0
	),
	Agg1 is Agg + B1 + B2,
	king_bonusL(Xs, Bonus, Agg1).

