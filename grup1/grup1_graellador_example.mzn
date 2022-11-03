% Use this editor as a MiniZinc scratch book
int: nPersones;
int: nLinies;
int: nFiles;
int: nNingus;
int: nPersonesNingus;
int: nDies;
int: maxTornsPerDia;
int: mimaxTornsSetmana = 2;
array[1..nPersones] of int: maxTornsSetmana;
array[1..nPersones, 1..nDies] of set of 1..nFiles: indisponibilitats;


array[1..nDies,1..nFiles,1..nLinies] of var 1..nPersonesNingus: graella;


int: tornsIdeals;

include "alldifferent.mzn";
include "count.mzn";
include "at_most.mzn";
include "at_least.mzn";

nLinies=8;
nFiles=4;
nNingus=2;
nPersones=32;
% nPersones+1 i nPersones+2 són ningus (33,34)
nPersonesNingus=nPersones+nNingus;
% set of nPersones..nPersonesNingus: ningus;
set of int: ningus = nPersones+1..nPersonesNingus;
nDies=5;
tornsIdeals = nLinies*nFiles*nDies div nPersones;
maxTornsPerDia=2;
maxTornsSetmana = [9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9];
indisponibilitats = [| {1,3,4}, {1}, {1}, {1}, {1}, 
| {2}, {2}, {2}, {2}, {2},
| {3}, {3}, {3}, {3}, {3}, 
| {4}, {4}, {4}, {4}, {4}, 
| {1}, {2}, {3}, {4}, {1}, 
| {2}, {3}, {4}, {1}, {2}, 
| {3}, {4}, {1}, {2}, {3},
| {4}, {1}, {2}, {3}, {4}, 
| {4}, {3}, {2}, {1}, {4},
| {2}, {1}, {3}, {4}, {2},
| {1}, {2}, {3}, {4}, {1}, 
| {2}, {3}, {4}, {1}, {2}, 
| {3}, {4}, {1}, {2}, {3},
| {4}, {1}, {2}, {3}, {4}, 
| {4}, {3}, {2}, {1}, {4},
| {2}, {1}, {3}, {4}, {2},
| {1}, {1}, {1}, {1}, {1}, 
| {2}, {2}, {2}, {2}, {2},
| {3}, {3}, {3}, {3}, {3}, 
| {4}, {4}, {4}, {4}, {4}, 
| {1}, {2}, {3}, {4}, {1}, 
| {2}, {3}, {4}, {1}, {2}, 
| {3}, {4}, {1}, {2}, {3},
| {4}, {1}, {2}, {3}, {4}, 
| {4}, {3}, {2}, {1}, {4},
| {2}, {1}, {3}, {4}, {2},
| {1}, {2}, {3}, {4}, {1}, 
| {2}, {3}, {4}, {1}, {2}, 
| {3}, {4}, {1}, {2}, {3},
| {4}, {1}, {2}, {3}, {4}, 
| {4}, {3}, {2}, {1}, {4},
| {2}, {1}, {3}, {4}, {2},
|];


% [FET] 1 setmana -> 5 dies
% [FET] Cada dia matriu X slots Y línies (4 i 8)
% [FET] Una persona no pot estar a dues línies a la vegada
% Cada slot pot tenir un màxim de N ningús (2)
% [FET] Una persona pot tenir un màxim de MAX torns per dia (2)
% [CHANGE] Una persona ha de fer un mínim de MIN torns a la setmana --> maxim torns per setmana
% Una persona pot demanar no estar en un conjunt de torns determinat (pex: dijous a primera hora) o de vacances tot el dia.

% en una hora només pots estar en un telèfon, a més hi ha dues persones ningus
constraint forall(dia in 1..nDies, fila in 1..nFiles)(alldifferent(graella[dia,fila,1..nLinies]));

% una persona no pot fer més de dos telèfons en un dia
% constraint forall(dia in 1..nDies, persona in 1..nPersones)(at_most(2,graella[dia,1..nFiles,1..nLinies],persona));

constraint forall(dia in 1..nDies, persona in 1..nPersones)(count(persona_i in graella[dia,1..nFiles,1..nLinies])(persona_i=persona) <= maxTornsPerDia);

% una persona no pot fer més dels seus maxTorns en una setmana
% constraint forall(persona in 1..nPersones)(at_most(maxTornsSetmana[persona],graella[1..nDies,1..nFiles,1..nLinies],persona));

constraint forall(persona in 1..nPersones)(count(persona_i in graella[1..nDies,1..nFiles,1..nLinies])(persona_i=persona) <= maxTornsSetmana[persona]);

% les persones poden demanar no fer telèfon en hores concretes
constraint forall(persona in 1..nPersones, dia in 1..nDies, fila in 1..nFiles, linia in 1..nLinies)(not (fila in indisponibilitats[graella[dia,fila,linia],dia]));



output ["foo \(graella[1,1,1]) constraint \((1 in indisponibilitats[1,1]))\n"];

% this should not be satisfiable
% constraint graella[1,1,1] = 1;

% this should be satisfiable and is not
% constraint graella[1,2,1] = 1;

% minimitzar el nombre de ningus
%solve minimize count(persona_i in graella[1..nDies,1..nFiles,1..nLinies])(persona_i in ningus);

% intent de minimitzar les persones repetidores
% solve minimize count(persona_i in graella[1..nDies,1..nFiles,1..nLinies])(persona_i in 1..nPersonesNingus);

% solve minimize count(persona_i in graella[1..nDies,1..nFiles,1..nLinies])(persona_i in ningus);

output ["\(count(persona_i in graella[1..nDies,1..nFiles,1..nLinies])(persona_i in 1..nPersonesNingus)))"];



output ["dilluns\n"];
output ["\(graella[1,fila,1..nLinies])\n" | fila in 1..nFiles];
output ["dimarts\n"];
output ["\(graella[2,fila,1..nLinies])\n" | fila in 1..nFiles];
output ["dimecres\n"];
output ["\(graella[3,fila,1..nLinies])\n" | fila in 1..nFiles];
output ["dijous\n"];
output ["\(graella[4,fila,1..nLinies])\n" | fila in 1..nFiles];
output ["divendres\n"];
output ["\(graella[5,fila,1..nLinies])\n" | fila in 1..nFiles];

output ["ningus: \(ningus)"]



