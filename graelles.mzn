int: nPersones;
int: nLinies;
int: nSlots;
int: nNingus;
int: nDies;
int: maxTorns;
array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDies] of set of 0..nSlots: indisponibilitats;
