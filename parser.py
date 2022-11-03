from yamlns import namespace as ns
from random import shuffle

FILENAME_IDEALS = 'idealshifts.csv'
FILENAME_INDISP = 'indisponibilitats.conf'

def get_names_and_ideals():
    ideals = ns.load(FILENAME_IDEALS)

    clean_ideals = dict()
    for person, turns in ideals.items():
        if turns:
            clean_ideals[person] = turns

    names = list(clean_ideals.keys())
    shuffle(names)
    turns = [clean_ideals[name] for name in names]

    return names, turns

def get_indisponibilitats():
    with open(FILENAME_INDISP, 'r') as f:
        lines = f.readlines()

    # for line in lines:
    #     data = line.split(" ")
    #     if data[0].startswith("+"):
    #         name = data[0][1:]
    #     else:
    #         name = data[0]

        # weekday = 
        # [[{1,2,3},{},{},{},{}],...]

        





# names, turns = get_names_and_ideals()
# print(names)
# print(turns)

get_indisponibilitats()