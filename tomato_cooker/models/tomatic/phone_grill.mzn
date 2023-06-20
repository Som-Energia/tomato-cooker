int: nPersons;
int: nLines;
int: nHours;
int: nNingus;
int: nDays;
% TODO: rename maxLoadPerDay
int: maxTorns;
enum names;

set of names: Persons = names;
set of int: Hours = 1..nHours;
set of int: InnerHours = 2..nHours-1;
set of int: HourCount = 0..nHours;
set of int: Days = 1..nDays;

constraint assert(nPersons = card(names),
	"'nPersons' (" ++ format(nPersons) ++
	") does not match the size of 'names' (" ++
	format(card(names)) ++ ")"
);


% Number of torns to be filled for each person
array[Persons] of int: nTorns;
array[Persons, Days] of set of Hours: indisponibilitats;
% Fixed turns assignments
array[Persons, Days] of set of Hours: forcedTurns;


% Fixed turns assignments after removing person's busy hours
array[Persons, Days] of var set of Hours: fixedWithoutBusy;
% Number of fixed torns per person after removing person busy
array[Persons, Days] of var HourCount: nFixedPerDiaPersona;
array[Persons] of var int: nFixedPerPerson;
% interval of valid number simultaneusly covered lines
var (nDays*nHours*(nLines-nNingus))..(nDays*nHours*nLines): totalTorns;

% Output: Who is attending phone each day/hour
array[Days, Hours] of var set of Persons: ocupacioSlot;

% Complementary to the former? Whose days/hours a person has a turn
array[Days, Persons] of var set of Hours: ocupacioPersona;
% How many turns a person does each day
array[Days, Persons] of var HourCount: tornsPerDiaPersona;
% Turns done each day by anyone
array[Days] of var (nHours*(nLines-nNingus))..(nHours*nLines): tornsPerDia;

% Determination of nFixedPerDiaPersona based on fixedWithoutBusy
constraint forall (
	p in Persons,
	d in Days
) (
	nFixedPerDiaPersona[p,d] = card(fixedWithoutBusy[p,d])
);

% nFixedPerPerson consistent with nFixedPerDiaPersona
constraint forall(
	p in Persons
) (
	nFixedPerPerson[p] = sum(nFixedPerDiaPersona[p,..])
);

% Determination of fixedWithoutBusy
constraint forall (
	d in Days,
	h in Hours,
	p in Persons
) (
	fixedWithoutBusy[p,d] = forcedTurns[p,d] diff indisponibilitats[p,d]
);

% Every day/hour should have between nLines and nLines-nNingus
% ocupacioSlot and ocupacioPersona should be consistent
constraint forall (
	d in Days,
	h in Hours,
	p in Persons
) (
	card(ocupacioSlot[d,h])>=(nLines-nNingus) /\
	card(ocupacioSlot[d,h])<=(nLines) /\
	(p in ocupacioSlot[d,h]) = (h in ocupacioPersona[d,p])
);

% Person busy hours are respected
constraint forall (
	d in Days,
	p in Persons
) (
	card(ocupacioPersona[d,p] intersect indisponibilitats[p,d])=0
);

% Person fixed torns are respected, if possible
% - Ignored when the person is busy
% - Ignored if there is less load than fixed turns
%   still all taken turns should be a subset of the fixed
constraint forall (
	d in Days,
	p in Persons
) (
	% If fixed turns for a person do not exceed its max load
	if nFixedPerPerson[p] <= nTorns[p]
	% all fixed turns should be included in the result
	then fixedWithoutBusy[p,d] subset ocupacioPersona[d,p]
	% if not, all result turns should be fixed
	else ocupacioPersona[d,p] subset fixedWithoutBusy[p,d]
	endif
);


% Determination of tornsPerDiaPersona based on ocupacioPersona
constraint forall (
	d in Days,
	p in Persons
) (
	tornsPerDiaPersona[d,p] = card(ocupacioPersona[d,p])
);

% Limit daily load to maxTorns
constraint forall (
	d in Days,
	p in Persons
) (
	tornsPerDiaPersona[d,p] <= maxTorns
);

% If a person has more than one torn the same day, they should be consecutive
constraint forall (
	d in Days,
	p in Persons,
	h in InnerHours
) (
	if tornsPerDiaPersona[d,p] == maxTorns /\
	h in ocupacioPersona[d,p] then h-1 in ocupacioPersona[d,p] \/
	h+1 in ocupacioPersona[d,p] else true endif
);

% A person does at most the weakly load assigned
constraint forall (
	p in Persons
) (
	sum(tornsPerDiaPersona[..,p]) <= nTorns[p]
);

% tornsPerDia consistent with tornsPerDiaPersona
constraint forall(
	d in Days
) (
	tornsPerDia[d] = sum(tornsPerDiaPersona[d,..])
);

% totalTorns consistent with tornsPerDia
constraint totalTorns = sum(tornsPerDia);

int: tornsDisponibles = sum(nTorns);

output ["\n\n"];
output ["Solution:\n"];
output [show2d(ocupacioSlot)];
output ["\n\n"];
output ["Taula ocupacioSlot\n"];
output [
	show(ocupacioSlot[d,h]) ++
        if h == nHours then "\n" else " " endif
	| d in Days, h in Hours
];
output ["\n\n"];
output ["Taula ocupacioPersona\n"];
output [
        format(d) ++ ": " ++
	concat(h in Hours)(
		if fix(h in ocupacioPersona[d,p]) then "x" else "." endif
	) ++
        if d == nDays then " " ++ format(p) ++ "\n" else " " endif
	| p in Persons, d in Days
];

output ["\n\n"];
output ["Taula tornsPerDiaPersona\n"];
output [show2d(tornsPerDiaPersona)];

output ["\n\n"];
output ["Taula tornsPerDia\n"];
output [ show(tornsPerDia[d]) ++  " " |
         d in Days
];

output ["\n\n"];
output [
	"Complecio: ",
	show(totalTorns),
	"/",
	show(tornsDisponibles),
	"/",
	show(nDays*nHours*nLines)
];

output ["\n\n"];
output ["indisponibilitats\n"];
output [ show2d(indisponibilitats)];

output ["\n\n"];
output ["forçats\n"];
output [ show2d(forcedTurns)];


%per començar satisfy però seria maximize persones/ minimize forats
%fer servir el coin!!!
solve maximize totalTorns;
