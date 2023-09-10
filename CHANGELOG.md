# Change log

## 0.3.0 (2023-09-10)

- New Problem model: `models.cost_based.TimetableScenario`
    - minimizes costs, enabling new constraints
    - more flexible under conflicting constraints
    - more direct problem data mapping, for input and output
    - added penalty sources as output
    - methods for executing itself
- Breaking changes:
    - `tomato_cooker.models.tomatic.MODEL_DEFINITION_PATH`
      can now be found as `tomato_cooker.models.tomatic.TomaticProblem.model_path`

## 0.2.1 (2023-06-20)

- Deterministic mode for testing

## 0.2.0 (2023-06-20)

- Fix: Forced turns now behave if person is busy
- Fix: Forced turns now behave if person has less load than fixed turns
- Fix: Busy hours were not taken into account
- Input variables translated to adhere Tomatic glossary
    - nPersones -> nPersons
    - nSlots -> nHours
    - nDies -> nDays
    - nLinies -> nLines
    - preferencies -> forcedTurns
- Persons domain are names not indexes. Easier to debug and understand
  results and less error prone.

## 0.1.0 (2023-05-12)

- Add a constraint to obtain consecutive turns for the same person in a day
- Fix: packaging now includes mzn file

## 0.0.1

- Implemented somenergia phone turn distribution with minizinc modelation problem.
- Structure solution to be used as a library
