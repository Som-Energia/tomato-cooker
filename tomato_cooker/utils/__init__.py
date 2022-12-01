import yaml


def minizinc2tomatic(minizinc_solution) -> str:
    nlinies = 8
    i = 0
    str_days = ["dl", "dm", "dx", "dj", "dv"]
    timetable = {"timetable": {}}

    for day in minizinc_solution:
        llista = []
        for slot in day:
            slot = list(slot) + [0] * (nlinies - len(slot))
            llista.append(slot)
        timetable["timetable"][str_days[i]] = llista
        i += 1

    return yaml.dump(timetable)


"""
    #Expected input (result.solution.graella)
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
"""
