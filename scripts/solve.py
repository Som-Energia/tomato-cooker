from minizinc import Instance, Model, Solver

def graellada(dzndata_file = "./exemple-setmana.dzn"):

    gecode = Solver.lookup("gecode")

    graellador = Model("grup1/grup1_graellador.mzn")
    graellador.add_file(dzndata_file)
    instance = Instance(gecode, graellador)
    result = instance.solve()
    result.solution.graella

if __name__ == "__main__":
	graellada()