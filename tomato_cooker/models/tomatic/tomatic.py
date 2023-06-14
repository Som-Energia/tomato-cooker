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
    nDays: int
    maxTorns: int
    nTorns: list
    indisponibilitats: list
    forcedTurns: list

    def index(self, person, day):
        return self.nDays*person + day
