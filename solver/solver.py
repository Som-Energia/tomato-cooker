import asyncio
from collections import namedtuple

import minizinc
from minizinc import Model

GridProblem = namedtuple("GridProblem", "nPersones, nLinies, nSlots, nNingus, nDies, maxTorns, nTorns, indisponibilitats")


class GridTomatoCooker:

    SOLVERS = ['chuffed', 'coin-bc']

    def __init__(self, model_path):
        self.model = Model(model_path)

    async def cook(self, grid_instance):
        result = None
        for attr, value in grid_instance._asdict().items():
            self.model[attr] = value

        tasks = set()
        for solver_name in self.SOLVERS:
            # Create an instance of the model for every solver
            solver = minizinc.Solver.lookup(solver_name)
            inst = minizinc.Instance(solver, self.model)

            # Create a task for the solving of each instance
            task = asyncio.create_task(inst.solve_async())
            task.solver = solver.name
            tasks.add(task)

        # Wait on the first task to finish and cancel the other tasks
        done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
        # Declare the winner
        if done:
            result = done.pop().result().solution.ocupacioSlot
        # Clean pending tasks
        for task in pending:
            task.cancel()
            await asyncio.sleep(0.1)

        return result
