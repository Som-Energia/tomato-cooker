from minizinc import Instance, Model, Solver
import asyncio
import minizinc
import pymzn

# exemples d'inputs

indisponibilitats = [[{1},{1},{1},{1},{1}], [{4},{4},{4},{4},{4}]]
nTorns = [3,5]

with open('./test_generate.dzn', 'w') as f:
    f.write('\n'.join(pymzn.dict2dzn({
        'nTorns':nTorns,
        'indisponibilitats':indisponibilitats,
        }
    )))
exit()

model = Model("./graellador.mzn")
dzdata_file = './input_base.dzn'

async def solver_race(model, dzdata_file, solvers):
    model.add_file(dzdata_file)
    tasks = set()
    for solver in solvers:
        # Create an instance of the model for every solver
        inst = minizinc.Instance(solver, model)
    
        # Create a task for the solving of each instance
        task = asyncio.create_task(inst.solve_async())
        task.solver = solver.name
        tasks.add(task)

    # Wait on the first task to finish and cancel the other tasks
    done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
    for t in pending:
        t.cancel()

    # Declare the winner
    for t in done:
        print("{} finished solving the problem first!".format(t.solver))
        print("{} i la graella és... ".format(t.result().solution.ocupacioSlot))


solvers = ['chuffed', 'gecode', 'coin-bc']
mz_solvers = [minizinc.Solver.lookup(solver) for solver in solvers]
asyncio.run(solver_race(model, dzdata_file, mz_solvers))