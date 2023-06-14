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
async def test__solution__well_formed(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    # Then a valid phone schedule is generated
    assert len(results.solution.ocupacioSlot) == tomatic_instance.nDays
    for day in results.solution.ocupacioSlot:
        assert len(day) == tomatic_instance.nHours
        for slot in day:
            assert (
                tomatic_instance.nLines - tomatic_instance.nNingus
                <= len(slot)
                <= tomatic_instance.nLines
            )

@pytest.mark.asyncio
async def test__multiple_turns_a_day__must_be_consecutive(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance_one_day_three_people,
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance_one_day_three_people)

    # Then a valid phone schedule is generated
    assert len(results.solution.ocupacioSlot) == tomatic_instance_one_day_three_people.nDays
    for day in results.solution.ocupacioSlot:
        assert len(day) == tomatic_instance_one_day_three_people.nHours
        for slot in day:
            assert (
                tomatic_instance_one_day_three_people.nLines - tomatic_instance_one_day_three_people.nNingus
                <= len(slot)
                <= tomatic_instance_one_day_three_people.nLines
            )
            assert (
                'alice' in results.solution.ocupacioSlot[0][0]
            )
            assert (
                'bob' in results.solution.ocupacioSlot[0][1] or
                'carol' in results.solution.ocupacioSlot[0][1]
            )
            assert (
                'bob' in results.solution.ocupacioSlot[0][2] or
                'carol' in results.solution.ocupacioSlot[0][2]
            )

@pytest.mark.asyncio
async def test__busy_persons__not_in_result(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    # TODO: Have fun 🦄🌈
    for index, in_this_pony in enumerate(tomatic_instance.indisponibilitats):
        person = index // tomatic_instance.nDays
        day = index % tomatic_instance.nDays
        for little_pony in in_this_pony:
            assert person + 1 not in results.solution.ocupacioSlot[day][little_pony - 1]


@pytest.mark.asyncio
async def test__forced_turns__included_in_resut(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    day=1
    hour=4
    person='C'
    iperson = tomatic_instance.names.index(person)
    idx=tomatic_instance.index(person=iperson, day=day)
    tomatic_instance.forcedTurns[idx].add(hour)

    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)
    assert person in results.solution.ocupacioSlot[day][hour-1]

@pytest.mark.asyncio
async def test__forced_turns__ignored_if_busy(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance,
):
    person = 'C'
    day = 3 # dj
    hour = 4
    iperson = tomatic_instance.names.index(person)
    idx=tomatic_instance.index(person=iperson, day=day)
    tomatic_instance.forcedTurns[idx].add(hour)
    tomatic_instance.indisponibilitats[idx].add(hour)
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    assert person not in results.solution.ocupacioSlot[day][hour-1]

@pytest.mark.asyncio
async def test__forced_turns__reduced_if_person_has_less_load(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance_one_day_three_people,
):
    tomatic_instance = tomatic_instance_one_day_three_people
    person = 'alice'
    day = 0 # dl
    hours = {1,2}
    iperson = tomatic_instance.names.index(person)
    idx=tomatic_instance.index(person=iperson, day=day)
    tomatic_instance.forcedTurns[idx]=hours # 2 fixed torns
    tomatic_instance.nTorns[iperson]=1 # load=1
    tomatic_instance.indisponibilitats[idx]=set() # no indisponibility that day
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance)

    assert results.solution.ocupacioPersona[iperson][day].issubset(hours)
