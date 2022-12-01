import dataclasses


@dataclasses.dataclass
class GridProblem:
    def _asdict(self) -> dict:
        return dataclasses.asdict(self)
