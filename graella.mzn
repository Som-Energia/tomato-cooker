% Use this editor as a MiniZinc scratch book

include "all_different_except_0.mzn";

int: nPersones;
int: nLinies;
int: nSlots;
int: N = nLinies * nSlots;
int: nNingus;
int: nDies;
int: maxTorns;
array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDies] of set of 1..nSlots: indisponibilitats;

%%el numero de nngus de la setmana l'entrarem per paràmetre
int: nNingusGastats;


array[1..nDies, 1..nSlots, 1..nLinies] of var 0..nPersones: graella;
array[1..nPersones] of var 0..maxTorns*nDies: nTornsPersonaSetmana;

array[1..nPersones, 1..nDies] of var 0..maxTorns: nTornsPersonaDia;



array[1..nDies, 1..nSlots] of var 0..nNingus: nNingusTorn;

var int: diferencies;


%que una persona no estigui a dues línies del mateix torn
constraint forall(s in 1..nSlots, d in 1..nDies)(
              all_different_except_0( [ graella[d,s,l] | l in 1..nLinies ]));

constraint forall(p in 1..nPersones)
(sum([(graella[d,s,l] == p) | s in 1..nSlots, l in 1..nLinies, d in 1..nDies]) == nTornsPersonaSetmana[p]);

%controlar indisponibilitats
constraint forall(p in 1..nPersones, d in 1..nDies, s in 1..nSlots)
 (s in indisponibilitats[p,d] -> (not (p  in {graella[d,s,l]  | l in 1..nLinies})));

constraint forall(p in 1..nPersones, d in 1..nDies) 
(sum([(graella[d,s,l] == p) | s in 1..nSlots, l in 1..nLinies]) == nTornsPersonaDia[p, d]);

constraint (sum([nNingusTorn[d,s] | d in 1..nDies, s in 1..nSlots]) <= nNingusGastats);

%complir max ningus per slot
constraint forall(d in 1..nDies, s in 1..nSlots) 
  (sum([(graella[d,s,l] == 0) | l in 1..nLinies]) == nNingusTorn[d, s]);

%complir el mínim
constraint forall(p in 1..nPersones)(nTornsPersonaSetmana[p]<= nTorns[p]);

constraint max([nTorns[p]-nTornsPersonaSetmana[p] | p in 1..nPersones]) = diferencies;
solve :: int_search(graella, first_fail, indomain_random) minimize diferencies; 
%
%solve ::  int_search(graella, first_fail, indomain_random) satisfy;

%output ["slot: \(j)-persona: \(i)\n" | i,j in graella ];

output  [ show_int(2,graella[d,s,l]) ++ " " ++ 
         if l mod nLinies == 0 then "\n" else "" endif ++
         if s == nSlots /\ l == nLinies then "\n--------\n" else "" endif
         | d in 1..nDies, s in 1..nSlots, l in 1..nLinies ] 
         ++[ "\n\n nDies: \(nDies), nSlots:\(nSlots) , nLinies: \(nLinies)" ++ "\n" ] ++ ["\(p), " | p in nTornsPersonaSetmana];
