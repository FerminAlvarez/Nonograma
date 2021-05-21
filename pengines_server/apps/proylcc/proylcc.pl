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

 	getRow(NewGrilla,RowN,RowOut),
  	getClue(RowN, PistasFilas, ClueRow),
 	checkClue(RowOut, ClueRow, SatisfiedRow) ,!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se considera vacío a los elementos no instanciados o que son X
% isVoid(Elem).
%
isVoid(Elem):- not(ground(Elem)) , !.
isVoid("X").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dado un indice y un arreglo de pistas, se obtiene la pista correspondiente.
% getClue(Index,Clue,RES).
%
getClue(Index, Clue, RES):- nth0(Index, Clue, RES).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dado un numero de columna y un arreglo de columnas, se obtiene la pista correspondiente.
% getCol(ColN,PistasColumnas,RES).
%
getCol([],_,[]).
getCol([L1|Ls],ColN, [Elem|Col]):- nth0(ColN, L1, Elem), getCol(Ls,ColN, Col).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dado un numero de pista y un arreglo de pistas, se obtiene la pista correspondiente.
% getRow(RowN,PistasFilas,RES).
%
getRow(Grilla,RowN,RES):- nth0(RowN, Grilla, RES).

	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determina si una fila o columna satisface su pista correspondiente.
% checkClue(Fila/Columna,PistasFilas/PistasColumnas,RES).
% Se utiliza una "cascara" que se encarga de omitir los elementos que no son # y luego se usa checkClueAux


% Si queda un solo elemento y no hay mas pistas que satisfacer entonces debe ser vacio.
%																							checkClue([Elem],[0],1):- isVoid(Elem).
% Si no queda ningún elemento y no hay mas pistas que satisfacer entonces satisface.
checkClue([],[0],1).
checkClue([],[],1).
% Si el elemento es vacío entonces se llama con el siguiente elemento de la lista.
checkClue([Elem|Sublist],Clue,RES):- isVoid(Elem) , checkClue(Sublist,Clue,RES).
% Si es el elemento no es vacío, se encarga checkClueAux.
checkClue([Elem|Sublist],Clue,RES):- Elem == "#" , checkClueAux([Elem|Sublist],Clue,RES).
% Cualquier otro caso es falso.
checkClue(_,_,0).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determina si una fila o columna satisface su pista correspondiente, esta fila o columna debe comenzar con un elemento no "vacío"
% checkClueAux(Fila/Columna,PistasFilas/PistasColumnas,RES).
% Si queda un solo elemento y no hay mas pistas que satisfacer entonces debe ser vacio.
%																							checkClueAux([Elem],[0],1):- isVoid(Elem).
% Si no queda ningún elemento y no hay mas pistas que satisfacer entonces satisface.
checkClueAux([],[0],1).
% Si el elemento es #, entonces se decrementa el valor de la pista y se llama recursivamente con el siguiente elemento de la fila o columna.
checkClueAux([Elem|Sublist],[Clue|Ppost],RES):- Elem == "#", P is (Clue-1), checkClueAux(Sublist,[P|Ppost],RES),!.
% Si el elemento es vacío y el valor de la pista está en 0, significa que cumplió con al menos una parte de las pistas, entonces se llama con la parte siguiente.
checkClueAux([Elem|Sublist],[Clue|P],RES):- isVoid(Elem), Clue is 0, checkClueAux(Sublist,P,RES).
% Si se alcanza este caso siginifca que no hay mas pistas que resolver, por lo que todos los elementos que quedan deben estar vacios.
checkClueAux([Elem|Sublist],[],RES):- isVoid(Elem), checkClueAux(Sublist,[0],RES).

% Cualquier otro caso es falso.
checkClueAux(_,_,0).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se almacen en RowChecked las filas que satisfacen las pistas de una grilla dada, y lo mismo para las columnas en ColChecked.
% checkInit(Grilla,LengthRow,LengthCol,RowClue,ColClue,RowChecked,ColChecked).

checkInit(Grilla, LengthRow, LengthCol, RowClue, ColClue, RowChecked, ColChecked):-
    checkInitRow(Grilla, 0, LengthRow, RowClue, RowChecked), 
    checkInitCol(Grilla, 0, LengthCol, ColClue, ColChecked).
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se almacen en RES las filas que satisfacen las pistas de una grilla dada.
% checkInitRow(Grilla,Length,Length,RowClue,RES).

% Si la longitud es igual al contador entonces no hay que "recorrer" más.
checkInitRow(_Grilla,Length,Length,_RowClue,[]).
% Caso recursivo, si el contador no es igual a la longitud, entonces se obtiene la fila del contador, se verifica que esté bien y se obtiene para el resto de filas
checkInitRow(Grilla,Index,Length,[R|RSub],[RES|RowArray]):-
    not(Index is Length),
    getRow(Grilla,Index,Row),
    checkClue(Row,R,RES),
    IndexAux is Index + 1,
    checkInitRow(Grilla,IndexAux,Length,RSub,RowArray).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se almacen en RES las columnas que satisfacen las pistas de una grilla dada.
% checkInitCol(Grilla,Length,Length,ColClue,RES).

% Si la longitud es igual al contador entonces no hay que "recorrer" más.
checkInitCol(_Grilla,Length,Length,_ColClue,[]).
% Caso recursivo, si el contador no es igual a la longitud, entonces se obtiene la fila del contador, se verifica que esté bien y se obtiene para el resto de filas
checkInitCol(Grilla,Index,Length,[C|CSub],[RES|ColArray]):-
    not(Index is Length),
    getCol(Grilla,Index,Col),
    checkClue(Col,C,RES),
    IndexAux is Index + 1,
    checkInitCol(Grilla,IndexAux,Length,CSub,ColArray).
