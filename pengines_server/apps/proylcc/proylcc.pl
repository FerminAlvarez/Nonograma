:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -FilaSat, -ColSat).
%

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, SatisfiedRow, SatisfiedCol):-	
	replace(Row, RowN, NewRow, Grilla, NewGrilla),

	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Conenido.	 
	
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Contenido 
		;
	replace(_Cell, ColN, Contenido, Row, NewRow)),


    getCol(NewGrilla,ColN,Col),
	
  	getClue(ColN, PistasColumnas, ClueCol),

  	checkClue(Col, ClueCol, SatisfiedCol),

  	getClue(RowN, PistasFilas, ClueRow),

 	getRow(NewGrilla,RowN,RowOut),

 	checkClue(RowOut, ClueRow, SatisfiedRow).




isVoid(Elem):- not(ground(Elem)) , !.
isVoid("#").


getClue(Index, Clue, RES):- nth0(Index, Clue, RES).

getCol([],_,[]).
getCol([L1|Ls],ColN, [Elemento|Columna]):- nth0(ColN, L1, Elemento), getCol(Ls,ColN, Columna).

getRow(Grilla,RowN,RES):- nth0(RowN, Grilla, RES).

%Caso base, si el elemento de la fila/columna es # o no está definida y no se necesitan mas "X", es 1
checkClue([Elem],[0],1):- isVoid(Elem).
checkClue([],[0],1).

%Caso recursivo, si el primer elemento de la fila/columna es X, llamamos con un valor de pista menos
checkClue([Elem|Sublist],[Clue|Ppost],RES):- Elem == "X", P is (Clue-1), checkClue(Sublist,[P|Ppost],RES),!.
checkClue([Elem|Sublist],[Clue|P],RES):- isVoid(Elem), Clue is 0, checkClue(Sublist,P,RES).
checkClue([Elem|Sublist],[],RES):- isVoid(Elem), checkClue(Sublist,[0],RES).
checkClue(_,_,0).


