include "alldifferent.mzn";

int: nPersones;
int: nLinies;
int: nSlots;
int: nNingus;
int: nDies;
int: maxTorns;

array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDies] of set of 1..nSlots: indisponibilitats;

array[1..nPersones, 1..nDies] of var set of 1..nSlots: persones;
array[1..nSlots, 1..nDies] of var set of 1..nPersones: graella;

array[1..nPersones, 1..nDies] of var int: nTornsPersona;

array[1..nPersones, 1..nDies] of var int: nTornsPersonaSetmana;

% Slot: 4 slots
% Torn: Una línia telefònica d'un slot

% Una mateixa persona no pot fer més de X torns al dia
constraint forall(i in 1..nPersones, j in 1..nDies) (
  nTornsPersona[i, j] == card(persones[i, j])
);

% Una mateixa persona ha de fer màxim X torns a la setmana
constraint forall(i in 1..nPersones) (
  sum(nTornsPersona[i, ..]) <= nTorns[i]
);

% Restricció nombre de persones per slot
constraint forall(i in 1..nSlots, j in 1..nDies) (
  card(graella[i, j]) >= (nLinies - nNingus) /\ card(graella[i, j]) <= (nLinies) 
);

% Una mateixa persona no pot fer més de X torns al dia
constraint forall(i in 1..nPersones, j in 1..nDies) (
  card(persones[i, j]) <= maxTorns
);

% INICI CADENA
% Si una persona té assignat un torn a "persones" apareix a l'slot de la graella 
constraint forall(i in 1..nPersones, j in 1..nDies) ( 
  forall(k in persones[i, j]) (
    i in graella[k, j]
  )
);

% Si una persona està a un slot de "graella" apareix a persones
constraint forall(i in 1..nSlots, j in 1..nDies) (
  forall(k in graella[i, j]) (
    i in persones[k, j]
  )
);

% Cada persones pot definir una indisponibilitat
constraint forall(i in 1..nPersones, j in 1..nDies) ( 
  persones[i, j] intersect indisponibilitats[i, j] = {}
);

% FI CADENA

output ["\n--- DIA 1 ---\n"];

output [show(graella[i, 1]) ++ 
      "\n" |
      i in 1..nSlots
];
output ["\n------------\n"];
output [show(persones[i, 1]) ++ 
      "\n" |
      i in 1..nPersones
];

output ["\n--- DIA 2 ---\n"];

output [show(graella[i, 2]) ++ 
      "\n" |
      i in 1..nSlots
];
output ["\n------------\n"];
output [show(persones[i, 2]) ++ 
      "\n" |
      i in 1..nPersones
];

output ["\n--- DIA 3 ---\n"];

output [show(graella[i, 3]) ++ 
      "\n" |
      i in 1..nSlots
];
output ["\n------------\n"];
output [show(persones[i, 3]) ++ 
      "\n" |
      i in 1..nPersones
];

output ["\n--- DIA 4 ---\n"];

output [show(graella[i, 4]) ++ 
      "\n" |
      i in 1..nSlots
];
output ["\n------------\n"];
output [show(persones[i, 4]) ++ 
      "\n" |
      i in 1..nPersones
];

output ["\n--- DIA 5 ---\n"];

output [show(graella[i, 5]) ++ 
      "\n" |
      i in 1..nSlots
];
output ["\n------------\n"];
output [show(persones[i, 5]) ++ 
      "\n" |
      i in 1..nPersones
];

output [show(sum(nTornsPersona[.., ..]))];

output [show(sum(nTornsPersona))];
output ["\n------------\n"];
output [show(nTornsPersona)];

solve maximize sum(nTornsPersona[.., ..]);