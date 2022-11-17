import pytest
from solver import GridTomatoCooker


@pytest.fixture
def graellador_path():
    return "solver/graellador.mzn"


@pytest.fixture
def solver(graellador_path):
    return GridTomatoCooker(graellador_path)
