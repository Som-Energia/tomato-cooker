import pytest

from pathlib import Path
import dataclasses
from tomato_cooker.grill import GrillTomatoCooker
from tomato_cooker.models.base import GridProblem

@dataclasses.dataclass
class TimetableScenario(GridProblem):
    names: set[str]
    Nobodies: set[str]
    maxPersonLoadPerDay: int
    maxLoad: list[int]
    days: list[str] = dataclasses.field(default_factory=lambda: [dl, dm, dx, dj, dv])
    nHours: int = 4
    nLines: int = 6
    forced: list[list[set[str]]] | None = None
    busy: list[list[set[str]]] | None = None 
    inconvenient: list[list[set[str]]] | None = None

    penaltyInconvenientHours: int = 5 # Assigning a turn someone marked as inconvenient
    penaltyMultipleHours: int = 10 # Multiple turns a day, multiplies by n(n-1) n: number of daily turns
    penaltyNoBrunch: int = 10 # Person daily distribution 0110, no time for lunch
    penaltyFarDiscontinuousHours: int = 20 # Persons daily distribution 1001, minor focus change
    penaltyDiscontinuousHours: int = 30 # Person daily distribution 1010 or 0101, focus change
    penaltyMarathon: int = 40 # Person daily distribution 1110 or 0111, need a break

    def _days_hours_matrix(self, factory):
        return [
            [
                factory()
                for _ in range(self.nHours)
            ]
            for _ in self.days
        ]

    def _add_to_days_hours_matrix(self, timetable, day, hour, persons):
        iday = self.days.index(day)
        timetable[iday][hour].update(persons)

    def __post_init__(self):
        for attrib in ('forced', 'busy', 'inconvenient'):
            if getattr(self, attrib): continue
            setattr(self, attrib, self._days_hours_matrix(set))


    def forceTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.forced, day, hour, persons)

    def busyTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.busy, day, hour, persons)

    def inconvenientTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.inconvenient, day, hour, persons)

    async def solve(self, deterministic=False):
        parent_dir = Path(__file__).parent.absolute()
        cooker = GrillTomatoCooker(
            parent_dir/'../tomato_cooker/models/cost_based/model.mzn',
            ["coinbc"],
        )
        self.result = await cooker.cook(self, deterministic=deterministic)
        return self.result


# Use global vars instead of strings to avoid unnoticed misspels
for symbol in "dl dm dx dj dv alice barb carol diane emily fanny nobody".split():
    globals()[symbol] = symbol
O = set()

def minimalScenario(**overrides):
    """One day, one line, four hours, two people and nobody"""
    return TimetableScenario(**dict(dict(
        days=['dl'],
        nLines=1,
        names=[alice, barb, nobody],
        Nobodies=[nobody],
        maxPersonLoadPerDay=2,
        maxLoad=[2,1,1],
    ), **overrides))

async def test_minimal():
    scenario = minimalScenario()
    result = await scenario.solve(deterministic=True)
    # Any solutions concentrating alice turns at
    # either side is good
    assert result.solution.timetable in [
        [[{alice}, {alice}, {barb}, {nobody}]],
        [[{alice}, {alice}, {nobody}, {barb}]],
        [[{barb}, {nobody}, {alice}, {alice}]],
        [[{nobody}, {barb}, {alice}, {alice}]],
    ]

async def test_everybody_busy__forces_nobody():
    scenario = minimalScenario()
    # Set busy Alice and Barb the same turn
    scenario.busyTurn(dl, 0, barb, alice)
    result = await scenario.solve(deterministic=True)
    # Nobody will take the turn
    assert result.solution.timetable == [
        [{nobody}, {barb}, {alice}, {alice}],
    ]

async def test_busy_alice__move_both_turns():
    scenario = minimalScenario()
    # Make Alice busy some of the later torns
    scenario.busyTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    # Only solutions with Alice doing the first two turns
    # are optimal
    assert result.solution.timetable in [
        [[{alice}, {alice}, {nobody}, {barb}]],
        [[{alice}, {alice}, {barb}, {nobody}]],
    ]
async def test_inconvenient_alice__turns_moved():
    scenario = minimalScenario()
    scenario.inconvenientTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    # When no further restrictions, inconvenient
    # hours are much like busy hours
    assert result.solution.timetable in [
        [[{alice}, {alice}, {nobody}, {barb}]],
        [[{alice}, {alice}, {barb}, {nobody}]],
    ]

async def test_inconvenient_but_everybody_else_busy__resignate():
    scenario = minimalScenario()
    # Alice don't like at fist hour
    scenario.inconvenientTurn(dl, 0, alice)
    # But Barb really can not do it a first hours
    scenario.busyTurn(dl, 0, barb)
    scenario.busyTurn(dl, 1, barb)
    result = await scenario.solve(deterministic=True)
    # Alice does the two first hours, and barb one of the last
    assert result.solution.timetable in [
        [[{alice}, {alice}, {nobody}, {barb}]],
        [[{alice}, {alice}, {barb}, {nobody}]],
    ]

async def test_nobody_available_noSolution():
    scenario = minimalScenario()
    scenario.busyTurn(dl, 0, alice, barb)
    scenario.busyTurn(dl, 1, alice, barb)
    result = await scenario.solve(deterministic=True)
    assert result.solution == None

async def test_dejeuner_constraint_ignored_if_no_other_way():
    scenario = minimalScenario()
    scenario.busyTurn(dl, 0, alice)
    scenario.busyTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable == [
        [{nobody}, {alice}, {alice}, {barb},],
    ]

async def test_fixed_turns_imposes_over_continous_turns_rule():
    scenario = minimalScenario()
    scenario.forceTurn(dl, 0, alice)
    scenario.forceTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable == [
        [{alice}, {nobody}, {barb}, {alice},],
    ]

async def test_fixed_ignored_if_also_busy():
    scenario = minimalScenario()
    scenario.busyTurn(dl, 0, alice)
    scenario.forceTurn(dl, 0, alice)
    scenario.forceTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable == [
        [{nobody}, {barb}, {alice}, {alice},],
    ]


async def test_fixed_ignored_if_exceeds_persons_max_torns():
    scenario = minimalScenario()
    # Barb just dues 1 turn, but fixes 2 turns
    scenario.forceTurn(dl, 0, barb)
    scenario.forceTurn(dl, 1, barb)
    result = await scenario.solve(deterministic=True)
    # still, only one forced is given
    assert result.solution.timetable == [
        [{nobody}, {barb}, {alice}, {alice}, ],
    ]

async def test_fixed_ignored_if_exceeds_persons_max_torns_in_multiple_days():
    scenario = minimalScenario(
        days=('dl', 'dm'),
        names=[alice, barb, carol, diane, nobody],
        maxLoad=[2,1,2,2,1]
    )
    # Barb just dues 1 turn, but fixes 2 turns in different days
    scenario.forceTurn(dl, 0, barb)
    scenario.forceTurn(dm, 0, barb)
    result = await scenario.solve(deterministic=True)
    # still, only one forced is actually fixed
    assert result.solution.timetable == [
        [{nobody}, {carol}, {diane}, {alice}, ],
        [{barb}, {carol}, {alice}, {diane}, ],
    ]




def baseScenario(**extras):

    return TimetableScenario(**dict(dict(
        days=[dl,dm,dv],
        nHours=4,
        nLines=2,
        names=[alice,barb,carol,diane,emily,fanny,nobody],
        Nobodies = {nobody},
        maxLoad=[3,2,5,5,2,3,4],
        maxPersonLoadPerDay=2,
        forced=[
            [{alice}, O, O, {barb}], # dl
            [{alice}, O, O, O], # dm
            [O, O, O, O], # dv
        ],
        busy=[
            [{alice, barb, carol, diane, fanny}, O, {barb}, O], # dl
            [O, O, O, O], # dm
            [O, O, O, O], # dv
        ],
        inconvenient = [
            [{alice}, {alice}, {alice}, {alice}], # dl
            [{barb}, {barb}, {alice, barb, carol}, {barb}], # dm
            [{barb}, {barb}, {barb}, {barb}],  # dv
        ],
    ), **extras))
    
async def test_small_problem():
    scenario = baseScenario()
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable == [
            [{emily, nobody}, {alice, fanny}, {carol, diane}, {barb, carol}],
            [{alice, diane}, {diane, nobody}, {fanny, nobody}, {barb, carol}],
            [{carol, nobody}, {carol, fanny}, {alice, diane}, {emily, diane}],
    ]

async def test_small_problem2():
    scenario = baseScenario(
        forced=None,
        busy=None,
        inconvenient=None,
    )
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable == [
        [{emily, barb}, {fanny, diane}, {alice, carol}, {nobody, carol}],
        [{alice, nobody}, {nobody, carol}, {emily, diane}, {fanny, diane}],
        [{alice, diane}, {barb, diane}, {nobody, carol}, {fanny, carol}],
    ]


