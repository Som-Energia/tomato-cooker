import pytest
from tomato_cooker.models.cost_based.cost_based import TimetableScenario


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
async def test_undesired_alice__turns_moved():
    scenario = minimalScenario()
    scenario.undesiredTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    # When no further restrictions, inconvenient
    # hours are much like busy hours
    assert result.solution.timetable in [
        [[{alice}, {alice}, {nobody}, {barb}]],
        [[{alice}, {alice}, {barb}, {nobody}]],
    ]

async def test_undesired_but_everybody_else_busy__resignate():
    scenario = minimalScenario()
    # Alice don't like at fist hour
    scenario.undesiredTurn(dl, 0, alice)
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
    assert result.solution.timetable in [
        [[{nobody}, {nobody}, {alice}, {barb}]],
        [[{nobody}, {nobody}, {alice}, {barb}]],
        [[{nobody}, {nobody}, {barb}, {alice}]],
        [[{nobody}, {nobody}, {barb}, {alice}]],
    ]

async def test_dejeuner_constraint_ignored_if_no_other_way():
    scenario = minimalScenario()
    scenario.busyTurn(dl, 0, alice)
    scenario.busyTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable in [
        [[{nobody}, {alice}, {alice}, {barb},]],
        [[{barb}, {alice}, {alice}, {nobody},]],
    ]

async def test_fixed_turns_imposes_over_continous_turns_rule():
    scenario = minimalScenario()
    scenario.forceTurn(dl, 0, alice)
    scenario.forceTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable in [
        [[{alice}, {nobody}, {barb}, {alice},]],
        [[{alice}, {barb}, {nobody}, {alice},]],
    ]

async def test_fixed_ignored_if_also_busy():
    scenario = minimalScenario()
    scenario.busyTurn(dl, 0, alice)
    scenario.forceTurn(dl, 0, alice)
    scenario.forceTurn(dl, 3, alice)
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable in [
        [[{nobody}, {barb}, {alice}, {alice},]],
        [[{barb}, {nobody}, {alice}, {alice},]],
    ]


async def test_fixed_ignored_if_exceeds_persons_max_load():
    scenario = minimalScenario()
    # Barb just dues 1 turn, but fixes 2 turns
    scenario.forceTurn(dl, 0, barb)
    scenario.forceTurn(dl, 1, barb)
    result = await scenario.solve(deterministic=True)
    # still, only one forced is given
    assert result.solution.timetable in [
        [[{nobody}, {barb}, {alice}, {alice}, ]],
        [[{barb}, {nobody}, {alice}, {alice}, ]],
    ]

def personOccurrence(timetable, person):
    return '|'.join(
        ''.join('X' if person in hour else '_' for hour in day )
        for day in timetable
    )

async def test_fixed_ignored_if_exceeds_persons_max_load_in_multiple_days():
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
    assert personOccurrence(result.solution.timetable, barb) in [
        "____|X___",
        "X___|____",
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
        undesired = [
            [{alice}, {alice}, {alice}, {alice}], # dl
            [{barb}, {barb}, {alice, barb, carol}, {barb}], # dm
            [{barb}, {barb}, {barb}, {barb}],  # dv
        ],
    ), **extras))
 
@pytest.mark.skip("Solution mutated")
async def test_small_problem():
    scenario = baseScenario()
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable == [
            [{emily, nobody}, {alice, fanny}, {carol, diane}, {barb, carol}],
            [{alice, diane}, {diane, nobody}, {fanny, nobody}, {barb, carol}],
            [{carol, nobody}, {carol, fanny}, {alice, diane}, {emily, diane}],
    ]

@pytest.mark.skip("Solution mutated")
async def test_small_problem2():
    scenario = baseScenario(
        forced=None,
        busy=None,
        undesired=None,
    )
    result = await scenario.solve(deterministic=True)
    assert result.solution.timetable == [
        [{emily, barb}, {fanny, diane}, {alice, carol}, {nobody, carol}],
        [{alice, nobody}, {nobody, carol}, {emily, diane}, {fanny, diane}],
        [{alice, diane}, {barb, diane}, {nobody, carol}, {fanny, carol}],
    ]


