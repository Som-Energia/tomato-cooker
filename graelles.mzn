int: nPersones;
int: nLinies;
int: nSlots;
int: nNingus;
int: nDies;
int: maxTorns;
array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDies] of set of 1..nSlots: indisponibilitats;
var (nDies*nSlots*(nLinies-nNingus))..(nDies*nSlots*nLinies): totalTorns;

%cada slot té un set de persones que (d'aquesta forma ja assegurem que no es repeteix persona a un slot)
array[1..nDies, 1..nSlots] of var set of 1..nPersones: ocupacioSlot;
%dual
array[1..nDies, 1..nPersones] of var set of 1..nSlots: ocupacioPersona;
%matriu que guarda quan torns fa cada persona per dia
array[1..nDies ,1..nPersones] of var 0..maxTorns: tornsPerDiaPersona;
%array de torns que es fan cada dia
array[1..nDies] of var (nSlots*(nLinies-nNingus))..(nSlots*nLinies): tornsPerDia;

%mother of all constraints
constraint forall (i in 1..nDies, j in 1..nSlots, k in 1..nPersones) (((card(ocupacioSlot[i,j])>=(nLinies-nNingus) /\ (card(ocupacioSlot[i,j])<=(nLinies))) /\ ((k in ocupacioSlot[i,j]) <-> (j in ocupacioPersona[i,k])))); 

%comprovar que no toca quan no es pot
constraint forall (i in 1..nDies, j in 1..nPersones) (ocupacioPersona[i,j] intersect indisponibilitats[j,i] = {});
% "emplenar" tornsPerDiaPersona  
constraint forall (i in 1..nDies, j in 1..nPersones) (tornsPerDiaPersona[i,j] = card(ocupacioPersona[i,j]));
%Alternativament Comprovar que no es fan el màxim de torns (2) en un dia
constraint forall (i in 1..nDies, j in 1..nPersones) (tornsPerDiaPersona[i,j] <= maxTorns);
%comprovar que fa igual o menys torns del que li toca
constraint forall (i in 1..nPersones) (sum(tornsPerDiaPersona[..,i]) <= nTorns[i]);
%calcul del total de torns
constraint forall(i in 1..nDies) (tornsPerDia[i] = sum(tornsPerDiaPersona[i,..]));

constraint totalTorns = sum(tornsPerDia);

int: tornsDisponibles = sum(nTorns);

output ["Taula ocupacioSlot\n"];
output [ show(ocupacioSlot[i,j]) ++ 
        if j == nSlots then "\n" else " " endif|
         i in 1..nDies, j in 1..nSlots
];
output ["\n\n"];
output ["Taula ocupacioPersona\n"];
output [ show(ocupacioPersona[i,j]) ++ 
        if j == nPersones then "\n" else " " endif|
         i in 1..nDies, j in 1..nPersones
];

output ["\n\n"];
output ["Taula tornsPerDiaPersona\n"];
output [ show(tornsPerDiaPersona[i,j]) ++ 
        if j == nPersones then "\n" else " " endif|
         i in 1..nDies, j in 1..nPersones
];

output ["\n\n"];
output ["Taula tornsPerDia\n"];
output [ show(tornsPerDia[i]) ++  " " |
         i in 1..nDies
];

output ["\n\n"];
output ["TornsDisponibles\n"];
output [ show(tornsDisponibles)];

output ["\n\n"];
output ["TotalTorns\n"];
output [ show(totalTorns)];

solve maximize totalTorns; 
