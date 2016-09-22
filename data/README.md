## `data/` Contents

- `data/raw` contains raw files received from our California DoJ partners, roughly 2016-03-14.
- `data/scripts` contains Python scripts that are run by the Makefile to process the raw data.
- `ori.csv` **must be provided** for the application to run. If you don't have a list of police agencies in your state, you can copy over the provided example file:
  ```
  cp data/ori.csv.example data/ori.csv
  ```
