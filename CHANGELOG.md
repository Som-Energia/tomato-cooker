# Change log

## Unreleased

- Fix: Forced turns now behave if person is busy
- Fix: Forced turns now behave if person has less load than fixed turns
- Input variables translated to adhere Tomatic glossary
    - nPersones -> nPersons
    - nSlots -> nHours
    - nDies -> nDays
    - nLinies -> nLines
    - preferencies -> forcedTurns

## 0.1.0 2023-05-12

- Add a constraint to obtain consecutive turns for the same person in a day
- Fix: packaging now includes mzn file

## 0.0.1

- Implemented somenergia phone turn distribution with minizinc modelation problem.
- Structure solution to be used as a library

