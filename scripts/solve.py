import typer

from minizinc import Instance, Model, Solver


def graellada(dzndata_file: str = "./exemple-setmana.dzn"):

    gecode = Solver.lookup("gecode")

    graellador = Model("grup1/grup1_graellador.mzn")
    graellador.add_file(dzndata_file)
    instance = Instance(gecode, graellador)
    result = instance.solve()
    print(result.solution.graella)

    '''
    #Expected output result.solution.graella
    output = [[{1, 2, 3, 4, 5, 6, 7, 8},
        {9, 10, 11, 12, 13, 14, 15, 16},
        {17, 18, 19, 20, 21},
        {22, 23, 24, 25, 26, 27, 28, 29}],
        [{1, 2, 3, 4, 5, 6, 7, 8},
        {9, 10, 11, 12, 13, 14, 15, 16},
        {17, 18, 19, 20, 21},
        {22, 23, 24, 25, 26, 27, 28, 29}],
        [{1, 2, 3, 4, 5, 6, 7, 8},
        {9, 10, 11, 12, 13, 14, 15, 16},
        {17, 18, 19, 20, 21},
        {22, 23, 24, 25, 26, 27, 28, 29}],
        [{1, 2, 3, 4, 5, 6, 7, 8},
        {9, 10, 11, 12, 13, 14, 15, 16},
        {17, 18, 19, 20, 21},
        {22, 23, 24, 25, 26, 27, 28, 29}],
        [{1, 2, 3, 4, 5, 6, 7, 8},
        {9, 10, 11, 12, 13, 14, 15, 16},
        {17, 18, 19, 20, 21},
        {22, 23, 24, 25, 26, 27, 28, 29}]]
    '''

    nlinies = 8
    i = 0
    str_days = ['dl', 'dm','dx','dj','dv']
    timetable = {'timetable': {}}
    for day in output:
        llista = []
        for slot in day:
            slot = list(slot) + [0]*(nlinies - len(slot))
            llista.append(slot)
        timetable['timetable'][str_days[i]] = llista
        i += 1


    with open('data.yml', 'w') as outfile:
        yaml.dump(timetable, outfile, default_flow_style=False, sort_keys=False)


if __name__ == "__main__":
	typer.run(graellada)