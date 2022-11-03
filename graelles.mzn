include "alldifferent.mzn";
include "at_most.mzn";
include "count.mzn";
include "at_least.mzn";

int: nPersones;
int: nLinies;
int: nSlots;
int: nNingus;
int: nDies;
int: maxTorns;
int: maxTornsSetmana;
array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDies] of set of 1..nSlots: indisponibilitats;

%set of int: Slots = 1..nSlots;
%set of int: Linies = 1..nLinies;
%set of int: Dies = 1..nDies;
%set of int: Persones = 1..nPersones;

enum Slots = {T1, T2, T3, T4};
enum Linies = {L1, L2, L3, L4, L5, L6, L7, L8};
enum Dies = {D1, D2, D3, D4, D5};
enum Persones = {Herminia, Joan, Gil, Marta, Oriol, Marite, Fran, Pol, Benji, Roger, Xavier, Israel, Pau, Joana, Mar, Raul, Erola, Bea, Mateu, JuanPe, Voki, Backtracking, Jordi};

%set of Persones: setPersones = 1..nPersones;

array [Linies, Slots, Dies] of var Persones: gDia; %TOTS ELS TORNS D'UNA SETMANA

constraint forall(z in Dies, y in Slots)(
  alldifferent([gDia[x,y,z] | x in Linies])
);


%array[1..23] of var int: occurs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
array[1..23] of int: occurs;

constraint forall(d in Dies, s in Slots, l in Linies, j in 1..23)(gDia[l,s,d] = j -> occurs[j]=occurs[j]+1 );

%var int: num_diff = count(occurs);

output[show(occurs) ++ "\n"];

%output[show(num_diff)++ "\n"];

% constraint forall (d in Dies, s in Slots, l in Linies) (count(Persones, d, gDia[l,s,d]));

%constraint at_most(maxTornsSetmana, gDia, Persones);

%constraint forall(x in Linies, y in Slots, z in Dies)(
%  at_most(maxTornsSetmana,gDia[x,y], 1..nPersones)
%  at_most(maxTornsSetmana,gDia, nPersones)
%);


%function var int: count_repeat_torns(z) =  (
%  array[1..nPersones] of int: CountPersones;
%  forall(x in Linies, y in Slots)(
%      CountPersones[gDia[x,y,z]] = CountPersones[gDia[x,y,z]] + 1 
%  )
%);

%constraint forall(z in gDia)(
%  % z = graella
%  forall(y in z)(
%    % y = 
%    at_most = count_repeat_torns(z)
%  );
%);



solve satisfy;

output[ 
show(x) ++ "," ++ show(y) ++ "," ++ show(z) ++ "-> ( " ++ show(gDia[x,y,z]) ++ " )" ++
if x == nLinies then "\n" else " " endif  ++
if y == nSlots /\ x == nLinies then "\n" else "" endif |
z in Dies, y in Slots, x in Linies
];
