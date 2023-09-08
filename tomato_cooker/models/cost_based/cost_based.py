from pathlib import Path
import dataclasses
from tomato_cooker.grill import GrillTomatoCooker
from tomato_cooker.models.base import GridProblem

@dataclasses.dataclass
class TimetableScenario(GridProblem):
    names: set[str]
    Nobodies: set[str]
    maxPersonLoadPerDay: int
    maxLoad: list[int]
    days: list[str] = dataclasses.field(default_factory=lambda: [dl, dm, dx, dj, dv])
    nHours: int = 4
    nLines: int = 6
    forced: list[list[set[str]]] | None = None
    busy: list[list[set[str]]] | None = None 
    inconvenient: list[list[set[str]]] | None = None

    penaltyInconvenientHours: int = 5 # Assigning a turn someone marked as inconvenient
    penaltyMultipleHours: int = 10 # Multiple turns a day, multiplies by n(n-1) n: number of daily turns
    penaltyNoBrunch: int = 10 # Person daily distribution 0110, no time for lunch
    penaltyFarDiscontinuousHours: int = 20 # Persons daily distribution 1001, minor focus change
    penaltyDiscontinuousHours: int = 30 # Person daily distribution 1010 or 0101, focus change
    penaltyMarathon: int = 40 # Person daily distribution 1110 or 0111, need a break

    def _days_hours_matrix(self, factory):
        return [
            [
                factory()
                for _ in range(self.nHours)
            ]
            for _ in self.days
        ]

    def _add_to_days_hours_matrix(self, timetable, day, hour, persons):
        iday = self.days.index(day)
        timetable[iday][hour].update(persons)

    def __post_init__(self):
        for attrib in ('forced', 'busy', 'inconvenient'):
            if getattr(self, attrib): continue
            setattr(self, attrib, self._days_hours_matrix(set))


    def forceTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.forced, day, hour, persons)

    def busyTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.busy, day, hour, persons)

    def inconvenientTurn(self, day, hour, *persons):
        self._add_to_days_hours_matrix(self.inconvenient, day, hour, persons)

    async def solve(self, deterministic=False):
        parent_dir = Path(__file__).parent.absolute()
        cooker = GrillTomatoCooker(
            parent_dir/'model.mzn',
            ["coinbc"],
        )
        self.result = await cooker.cook(self, deterministic=deterministic)
        return self.result



