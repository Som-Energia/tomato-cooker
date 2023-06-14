int: nPersones;
int: nLinies;
% TODO: rename nSlots -> nHours
int: nSlots;
int: nNingus;
int: nDays;
% TODO: rename maxLoadPerDay
int: maxTorns;
% Number of torns to be filled for each person
array[1..nPersones] of int: nTorns;
array[1..nPersones, 1..nDays] of set of 1..nSlots: indisponibilitats;
% Fixed turns assignments
array[1..nPersones, 1..nDays] of set of 1..nSlots: forcedTurns;
% Fixed turns assignments after removing person's busy hours
array[1..nPersones, 1..nDays] of var set of 1..nSlots: fixedWithoutBusy;
% Number of fixed torns per person after removing person busy
array[1..nPersones, 1..nDays] of var 0..nSlots: nFixedPerDiaPersona;
array[1..nPersones] of var int: nFixedPerPerson;
% interval of valid number simultaneusly covered lines
var (nDays*nSlots*(nLinies-nNingus))..(nDays*nSlots*nLinies): totalTorns;

% Output: Who is attending phone each day/hour
array[1..nDays, 1..nSlots] of var set of 1..nPersones: ocupacioSlot;

% Complementary to the former? Whose days/hours a person has a turn
array[1..nDays, 1..nPersones] of var set of 1..nSlots: ocupacioPersona;
% How many turns a person does each day
array[1..nDays ,1..nPersones] of var 0..nSlots: tornsPerDiaPersona;
% Turns done each day by anyone
array[1..nDays] of var (nSlots*(nLinies-nNingus))..(nSlots*nLinies): tornsPerDia;

% Determination of nFixedPerDiaPersona based on fixedWithoutBusy
constraint forall (
	p in 1..nPersones,
	d in 1..nDays
) (
	nFixedPerDiaPersona[p,d] = card(fixedWithoutBusy[p,d])
);

% nFixedPerPerson consistent with nFixedPerDiaPersona
constraint forall(
	p in 1..nPersones
) (
	nFixedPerPerson[p] = sum(nFixedPerDiaPersona[p,..])
);

% Determination of fixedWithoutBusy
constraint forall (
	d in 1..nDays,
	s in 1..nSlots,
	p in 1..nPersones
) (
	fixedWithoutBusy[p,d] = forcedTurns[p,d] diff indisponibilitats[p,d]
);

% Every day/hour should have between nLines and nLines-nNingus
% ocupacioSlot and ocupacioPersona should be consistent
constraint forall (
	d in 1..nDays,
	s in 1..nSlots,
	p in 1..nPersones
) (
	card(ocupacioSlot[d,s])>=(nLinies-nNingus) /\
	card(ocupacioSlot[d,s])<=(nLinies) /\
	(p in ocupacioSlot[d,s]) <-> (s in ocupacioPersona[d,p])
);

% Person busy hours are respected
constraint forall (
	d in 1..nDays,
	p in 1..nPersones
) (
	ocupacioPersona[d,p] intersect indisponibilitats[p,d] = {}
);

% Person fixed torns are respected
% TODO: ignore fixed torn if busy
% TODO: ignore fixed torns if they exceed the load
constraint forall (
	d in 1..nDays,
	p in 1..nPersones
) (
	fixedWithoutBusy[p,d] diff ocupacioPersona[d,p] = {} \/
	(
		nFixedPerPerson[p] >= nTorns[p] /\
		ocupacioPersona[d,p] diff fixedWithoutBusy[p,d] = {}
	)
);


% Determination of tornsPerDiaPersona based on ocupacioPersona
constraint forall (
	d in 1..nDays,
	p in 1..nPersones
) (
	tornsPerDiaPersona[d,p] = card(ocupacioPersona[d,p])
);

% Limit daily load to maxTorns
constraint forall (
	d in 1..nDays,
	p in 1..nPersones
) (
	tornsPerDiaPersona[d,p] <= maxTorns
);

% If a person has more than one torn the same day, they should be consecutive
constraint forall (
	d in 1..nDays,
	p in 1..nPersones,
	s in 2..nSlots-1
) (
	if tornsPerDiaPersona[d,p] == maxTorns /\
	s in ocupacioPersona[d,p] then s-1 in ocupacioPersona[d,p] \/
	s+1 in ocupacioPersona[d,p] else true endif
);

% A person does at most the weakly load assigned
constraint forall (
	p in 1..nPersones
) (
	sum(tornsPerDiaPersona[..,p]) <= nTorns[p]
);

% tornsPerDia consistent with tornsPerDiaPersona
constraint forall(
	d in 1..nDays
) (
	tornsPerDia[d] = sum(tornsPerDiaPersona[d,..])
);

% totalTorns consistent with tornsPerDia
constraint totalTorns = sum(tornsPerDia);

int: tornsDisponibles = sum(nTorns);

output ["Taula ocupacioSlot\n"];
output [ show(ocupacioSlot[d,s]) ++
        if s == nSlots then "\n" else " " endif|
         d in 1..nDays, s in 1..nSlots
];
output ["\n\n"];
output ["Taula ocupacioPersona\n"];
output [ show(ocupacioPersona[d,p]) ++
        if p == nPersones then "\n" else " " endif|
         d in 1..nDays, p in 1..nPersones
];

output ["\n\n"];
output ["Taula tornsPerDiaPersona\n"];
output [ show(tornsPerDiaPersona[d,p]) ++
        if p == nPersones then "\n" else " " endif|
         d in 1..nDays, p in 1..nPersones
];

output ["\n\n"];
output ["Taula tornsPerDia\n"];
output [ show(tornsPerDia[d]) ++  " " |
         d in 1..nDays
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
