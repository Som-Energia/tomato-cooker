import dataclasses
from typing import ClassVar
from pathlib import Path
from ..base import GridProblem


@dataclasses.dataclass
class TomaticProblem(GridProblem):
    model_path: ClassVar[Path] = Path(__file__).parent.absolute()/'phone_grill.mzn'

    nPersons: int
    nLines: int
    nHours: int
    nNingus: int
    nDays: int
    maxTorns: int
    nTorns: list
    names: list
    indisponibilitats: list
    forcedTurns: list

    def index(self, person, day):
        return self.nDays*person + day
