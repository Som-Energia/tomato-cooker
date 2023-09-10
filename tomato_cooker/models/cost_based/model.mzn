% minizinc model.mzn data-full.dzn  -a --solver coinbc
/*
Some MiniZinc basics for Pythoners (what we hardly learnt, still fuzzy):

- par values (not marked as var) are values fixed at init
  they do not depend on the solution, just on the problem.

- unitialized par values are the parameters of the problem
  and must be provided from outside (python or dzn file).

- var values are part of the solution
	- The more var values the bigger is the solution space,
	  so if some intermediate value is to be computed,
	  do not store as a value, make it a function.

- We want to comunicate cost generators to the Python code.
	- In order to make a value available from Python as
	  a solution attribute, use the annotation ::add_to_output
	- Those values must be var but because we don't want
	  to increase the search space, we mark them with
	  ::output_only
	- var values and add_to_output values do not mix
	  well together (why?) we had to duplicate the functions
	  to compute the cost and to output the cost generator (why!?)
	- Uses of actual output (timetable) in output_only
	  expressions must be wrapped by fix() (why?)
*/

enum days;
enum names;
int: nHours;
int: nDays = card(days);
int: nPersons = card(names);
set of names: Persons = names;
set of names: Nobodies;
set of names: Somebody = Persons diff Nobodies;
set of days: Days = days;
set of int: Hours = 1..nHours;
set of int: InnerHours = 2..nHours-1;
set of int: DailyHourCount = 0..maxPersonLoadPerDay;
set of int: WeeklyHourCount = 0..maxPersonLoadPerDay*nDays;
int: nLines;
int: maxPersonLoadPerDay;

array[Persons] of int: maxLoad;
array[Days, Hours] of set of Persons: busy;
array[Days, Hours] of set of Persons: undesired;
array[Days, Hours] of set of Persons: forced;
array[Days, Hours] of var set of Persons: timetable ::add_to_output;
var int: cost ::add_to_output;

int: timetableSize = nDays * nHours * nLines;

int: penaltyUndesiredHours =  5; % When includes turn someone has marked as undesired
int: penaltyMultipleHours = 10; % Multiplies by n(n-1) being n the turns a given person is assigned each day
int: penaltyNoBrunch = 10; % Every time someone is assigned in a day the two middle turns of the day (no brunch time)
int: penaltyFarDiscontinuousHours = 20; % Every time some one has two non continuous torns in a day
int: penaltyDiscontinuousHours = 30; % Every time some one has two non continuous torns in a day
int: penaltyMarathon = 40; % Every time someone is assigned in a day three turns without stop
int: penaltyUnforced = 50; % Tp apply to every fixed turn not applied
int: penaltyEmpty = 100; % To apply to the square of the empty turns each turn


% helper: targetLoad
int: targetLoad = sum(
	p in Persons
)(
	maxLoad[p]
);

constraint assert(targetLoad = timetableSize,
	"The sum of loads (" ++
	format(targetLoad) ++
	") does not match the timetable size (" ++
	format(timetableSize) ++
	")"
);

% helper: forcedWithoutBusy
array[Days, Hours] of set of Persons: forcedWithoutBusy = array2d(
	Days, Hours, [
	forced[d,h] diff busy[d,h]
	|
	d in Days,
	h in Hours
]);

/*
% helper: nForcedPerPerson
array[Persons] of 0..maxPersonLoadPerDay*nDays: nForcedPerPerson = [
	sum(
		d in Days,
		h in Hours
	)(
		bool2int(p in  forcedWithoutBusy[d,h])
	) |
	p in Persons
];
*/

function var WeeklyHourCount: personLoad(Persons: p) = (
	sum([1 |
		d in Days,
		h in Hours
		where p in timetable[d,h]
	])
);

function par WeeklyHourCount: personLoad_fixed(Persons: p) = (
	sum([1 |
		d in Days,
		h in Hours
		where p in fix(timetable[d,h])
	])
);

function var DailyHourCount: dailyPersonLoad(Days: d, Persons: p, array[Days,Hours] of var set of Persons: t) = (
	sum([1 |
		h in Hours
		where p in t[d,h]
	])
);

% All slot are filled
constraint forall(
	d in Days,
	h in Hours
)(
	card(timetable[d,h]) <= nLines
);

% Person load is not over its max load
constraint forall(
	p in Somebody
)(
	personLoad(p) <= maxLoad[p]
);

% Daily person load is not above max
constraint forall(
	p in Somebody, % Do not count Nobodies
	d in Days
)(
	dailyPersonLoad(d,p, timetable) <= maxPersonLoadPerDay
);

% A person has no turn in busy hours
constraint forall(
	d in Days,
	h in Hours,
	p in Somebody
)(
	¬ ( p in busy[d,h] /\ p in timetable[d,h] )
);

/*
% Forced turns for a person are respected,
% unless the person is busy or
% it has less load than the forced turns
% In the later case, all resulting turns for the person
% in the day should be forced
% TODO: Forced for the day/hour > nLines
% TODO: Forced for the person/day > min(maxLoadPerDay, nHours)
constraint forall(
	d in Days,
	h in Hours,
	p in Persons
)(
	if nForcedPerPerson[p] <= maxLoad[p]
	then
	(p in forcedWithoutBusy[d,h]) -> (p in timetable[d,h])
	else 
	(p in timetable[d,h]) -> (p in forcedWithoutBusy[d,h])
	endif
);
*/

function var int: patternCost(
	array[Days,Hours] of var set of Persons: timetable,
	Days: d, Persons: p,
	bool: h1, bool: h2, bool: h3, bool: h4
) = (
	bool2int(
		p in timetable[d,1] = h1 /\
		p in timetable[d,2] = h2 /\
		p in timetable[d,3] = h3 /\
		p in timetable[d,4] = h4 /\
		true
	)
);

var int: cost_daily_distributions_to_avoid(
	array[Days,Hours] of var set of Persons: t
) = sum(
	d in Days,
	p in Somebody % exclude Nobodies
)(
	% No brunch
	patternCost(t, d, p, false, true, true, false) * penaltyNoBrunch +
	% Two discontinuous turns interrupts other work
	patternCost(t, d, p, true, false, false, true) * penaltyFarDiscontinuousHours +
	patternCost(t, d, p, true, false, true, false) * penaltyDiscontinuousHours +
	patternCost(t, d, p, false, true, false, true) * penaltyDiscontinuousHours +
	% But three in a row is too maratonian
	patternCost(t, d, p, true, true, true, false) * penaltyMarathon +
	patternCost(t, d, p, false, true, true, true) * penaltyMarathon +
	0
);

var int: cost_unforced(array[Days,Hours] of var set of Persons: t) = sum(
	d in Days,
	h in Hours
)(
	card(forcedWithoutBusy[d,h] diff t[d,h])
) * penaltyUnforced;

var int: cost_emptySlots(array[Days,Hours] of var set of Persons: t) = sum(
	d in Days,
	h in Hours
)(
	% squared so is worst concentrating empty slots in one turn
	(nLines - card(t[d,h] intersect Somebody))^2
) * penaltyEmpty;

var int: cost_incompletion(array[Days,Hours] of var set of Persons: t) = sum(
	d in Days,
	h in Hours
)(
	nLines - card(t[d,h])
) * 1;

function var int: semiquadratic(var int: n) = n * (n-1);

var int: cost_dailyPersonHours(array[Days,Hours] of var set of Persons: t) = sum(
	p in Somebody, % exclude Nobodies
	d in Days
)(
	/* semiquadratic to make worse having the extra load
	spread among people than to concentrate it on one person.
	Also computing it by day, makes one person turns to spread
	among days.
	*/
	semiquadratic(
		dailyPersonLoad(d,p,t)
	)
)*penaltyMultipleHours;

var int: cost_undesiredTurns(
	array[Days,Hours] of var set of Persons: timetable,
	array[Days,Hours] of var set of Persons: undesired,
) = sum(
	d in Days,
	h in Hours
)(
	card(undesired[d,h] intersect timetable[d,h])
) * penaltyUndesiredHours;

var int: total_cost(
	array[Days,Hours] of var set of Persons: timetable,
	array[Days,Hours] of var set of Persons: undesired,
) = (0
	+ cost_unforced(timetable)
	+ cost_emptySlots(timetable)
	+ cost_incompletion(timetable)
	+ cost_daily_distributions_to_avoid(timetable)
	+ cost_dailyPersonHours(timetable)
	+ cost_undesiredTurns(timetable, undesired)
);

solve minimize(total_cost(timetable, undesired));



function array[int] of string: booleanTimetable(array[Days, Hours] of var set of Persons: source) = [
        format(d) ++ ": " ++
	concat(h in Hours)(
		if fix(p in source[d,h]) then "x" else "." endif
	) ++
        if d == nDays then " " ++ format(p) ++ "\n" else " " endif
	| p in Persons, d in Days
] ++ ["\n"];

output ["Forçats:\n"];
output booleanTimetable(forced);
output ["Indisponibilitats:\n"];
output booleanTimetable(busy);
output ["No desitjats:\n"];
output booleanTimetable(undesired);
output ["Forçats sense indisponibilitats:\n"];
output booleanTimetable(forcedWithoutBusy);
output ["Horari final\n"];
output booleanTimetable(timetable);

int: completion ::output_only ::add_to_output = sum(
	d in Days,
	h in Hours
)(
	card(fix(timetable[d,h]))
);

% Empty slots includes expected Nobodies
array[int] of tuple(Days, Hours, 1..nLines): emptySlots ::output_only ::add_to_output = [
	(d, h, nLines-card(fix(timetable[d,h]) diff Nobodies)) |
	d in Days,
	h in Hours
	where card(fix(timetable[d,h]) diff Nobodies) < nLines
];
output ["Empty slots:\n"] ++ [show(emptySlots)]++["\n\n"];

array[int] of tuple(Persons, int): unplaced ::output_only ::add_to_output = [
	(p, maxLoad[p] - personLoad_fixed(p)) |
	p in Persons where maxLoad[p] != personLoad_fixed(p)
];
output ["Unplaced Load:\n"] ++ [show(unplaced)]++["\n\n"];

array[int] of tuple(Days, Hours, Persons): unforced ::output_only ::add_to_output = [
	(d, h, p) |
	d in Days,
	h in Hours,
	p in forcedWithoutBusy[d,h] diff fix(timetable[d,h])
];
output ["Unforced fixed turns:\n"] ++ [show(unforced)]++["\n\n"];

array[int] of tuple(Days, Hours, Persons): undesiredPenalties ::output_only ::add_to_output = [
	(d, h, p) |
	d in Days,
	h in Hours,
	p in (undesired[d,h] intersect fix(timetable[d,h]))
];
output ["Undesired Penalties:\n"] ++ [show(undesiredPenalties)]++["\n\n"];

array[int] of tuple(Days, Persons, DailyHourCount): concentratedLoad ::output_only ::add_to_output = [
	(d, p, fix(dailyPersonLoad(d,p,timetable))) |
	d in Days,
	p in Persons
	where fix(dailyPersonLoad(d,p,timetable))>1
];
output ["Concentrated Load Penalties:\n"] ++ [show(concentratedLoad)]++["\n\n"];

array[int] of tuple(Days, Persons): patternOccurrences(bool: h1, bool: h2, bool: h3, bool: h4) = [
	(d, p) |
	d in Days,
	p in Somebody % Exclude Nobodies
	where fix(patternCost(fix(timetable), d, p, h1, h2, h3, h4)) > 0
];

array[int] of tuple(Days, Persons): discontinuousPenalties ::output_only ::add_to_output = (
	patternOccurrences(true, false, true, false) ++
	patternOccurrences(false, true, false, true)
);
output ["Discontinuous Load Penalties:\n"] ++ [show(discontinuousPenalties)]++["\n\n"];

array[int] of tuple(Days, Persons): farDiscontinuousPenalties ::output_only ::add_to_output = (
	patternOccurrences(true, false, false, true)
);
output ["Far discontinuous Load Penalties:\n"] ++ [show(farDiscontinuousPenalties)]++["\n\n"];

array[int] of tuple(Days, Persons): marathonPenalties ::output_only ::add_to_output = (
	patternOccurrences(false, true, true, true) ++
	patternOccurrences(true, true, true, false)
);
output ["Marathon Load Penalties:\n"] ++ [show(marathonPenalties)]++["\n\n"];

array[int] of tuple(Days, Persons): noBrunchPenalties ::output_only ::add_to_output = (
	patternOccurrences(false, true, true, false)
);
output ["No Brunch Penalties:\n"] ++ [show(noBrunchPenalties)]++["\n\n"];


constraint cost = total_cost(timetable, undesired);

output ["Solution cost: " ++ format(total_cost(timetable, undesired))++"\n"];
output [show2d(timetable)]++["\n\n"];

