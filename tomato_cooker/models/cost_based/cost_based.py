import dataclasses
from typing import ClassVar, Optional
from pathlib import Path
from ..base import GridProblem

@dataclasses.dataclass
class TimetableScenario(GridProblem):
    model_path: ClassVar[Path] = Path(__file__).parent.absolute()/'model.mzn'

    names: set[str]
    Nobodies: set[str]
    maxPersonLoadPerDay: int
    maxLoad: list[int]
    days: list[str] = dataclasses.field(default_factory=lambda: [dl, dm, dx, dj, dv])
    nHours: int = 4
    nLines: int = 6
    forced: Optional[list[list[set[str]]]] = None
    busy: Optional[list[list[set[str]]]] = None
    undesired: Optional[list[list[set[str]]]] = None

    # TODO: Set those parameters with existing or new config.yaml params.
    # Those parameters are set in the model, for isolated testing.
    # Setting them here is ok but they must match or complaints of inconsistency.
    # Split isolated testing parameters into a separate dnz file and
    # set them here to config.yaml values with sane defaults
    penaltyUndesiredHours: int = 5 # Assigning a turn someone marked as undesired
    penaltyMultipleHours: int = 10 # Multiple turns a day, multiplies by n(n-1) n: number of daily turns
    penaltyNoBrunch: int = 10 # Person daily distribution 0110, no time for lunch
    penaltyFarDiscontinuousHours: int = 20 # Persons daily distribution 1001, minor focus change
    penaltyDiscontinuousHours: int = 30 # Person daily distribution 1010 or 0101, focus change
    penaltyMarathon: int = 40 # Person daily distribution 1110 or 0111, need a break
    penaltyUnforced: int = 50 # Not assigning a fixed turn
    penaltyEmpty: int = 100 # Not assigning a fixed turn

    def __post_init__(self):
        for attrib in ('forced', 'busy', 'undesired'):
            if getattr(self, attrib): continue
            setattr(self, attrib, self._days_hours_matrix())

    def _days_hours_matrix(self):
        return [
            [ set() for _ in range(self.nHours) ]
            for _ in self.days
        ]

    def _add_to_days_hours_matrix(self, timetable, day, hour, persons):
        iday = self.days.index(day)
        timetable[iday][hour].update(persons)


    def forceTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.forced, day, hour, persons)

    def busyTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.busy, day, hour, persons)

    def undesiredTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.undesired, day, hour, persons)


    async def solve(self, deterministic=False):
        from ...grill import GrillTomatoCooker
        parent_dir = Path(__file__).parent.absolute()
        cooker = GrillTomatoCooker(
            self.model_path,
            ["coinbc", "chuffed"],
        )
        self.result = await cooker.cook(self, deterministic=deterministic)
        return self.result



