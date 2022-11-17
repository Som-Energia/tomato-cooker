from minizinc import Model
from solver import GridTomatoCooker


def test__solver_instance(graellador_path):
    # given a valid minizinc model
    model = Model(graellador_path)

    # When we create a new instance of GridTomatoCooker
    solver = GridTomatoCooker(model)

    # Then returns a GridTomatoCooker instance
    assert isinstance(solver, GridTomatoCooker)


def test__solver_grid_trigger(
    # given a solver instance
    solver
):
    # When we start a new grid execution
    results = solver.grid_trigger()

    # Then returns a Solver instance
    assert isinstance(solver, Solver)
