![PyPI](https://img.shields.io/pypi/v/tomato-cooker)
[![CI](https://github.com/Som-Energia/tomato-cooker/actions/workflows/main.yml/badge.svg)](https://github.com/Som-Energia/tomato-cooker/actions/workflows/main.yml)
[![Coverage Status](https://coveralls.io/repos/github/Som-Energia/tomato-cooker/badge.svg?branch=master)](https://coveralls.io/github/Som-Energia/tomato-cooker?branch=main)


# cooked-tomato

Timetable scheduler for phone attention turns in Som Energia

## History

This project is the result of an internal Som Energia Hackathon held on 11-03-2022 about MiniZinc
with the goal of reimplementing the previous solution based on a 
[pruned backtracking](https://github.com/Som-Energia/somenergia-tomatic/blob/master/tomatic/backtracker.py).


### Prerequisites

Before you begin, ensure you have met the following requirements:

* You must have at least `python 3.8`. You can get this python version through `pyenv`. See more here -> https://github.com/pyenv/pyenv#installation
* You should have a `Linux/Mac` machine. Windows is not supported and we are not thinking in it.

### Installation

```bash
pip install cooked-tomato
```

### Usage

```python
import asyncio
from tomato_cooker.grill import GrillTomatoCooker
from tomato_cooker.models import TomaticProblem, tomatic

# define a problem
tomatic_problem_params = {
    "nPersons": 4,
    "nLines": 2,
    "nHours": 3,
    "nNingus": 1,
    "nDays": 5,
    "maxTorns": 2,
    "nTorns": [3, 3, 3, 3,],
    "indisponibilitats": [
        {1}, {1}, {2}, {1}, {1},
        {2}, {2}, {2}, {2}, {2},
        {3}, {3}, {2}, {3}, {3},
        {2}, {3}, {2}, {2}, {1},
    ]
}
tomatic_problem = TomaticProblem(**tomatic_problem_params)

# choose a list of minizinc solvers to user
solvers = ["chuffed", "coin-bc"]

# create an instance of the cooker
tomato_cooker = GrillTomatoCooker(tomatic.MODEL_DEFINITION_PATH, solvers)

# Now, we can solve the problem
solution = asyncio.run(tomato_cooker.cook(tomatic_problem))
print(solution)
```

### Contribute

1. Fork the repository on GitHub.
2. Set up your development setup
```bash
$> pip install -e .[dev,tests]
```
3. Run the tests to confirm they all pass on your system.
```bash
$> pytest
```
4. Make your change and run the entire test suite again and confirm that all tests pass including the ones you just added.
5. Create us a GitHub Pull Request to the main repository’s master branch. GitHub Pull Requests are the expected method of code collaboration on this project.

## Changes

[Historic of changes.][changelog]

## License

This project uses the following license: [GNU AFFERO GENERAL PUBLIC LICENSE](LICENSE).

[changelog]: CHANGELOG.md
