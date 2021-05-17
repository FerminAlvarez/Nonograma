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


    getCol(NewGrilla,ColN,ColOut),
  	getClue(ColN, PistasColumnas, ClueCol),
  	checkClue(ColOut, ClueCol, SatisfiedCol),

  	getClue(RowN, PistasFilas, ClueRow),
 	getRow(NewGrilla,RowN,RowOut),
 	checkClue(RowOut, ClueRow, SatisfiedRow).

%Consideramos vacío a los elementos no definidos o que son X
isVoid(Elem):- not(ground(Elem)) , !.
isVoid("X").

% Dado un indice y un arreglo de pistas, obtengo la correspondiente.
getClue(Index, Clue, RES):- nth0(Index, Clue, RES).


% Dado un numero de columna obtengo el arreglo columna correspondiente.
getCol([],_,[]).
getCol([L1|Ls],ColN, [Elem|Col]):- nth0(ColN, L1, Elem), getCol(Ls,ColN, Col).

% Dado un numero de fila obtengo el arreglo fila correspondiente.
getRow(Grilla,RowN,RES):- nth0(RowN, Grilla, RES).



% Primero limpiamos todos los casilleros vacios y una vez encontrada una cruz dejamos que verifique todo el checkClueAux.
% Si queda un solo elemento y no hay mas pistas que satisfacer entonces debe ser vacio.
checkClue([Elem],[0],1):- isVoid(Elem).
% Si queda un solo elemento y no hay mas pistas que satisfacer entonces debe ser vacio.
checkClue([],[0],1).
% Si es el elemento es vacío entonces llamamos con el siguiente elemento.
checkClue([Elem|Sublist],Clue,RES):- isVoid(Elem) , checkClue(Sublist,Clue,RES).
% Si es el elemento no es vacío, dejamos que checkClueAux se encargue.
checkClue([Elem|Sublist],Clue,RES):- Elem == "#" , checkClueAux([Elem|Sublist],Clue,RES).
% Cualquier otro caso es falso.
checkClue(_,_,0).

% Si queda un solo elemento y no hay mas pistas que satisfacer entonces debe ser vacio.
checkClueAux([Elem],[0],1):- isVoid(Elem).
% Si es el elemento es vacío entonces llamamos con el siguiente elemento.
checkClueAux([],[0],1).
% Si el elemento no es vacío, entonces decrementamos la valor de la pista y llamamamos recursivamente con el siguiente elemento
checkClueAux([Elem|Sublist],[Clue|Ppost],RES):- Elem == "#", P is (Clue-1), checkClueAux(Sublist,[P|Ppost],RES),!.
% Si el elemento es vacío y pista es 0, significa que cumplió con al menos una parte de las pistas, entonces llamamos con la parte siguiente.
checkClueAux([Elem|Sublist],[Clue|P],RES):- isVoid(Elem), Clue is 0, checkClueAux(Sublist,P,RES).
% Si llegamos a este caso siginifca que no hay mas pistas que resolver, por lo que todos los elementos que quedan deben estar vacios.
checkClueAux([Elem|Sublist],[],RES):- isVoid(Elem), checkClueAux(Sublist,[0],RES).

% Cualquier otro caso es falso.
checkClueAux(_,_,0).





checkInit(Grilla, LengthRow, LengthCol, RowClue, ColClue, RowChecked, ColChecked):-
    checkInitRow(Grilla, 0, LengthRow, RowClue, RowChecked),
    checkInitCol(Grilla, 0, LengthCol, ColClue, ColChecked).
    
% Si la longitud es igual al contador entonces terminé.
checkInitRow(_Grilla,Length,Length,_RowClue,[]).
% Caso recursivo, si el contador no es igual a la longitud, entonces obtengo la fila del contador, verifico que esté bien y llamo para el resto de filas
checkInitRow(Grilla,Index,Length,[R|RSub],[RES|RowArray]):-
    not(Index is Length),
    getRow(Grilla,Index,Row),
    checkClue(Row,R,RES),
    IndexAux is Index + 1,
    checkInitRow(Grilla,IndexAux,Length,RSub,RowArray).


% Si la longitud es igual al contador entonces terminé.
checkInitCol(_Grilla,Length,Length,_ColClue,[]).
% Caso recursivo, si el contador no es igual a la longitud, entonces obtengo la fila del contador, verifico que esté bien y llamo para el resto de filas
checkInitCol(Grilla,Index,Length,[C|CSub],[RES|ColArray]):-
    not(Index is Length),
    getCol(Grilla,Index,Col),
    checkClue(Col,C,RES),
    IndexAux is Index + 1,
    checkInitRow(Grilla,IndexAux,Length,CSub,ColArray).
