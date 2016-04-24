# etl-python

## WHAT
An ETL program, written in `python3`. The spiritual successor to (etl)[github.com/sklbjo/etl], but in `python3`

## INSTALL && SETUP
- Install the repo, `git clone git@github.com:skilbjo/etl-python`
- Create a virtualenv,`$ mkvirtualenv --python=$(which python3) etl`
- Deactivate the virtualenv, `(etl)etl-python$ deactivate etl` ; `etl-python$ workon etl`
- Switch back to the virtualenv, `(etl)etl-python $`
- Install the dependencies, `pip install -r requirements.txt`
- And, for installed dependencies, `pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U`
- Write new dependencies`pip freeze > requirements.txt`

## WORKFLOW
- 
- cron: `0 20 * * * cd $TXN ; python3 extract.py transaction.sql >/dev/null`
- if necessary, add dependency loads via `bash` subshells & bash workflow, ie:
-- `python3 extract.py file.py && (python3 extract.py dependent_load_first.py ; python3 extract.py dependent_load_second.py)`

## TO DO
[ ] use `if __name__ == '__main__'`
[ ] make the script take an argument, a sql file, as the file to parse & execute

