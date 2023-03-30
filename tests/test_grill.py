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
async def test__grid_tomato_cooker__indisponibilities(
    # given a solver
    tomato_cooker,
    # problem instance
    tomatic_instance_with_preferences,
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(tomatic_instance_with_preferences)

    # TODO: Have fun 🦄🌈
    for index, in_this_pony in enumerate(tomatic_instance_with_preferences.indisponibilitats):
        person = index // tomatic_instance_with_preferences.nDies
        day = index % tomatic_instance_with_preferences.nDies
        for little_pony in in_this_pony:
            assert person + 1 not in results.solution.ocupacioSlot[day][little_pony - 1]