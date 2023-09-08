% minizinc model.mzn data-full.dzn  -a --solver COIN-BC
enum days;
enum names;
int: nHours;
int: nDays = card(days);
int: nPersons = card(names);
set of names: Persons = names;
set of names: Nobodies;
set of days: Days = days;
set of int: Hours = 1..nHours;
set of int: InnerHours = 2..nHours-1;
set of int: DailyHourCount = 0..maxPersonLoadPerDay;
set of int: WeeklyHourCount = 0..maxPersonLoadPerDay*nDays;
int: nLines;
int: maxPersonLoadPerDay;

array[Persons] of int: maxLoad;
array[Days, Hours] of set of Persons: busy;
array[Days, Hours] of set of Persons: inconvenient;
array[Days, Hours] of set of Persons: forced;
array[Days, Hours] of var set of Persons: timetable;

int: timetableSize = nDays * nHours * nLines;

/*
int: penaltyInconvenientHours =  5; % When includes turn someone has marked as inconvenient
int: penaltyMultipleHours = 10; % Multiplies by n(n-1) being n the turns a given person is assigned each day
int: penaltyNoBrunch = 10; % Every time someone is assigned in a day the two middle turns of the day (no brunch time)
int: penaltyFarDiscontinuousHours = 20; % Every time some one has two non continuous torns in a day
int: penaltyDiscontinuousHours = 30; % Every time some one has two non continuous torns in a day
int: penaltyMarathon = 40; % Every time someone is assigned in a day three turns without stop
*/

int: penaltyInconvenientHours; % When includes turn someone has marked as inconvenient
int: penaltyMultipleHours; % Multiplies by n(n-1) being n the turns a given person is assigned each day
int: penaltyNoBrunch; % Every time someone is assigned in a day the two middle turns of the day (no brunch time)
int: penaltyDiscontinuousHours; % Every time some one has two non continuous torns in a day
int: penaltyFarDiscontinuousHours; % Every time some one has two non continuous torns in a day
int: penaltyMarathon; % Every time someone is assigned in a day three turns without stop

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

function var WeeklyHourCount: personLoad(Persons: p) = (
	sum([1 |
		d in Days,
		h in Hours
		where p in timetable[d,h]
	])
);

function var DailyHourCount : dailyPersonLoad(Days: d, Persons: p, array[Days,Hours] of var set of Persons: t) = (
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
	card(timetable[d,h]) = nLines
);

% Person load is not over its max load
constraint forall(
	p in Persons
)(
	personLoad(p) = maxLoad[p]
);


% Daily person load is not above max
constraint forall(
	p in Persons,
	d in Days
)(
	dailyPersonLoad(d,p, timetable) <= maxPersonLoadPerDay
);

% A person has no turn in busy hours
constraint forall(
	d in Days,
	h in Hours,
	p in Persons
)(
	¬ ( p in busy[d,h] /\ p in timetable[d,h] )
);

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

var int: cost_inconvenient_daily_distributions(
	array[Days,Hours] of var set of Persons: t
) = sum(
	d in Days,
	p in Persons diff Nobodies
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

function var int: semiquadratic(var int: n) = n * (n-1);

var int: cost_dailyPersonHours(array[Days,Hours] of var set of Persons: t) = sum(
	p in Persons,
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

var int: cost_inconvenientTurns(
	array[Days,Hours] of var set of Persons: timetable,
	array[Days,Hours] of var set of Persons: inconvenient,
) = sum(
	d in Days,
	h in Hours
)(
	card(inconvenient[d,h] intersect timetable[d,h])
) * penaltyInconvenientHours;

var int: total_cost(
	array[Days,Hours] of var set of Persons: timetable,
	array[Days,Hours] of var set of Persons: inconvenient,
) = (
	cost_inconvenient_daily_distributions(timetable) +
	cost_dailyPersonHours(timetable) +
	cost_inconvenientTurns(timetable, inconvenient)
);

solve minimize(total_cost(timetable, inconvenient));



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
output ["Forçats sense indisponibilitats:\n"];
output booleanTimetable(forcedWithoutBusy);
output ["Horari final\n"];
output booleanTimetable(timetable);
output ["Solution cost: " ++ format(total_cost(timetable, inconvenient))++"\n"];


output [show2d(timetable)];
%output [show2d([fix(personLoad(p)) | p in Persons])];

