
:- module(init, [ init/3 ]).

init(
[[2,2], [1], [1,1], [1,1,1], [2]],	% PistasFilas

[[1,1], [2,1], [3], [1], [1,2]], 	% PistasColumnas

[["#", "#" , _ , "#" , _ ], 		
 ["X", _ , _ , _ , _ ],
 [_, _ , _ , _ , _ ],		% Grilla
 ["#", _, _ , _ , _ ],
 [_ , _ , _,_, "X"]
]
).