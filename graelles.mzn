int: nPersones;
int: nLinies;
int: nSlots;
int: nNingus;
int: nDies;
int: maxTorns;
array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDies] of set of 0..nSlots: indisponibilitats;
var (nSlots*(nLinies-2))..(nSlots*nLinies): totalTorns;

%cada slot té un set de persones que (d'aquesta forma ja assegurem que no es repeteix persona a un slot)
array[1..nDies, 1..nSlots] of var set of 1..nPersones: ocupacioSlot;
%dual
array[1..nDies, 1..nPersones] of var set of 1..nSlots: ocupacioPersona;
%matriu que guarda quan torns fa cada persona per dia
array[1..nDies ,1..nPersones] of var 0..nSlots: tornsPerDiaPersona;

constraint forall (i in 1..nDies, j in 1..nSlots, k in 1..nPersones) (((card(ocupacioSlot[i,j])>=(nLinies-nNingus) /\ (card(ocupacioSlot[i,j])<=(nLinies))) /\ ((k in ocupacioSlot[i,j]) -> (j in ocupacioPersona[i,k])))); 

%comprovar que no toca quan no es pot
constraint forall (i in 1..nDies, j in 1..nPersones) (ocupacioPersona[i,j] intersect indisponibilitats[j,i] = {});
% "emplenar" tornsPerDiaPersonaIT  
constraint forall (i in 1..nDies, j in 1..nPersones) (tornsPerDiaPersona[i,j] = card(ocupacioPersona[i,j]));
%Alternativament Comprovar que no es fan el màxim de torns (2) en un dia
constraint forall (i in 1..nDies, j in 1..nPersones) (tornsPerDiaPersona[i,j] <= maxTorns);
%comprovar que fa igual o menys torns del que li toca
constraint forall (i in 1..nPersones) (sum(tornsPerDiaPersona[..,i]) <= nTorns[i]);

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
%per començar satisfy però seria maximize persones/ minimize forats
%fer servir el coin!!!
solve satisfy; 