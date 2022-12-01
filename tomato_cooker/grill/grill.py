import asyncio
from typing import Any

import minizinc

from ..models import TomaticProblem


class GrillTomatoCooker:
    def __init__(self, model_path: str, solvers: list) -> None:
        self.model = minizinc.Model(model_path)
        self.solvers = solvers

    async def cook(self, problem_instance: TomaticProblem) -> Any:
        result = []
        for attr, value in problem_instance._asdict().items():
            self.model[attr] = value

        tasks = set()
        for solver_name in self.solvers:
            # Create an instance of the model for every solver
            solver = minizinc.Solver.lookup(solver_name)
            inst = minizinc.Instance(solver, self.model)

            task = asyncio.create_task(inst.solve_async())
            task.solver = solver.name
            tasks.add(task)

        # Wait on the first task to finish and cancel the other tasks
        done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
        if done:
            result = done.pop().result()

        # Clean pending tasks
        for task in pending:
            task.cancel()
            await asyncio.sleep(0.1)

        return result
