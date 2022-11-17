import pytest

from solver import GridTomatoCooker


def test__solver_instance(
    # given a path to a model description
        graellador_path
    ):
    # When we create a new instance
    solver = GridTomatoCooker(graellador_path)

    # Then returns a Solver instance
    assert isinstance(solver, GridTomatoCooker)


@pytest.mark.asyncio
async def test__grid_tomato_cooker__cook(
    # given a solver
    tomato_cooker,
    # problem instance
    grid_instance
):
    # When we start a new grid execution
    results = await tomato_cooker.cook(grid_instance)

    # Then a valid telephonic grid is generated
    assert len(results) == grid_instance.nDies
    for day in results:
        assert len(day) == grid_instance.nSlots
        for slot in day:
            assert grid_instance.nLinies - grid_instance.nNingus <= len(slot) <= grid_instance.nLinies
