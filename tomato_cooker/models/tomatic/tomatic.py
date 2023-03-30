import dataclasses
from pathlib import Path
from ..base import GridProblem


MODEL_DEFINITION_PATH = Path(__file__).absolute().parent.joinpath("phone_grill.mzn")


@dataclasses.dataclass
class TomaticProblem(GridProblem):
    nPersones: int
    nLinies: int
    nSlots: int
    nNingus: int
    nDies: int
    maxTorns: int
    nTorns: list
    indisponibilitats: list
    preferencies: list
