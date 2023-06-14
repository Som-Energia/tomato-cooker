import pytest
from tomato_cooker.grill import GrillTomatoCooker
from tomato_cooker.models import TomaticProblem, tomatic


@pytest.fixture
def graellador_path():
    return tomatic.MODEL_DEFINITION_PATH


@pytest.fixture
def solvers():
    return ["chuffed", "coin-bc"]


@pytest.fixture
def tomato_cooker(graellador_path, solvers):
    return GrillTomatoCooker(graellador_path, solvers)


@pytest.fixture
def tomatic_instance():
    nPersones = 32
    nDays = 5
    return TomaticProblem(
        nPersones=nPersones,
        nLinies=8,
        nSlots=4,
        nNingus=2,
        nDays=nDays,
        maxTorns=6,
        nTorns=[
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
            9,
        ],
        indisponibilitats=[
            {1}, {1}, {1}, {1}, {1},
            {2}, {2}, {2}, {2}, {2},
            {3}, {3}, {3}, {3}, {3},
            {4}, {4}, {4}, {4}, {4},
            {1}, {2}, {3}, {4}, {1},
            {2}, {3}, {4}, {1}, {2},
            {3}, {4}, {1}, {2}, {3},
            {4}, {1}, {2}, {3}, {4},
            {4}, {3}, {2}, {1}, {4},
            {2}, {1}, {3}, {4}, {2},
            {1}, {2}, {3}, {4}, {1},
            {2}, {3}, {4}, {1}, {2},
            {3}, {4}, {1}, {2}, {3},
            {4}, {1}, {2}, {3}, {4},
            {4}, {3}, {2}, {1}, {4},
            {2}, {1}, {3}, {4}, {2},
            {1}, {1}, {1}, {1}, {1},
            {2}, {2}, {2}, {2}, {2},
            {3}, {3}, {3}, {3}, {3},
            {4}, {4}, {4}, {4}, {4},
            {1}, {2}, {3}, {4}, {1},
            {2}, {3}, {4}, {1}, {2},
            {3}, {4}, {1}, {2}, {3},
            {4}, {1}, {2}, {3}, {4},
            {4}, {3}, {2}, {1}, {4},
            {2}, {1}, {3}, {4}, {2},
            {1}, {2}, {3}, {4}, {1},
            {2}, {3}, {4}, {1}, {2},
            {3}, {4}, {1}, {2}, {3},
            {4}, {1}, {2}, {3}, {4},
            {4}, {3}, {2}, {1}, {4},
            {2}, {1}, {3}, {4}, {2},
        ],
        forcedTurns=[
            set() for _ in range(nDays * nPersones)
        ]
    )
@pytest.fixture
def tomatic_instance_one_day_three_people(tomatic_instance):
    tomatic_instance.nPersones = 3
    tomatic_instance.nDays = 1
    tomatic_instance.nLinies = 1
    tomatic_instance.nNingus = 0
    tomatic_instance.maxTorns = 2
    tomatic_instance.nTorns = [4,4,4]
    tomatic_instance.indisponibilitats = [{2,3,4}, {1}, {1}]
    tomatic_instance.forcedTurns=[
        set() for _ in range(tomatic_instance.nDays * tomatic_instance.nPersones)
    ]
    return tomatic_instance

