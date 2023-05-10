int: nPersones;
int: nLinies;
int: nSlots;
int: nNingus;
int: nDies;
int: maxTorns;
array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDies] of set of 1..nSlots: indisponibilitats;
array[1..nPersones, 1..nDies] of set of 1..nSlots: preferencies;
var (nDies*nSlots*(nLinies-nNingus))..(nDies*nSlots*nLinies): totalTorns;

%cada slot té un set de persones que (d'aquesta forma ja assegurem que no es repeteix persona a un slot)
array[1..nDies, 1..nSlots] of var set of 1..nPersones: ocupacioSlot;

%dual
array[1..nDies, 1..nPersones] of var set of 1..nSlots: ocupacioPersona;
%matriu que guarda quan torns fa cada persona per dia
array[1..nDies ,1..nPersones] of var 0..nSlots: tornsPerDiaPersona;
%array de torns que es fan cada dia
array[1..nDies] of var (nSlots*(nLinies-nNingus))..(nSlots*nLinies): tornsPerDia;

%mother of all constraints
constraint forall (d in 1..nDies, s in 1..nSlots, p in 1..nPersones) (((card(ocupacioSlot[d,s])>=(nLinies-nNingus) /\ (card(ocupacioSlot[d,s])<=(nLinies))) /\ ((p in ocupacioSlot[d,s]) <-> (s in ocupacioPersona[d,p])))); 

%comprovar que no toca quan no es pot
constraint forall (d in 1..nDies, p in 1..nPersones) (ocupacioPersona[d,p] intersect indisponibilitats[p,d] = {});
%comprovar que toca quan es vol
constraint forall (d in 1..nDies, p in 1..nPersones) (preferencies[p,d] subset ocupacioPersona[d,p]);
% "emplenar" tornsPerDiaPersonaIT
constraint forall (d in 1..nDies, p in 1..nPersones) (tornsPerDiaPersona[d,p] = card(ocupacioPersona[d,p]));
%Alternativament Comprovar que no es fan el màxim de torns (2) en un dia
constraint forall (d in 1..nDies, p in 1..nPersones) (tornsPerDiaPersona[d,p] <= maxTorns);
%comprovar que si la pesona te el màxim de torns (2) en un dia son consecutius
constraint forall (d in 1..nDies, p in 1..nPersones, s in 2..nSlots-1) (if tornsPerDiaPersona[d,p] == maxTorns /\ s in ocupacioPersona[d,p] then s-1 in ocupacioPersona[d,p] \/ s+1 in ocupacioPersona[d,p] else true endif);
%comprovar que fa igual o menys torns del que li toca
constraint forall (p in 1..nPersones) (sum(tornsPerDiaPersona[..,p]) <= nTorns[p]);

constraint forall(d in 1..nDies) (tornsPerDia[d] = sum(tornsPerDiaPersona[d,..]));

constraint totalTorns = sum(tornsPerDia);

int: tornsDisponibles = sum(nTorns);

output ["Taula ocupacioSlot\n"];
output [ show(ocupacioSlot[d,s]) ++
        if s == nSlots then "\n" else " " endif|
         d in 1..nDies, s in 1..nSlots
];
output ["\n\n"];
output ["Taula ocupacioPersona\n"];
output [ show(ocupacioPersona[d,p]) ++
        if p == nPersones then "\n" else " " endif|
         d in 1..nDies, p in 1..nPersones
];

output ["\n\n"];
output ["Taula tornsPerDiaPersona\n"];
output [ show(tornsPerDiaPersona[d,p]) ++
        if p == nPersones then "\n" else " " endif|
         d in 1..nDies, p in 1..nPersones
];

output ["\n\n"];
output ["Taula tornsPerDia\n"];
output [ show(tornsPerDia[d]) ++  " " |
         d in 1..nDies
];

output ["\n\n"];
output ["TornsDisponibles\n"];
output [ show(tornsDisponibles)];

output ["\n\n"];
output ["TotalTorns\n"];
output [ show(totalTorns)];


%per començar satisfy però seria maximize persones/ minimize forats
%fer servir el coin!!!
solve maximize totalTorns; 