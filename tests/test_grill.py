import pytest

from tomato_cooker.grill import GrillTomatoCooker


def test__solver_instance(
    # given a path to a model description
    graellador_path,
    # and a list of solvers
    solvers,
):
    # When we create a new instance
    solver = GrillTomatoCooker(graellador_path, solvers)

    # Then returns a Solver instance
    assert isinstance(solver, GrillTomatoCooker)


@pytest.mark.asyncio
async def test__grid_tomato_cooker__cook(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    # Then a valid phone schedule is generated
    assert len(results.solution.ocupacioSlot) == tomatic_instance.nDies
    for day in results.solution.ocupacioSlot:
        assert len(day) == tomatic_instance.nSlots
        for slot in day:
            assert (
                tomatic_instance.nLinies - tomatic_instance.nNingus
                <= len(slot)
                <= tomatic_instance.nLinies
            )

@pytest.mark.asyncio
async def test__grid_tomato_cooker__cook__especial_one_day_two_consecutive_slots_same_person(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance_one_day_three_people,
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance_one_day_three_people)

    # Then a valid phone schedule is generated
    assert len(results.solution.ocupacioSlot) == tomatic_instance_one_day_three_people.nDies
    for day in results.solution.ocupacioSlot:
        assert len(day) == tomatic_instance_one_day_three_people.nSlots
        for slot in day:
            assert (
                tomatic_instance_one_day_three_people.nLinies - tomatic_instance_one_day_three_people.nNingus
                <= len(slot)
                <= tomatic_instance_one_day_three_people.nLinies
            )
            assert (
                1 in results.solution.ocupacioSlot[0][0]
            )
            assert (
                2 in results.solution.ocupacioSlot[0][1] or
                3 in results.solution.ocupacioSlot[0][1]
            )
            assert (
                2 in results.solution.ocupacioSlot[0][2] or
                3 in results.solution.ocupacioSlot[0][2]
            )

@pytest.mark.asyncio
async def test__grid_tomato_cooker__indisponibilities(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    # TODO: Have fun 🦄🌈
    for index, in_this_pony in enumerate(tomatic_instance.indisponibilitats):
        person = index // tomatic_instance.nDies
        day = index % tomatic_instance.nDies
        for little_pony in in_this_pony:
            assert person + 1 not in results.solution.ocupacioSlot[day][little_pony - 1]


@pytest.mark.asyncio
async def test__grid_tomato_cooker__fixed_turn_always_included(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    day=1
    hour=4
    person=0
    idx=tomatic_instance.index(person=person, day=day)
    tomatic_instance.forcedTurns[idx].add(hour)

    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)
    assert person + 1 in results.solution.ocupacioSlot[day][hour-1]

@pytest.mark.asyncio
async def test__grid_tomato_cooker__busy_turns_ignored_as_fixed(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    nDays = tomatic_instance.nDies
    person = 5
    day = 3 # dj
    hour = 4
    idx=tomatic_instance.index(person=person, day=day)
    tomatic_instance.forcedTurns[idx].add(hour)
    tomatic_instance.indisponibilitats[idx].add(hour)
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    assert person + 1 not in results.solution.ocupacioSlot[day][hour-1]

@pytest.mark.asyncio
async def test__grid_tomato_cooker__less_load_than_fixed__takes_a_subset_of_fixed(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance_one_day_three_people,
):
    tomatic_instance = tomatic_instance_one_day_three_people
    nDays = tomatic_instance.nDies
    person = 0
    day = 0 # dl
    hours = {1,2}
    idx=tomatic_instance.index(person=person, day=day)
    tomatic_instance.forcedTurns[idx]=hours # 2 fixed torns
    tomatic_instance.nTorns[person]=1 # load=1
    tomatic_instance.indisponibilitats[idx]=set() # no indisponibility that day
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    assert results.solution.ocupacioPersona[person][day].issubset(hours)
