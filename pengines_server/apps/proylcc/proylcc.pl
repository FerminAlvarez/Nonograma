	:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).
:- use_module(library(clpfd)).
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
isVoid([]).

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
checkClue([Elem],[0],1):- isVoid(Elem).
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
checkClueAux([Elem],[0],1):- isVoid(Elem).
% Si no queda ningún elemento y no hay mas pistas que satisfacer entonces satisface.
checkClueAux([],[0],1).
% Si el elemento es #, entonces se decrementa el valor de la pista y se llama recursivamente con el siguiente elemento de la fila o columna.
checkClueAux([Elem|Sublist],[Clue|Ppost],RES):- Elem == "#", P is (Clue-1), checkClueAux(Sublist,[P|Ppost],RES),!.
% Si el elemento es vacío y el valor de la pista está en 0, significa que cumplió con al menos una parte de las pistas, entonces se llama con la parte siguiente. ___________________________________________________________________________________________________________________
checkClueAux([Elem|Sublist],[Clue|P],RES):- isVoid(Elem), Clue is 0, checkClue(Sublist,P,RES).


% Si se alcanza este caso siginifca que no hay mas pistas que resolver, por lo que todos los elementos que quedan deben estar vacios.
checkClueAux([Elem|Sublist],[],RES):- isVoid(Elem), checkClueAux(Sublist,[0],RES).

% Cualquier otro caso es falso.
checkClueAux(_,_,0).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Se almacen en RowChecked las filas que satisfacen las pistas de una grilla dada, y lo mismo para las columnas en ColChecked.
% checkInit(Grilla,LengthRow,LengthCol,RowClue,ColClue,RowChecked,ColChecked).

checkInit(Grilla, LengthRow, LengthCol, RowClue, ColClue, RowChecked, ColChecked):-
    checkInitRow(Grilla, 0, LengthRow, RowClue, RowChecked), 
    checkInitCol(Grilla, 0, LengthCol, ColClue, ColChecked), !.
    

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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determina si todos los elementos de la Lista son iguales a E
% allE(Elemento,Lista).
allE(_E,[]).
allE(E,[X|Xs]):- X == E, allE(E,Xs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dada una pista se genera la posible solución que la satisface.
% generarPosibles(ListaPosible,Pista).

%Caso base
generarPosibles([],[]).
%Caso recursivo: insertamos en la lista a devolver un "#" y llamamos al metodo auxiliar.
generarPosibles([Elem|Sublist],Clue):- Elem = "#" , generarPosiblesAux([Elem|Sublist],Clue).

generarPosibles([Elem|Sublist],Clue):- Elem = "X" , generarPosibles(Sublist,Clue).

%Caso base: si la lista está vacía y las pistas ya son 0.
generarPosiblesAux([],[0]).
%Caso recursivo, insertamos en la lista a devolver un "#" y si las pista no es 0, entonces llamamos recursivamente.
generarPosiblesAux([Elem|Sublist],[Clue|Ppost]):- Elem = "#",Clue \= 0, P is (Clue-1), generarPosiblesAux(Sublist,[P|Ppost]).
generarPosiblesAux([Elem|Sublist],[Clue|P]):- Elem = "X", Clue is 0, generarPosibles(Sublist,P).


filaCauta(Actual,Pista,Length,FilaC):-
    findall(Actual,(length(Actual,Length),generarPosibles(Actual,Pista)),Todas),
    interseccion(Todas,Length,FilaC).

interseccion(Posibles,Len,Salida):-
    AuxLen is Len - 1,
    interseccion_aux(Posibles,AuxLen,[],Salida).

interseccion_aux(_,-1,Aux,Aux).
%....
interseccion_aux(_,-1,_,_).

interseccion_aux(Posibles,N,LAux,Salida):- 
    getCol(Posibles,N,Iesimos), 
    allE("X",Iesimos), 
    append(["X"],LAux,Aux),
    NAux is N -1,
    interseccion_aux(Posibles,NAux,Aux,Salida), !.

interseccion_aux(Posibles,N,LAux,Salida):- 
    getCol(Posibles,N,Iesimos), 
    allE("#",Iesimos), 
    append(["#"],LAux,Aux),
    NAux is N -1,
    interseccion_aux(Posibles,NAux,Aux,Salida), !.


%Si hay alguna distinta
interseccion_aux(Posibles,N,In,Out):-
    append([_],In,Aux), %Agrego al final de la lista.
    NAux is N-1,
    interseccion_aux(Posibles,NAux,Aux,Out), !.




%%Limpiar todo cumple condicion
%caso base
cumpleCondicion([0],0).

%Caso en el que estamos en un espacio, restamos y seguimos.
cumpleCondicion([0|Ps],Length):-
	L is Length - 1,
    cumpleCondicion(Ps,L) , !.

%Caso normal
cumpleCondicion([P|Ps],Length):-
    not(P is 0),
	L is Length - 1,
    PAux is P - 1,
    cumpleCondicion([PAux|Ps],L) , !.

%cumpleCondicion([[]|Ps],Length):-
%	L is Length - 1,
%   cumpleCondicion([Ps],L) , !.






%//Caso Base : Me quede sin pistas para analizar
primeraPasadaFilaAux(_,[],[],_).
%//Casos recursivo 1: Cumple con la condicion de primerapasada.
primeraPasadaFilaAux([Fila|Resto],[Pista|RestoPista],[FilaSalida|RestoSalida],Longitud):-
	cumpleCondicion(Pista,Longitud),
	filaCauta(Fila,Pista,Longitud,FilaSalida),
	primeraPasadaFilaAux(Resto,RestoPista,RestoSalida,Longitud),!.
	
%Caso recursivo 2: No cumple con la condicion.
primeraPasadaFilaAux([Fila|Resto],[_Pista|RestoPista],[Fila|RestoSalida],Longitud):-
	primeraPasadaFilaAux(Resto,RestoPista,RestoSalida,Longitud),!.




primeraPasada(GrillaIn,PistasFila,PistasColumna,GrillaFinal):-
    length(PistasFila,LongitudFilas),
    primeraPasadaFilaAux(GrillaIn, PistasFila, GrillaSalidaFilas,LongitudFilas),
 	transpose(GrillaSalidaFilas, GrillaTraspuesta),
    length(PistasFila,LongitudColumnas),
    primeraPasadaFilaAux(GrillaTraspuesta, PistasColumna, GrillaSalidaColumnas,LongitudColumnas),
    transpose(GrillaSalidaColumnas, GrillaFinal).


%Caso base 1, ya esta todo OK
segundaPasada(GrillaIn, PistasFila, _PistasColumna,GrillaIn):-
    length(PistasFila,L),
    grillaCompleta(GrillaIn,L).

segundaPasada(GrillaIn, PistasFila, PistasColumna,GrillaOut):-
    %%Calculo grilla cautas.
   grillaCautas(GrillaIn,PistasFila,PistasColumna,GrillaAux),(
           %Si son iguales, asigno el valor de salida.                                                  
          (grillaIguales(GrillaIn,GrillaAux), GrillaOut = GrillaAux);
          %Sino, vuelvo a llamar.
          segundaPasada(GrillaAux,PistasFila,PistasColumna,GrillaOut)
   ).


grillaIguales([], []).
grillaIguales([Fila1|Subgrilla1], [Fila2|Subgrilla2]):-
      filasIguales(Fila1, Fila2),
      grillaIguales(Subgrilla1, Subgrilla2).

filasIguales([], []).
filasIguales([Elemento1|Subfila1],[Elemento2|Subfila2]):-
      var(Elemento1),
      var(Elemento2),
      filasIguales(Subfila1, Subfila2).

filasIguales([Elemento1|Subfila1], [Elemento2|Subfila2]):-
      Elemento1 == Elemento2,
      filasIguales(Subfila1, Subfila2).

%IgualesF:
% Caso base: Vacias, fin.
% Caso R1: El primer elem de cada una es una variable: [X|Xs], var(X)
% Despues sigo con las demas.
% Caso R2: El primer elem, no es variable, X1 == X2

grillaCompleta(_,0):-!.
grillaCompleta(Grilla,Index):-
    I is Index-1,
    getRow(Grilla,I,Row), 
    allAtomico(Row),
    grillaCompleta(Grilla,I).
            
            
allAtomico([]).
allAtomico([X|Xs]):-
	forall(member(Elem,X), not(isVoid(Elem))),
	allAtomico(Xs).

grillaCautas(GrillaIN,PistasFilas,PistasColumnas,Out):-
    length(PistasFilas,LengthFC),
	generarFilasCautas(GrillaIN,PistasFilas,GrillasFilasCautas,0,LengthFC),
    transpose(GrillasFilasCautas, Traspuesta),
    length(PistasColumnas,LengthPC),
	generarFilasCautas(Traspuesta,PistasColumnas,GrillasColumnasCautas,0,LengthPC),
    transpose(GrillasColumnasCautas,Out),!.
                 
                 
generarFilasCautas(_GrillaIN,_Pistas,[],Length,Length).
generarFilasCautas(GrillaIN,Pistas,[RowCauta|GrillaOut],Index,Length):-
    getRow(GrillaIN,Index,Row),
    getClue(Index,Pistas,PistaObtenida),
    length(Row,L),
    filaCauta(Row,PistaObtenida,L,RowCauta),
    I is Index+1, 
    generarFilasCautas(GrillaIN,Pistas,GrillaOut,I,Length).
    


pasadaFinal(GrillaIn, PistasFila, PistasCol, GrillaOut):-
	pasadaFinalAux(GrillaIn, PistasFila, PistasCol, [], GrillaOut).

% checkInitCol(Grilla,Length,Length,ColClue,RES).

pasadaFinalAux(_GrillaIn,[],PistasColumna,Acumulado,GrillaOut):-
    length(PistasColumna,LengthCol),
    checkInitCol(Acumulado,0,LengthCol,PistasColumna,CheckColumna),
    allE(1,CheckColumna),
    GrillaOut = Acumulado.

pasadaFinalAux([Fila|Resto],[_P|RestoPistas],PistasColumna,Acumulado,GrillaOut):- 
	forall(member(Elem,Fila), not(isVoid(Elem))),
    append(Acumulado, [Fila], ListaAux),
    pasadaFinalAux(Resto,RestoPistas, PistasColumna, ListaAux, GrillaOut).

pasadaFinalAux([Fila|Resto], [PrimeraPistaFila|RestoPistasFila], PistasCol, Acumulado, GrillaOut):-
	generarPosibles(Fila,PrimeraPistaFila), 
	append(Acumulado, [Fila], ListaAux),
	pasadaFinalAux(Resto, RestoPistasFila, PistasCol, ListaAux, GrillaOut).

           

%primeraPasada(GrillaIn,PistasFila,PistasColumna,GrillaFinal):-
solucion(GrillaIn,PistasFila,PistasColumna,GrillaFinal):-
    primeraPasada(GrillaIn,PistasFila,PistasColumna,GrillaPrimeraPasada),
    segundaPasada(GrillaPrimeraPasada, PistasFila, PistasColumna,GrillaSegundaPasada),
    pasadaFinal(GrillaSegundaPasada, PistasFila, PistasColumna, GrillaFinal).




%Estandarizar si usamos not is o \=
%Cambiar nombres
%Comentar bien
%Comentar que por eficiencia el length en primera pasada se pasa como parametro
%A ingles
%transpose
%%en el segunda pasada caso base no usamos check init para evitar que se realice todo.
%Cut en la 290 pq pasaba hacia redu de un solo caso


%% \+ /1   
%% not(member...
% \+(member...

%solucion([[_,_,_,_,_,_],
%         [_,_,_,_,_,_],
%          [_,_,_,_,_,_],
%         [_,_,_,_,_,_],
%          [_,_,_,_,_,_]], 
%         [[2,1],[1,1],[2],[1,1],[1,1]],
%         [[1,1],[2],[1,1],[2],[1,2]],
%         GrillaOut).

%trace, solucion([[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ],
%	[_, _ , _ ,_ , _ , _ ,_, _ , _ , _ ]], 
 %       [[2], [2,3], [1,2], [2,4], [7], [5,2], [9], [2,5], [2,2], [2]],
  %       [[1,1], [3,3], [5], [1,3], [2,5,1], [9], [8], [2,2], [4], [2]],
   %      GrillaOut).





	