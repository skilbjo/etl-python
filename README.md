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

## DEPLOYMENT ON CENTOS
		# yum install python pip python3
		# pip install virtualenvwrapper
		# mkvirtualenv -p $(which python3) etl
		# source ~/.virtualenvs/etl/bin/activate

		local@skilbjo $ git remote add finance	ssh://skilbjo@finance.server.int/~/python/git/etl.git 


## USAGE
To run a query, call the `etl.py` file from python3. The three command-line flags are `-s, --server`,'`-e,--extract`, and `-l,--load`.

Example usage: 
- MSSQL: `python etl.py -s crostoli -e sql/Analytics/Analytics.tsql -l sql/Analytics/load_Analytics.sql`
- Postgres: `python etl.py -s finance_yapdm -e sql/Analytics/Analytics.psql -l sql/Analytics/load_Analytics.sql`


## WORKFLOW
- cron: `0 20 * * * cd $TXN ; python3 extract.py transaction.sql >/dev/null`
- if necessary, add dependency loads via `bash` subshells & bash workflow, ie:
-- `python3 extract.py file.py && (python3 extract.py dependent_load_first.py ; python3 extract.py dependent_load_second.py)`

## TO DO
- [x] use `if __name__ == '__main__'`
- [x] make the script take an argument, a sql file, as the file to parse & execute
- [ ] complete the load phase

## MISC
When running, `python3` will compile bytecode in a `__pychace__` folder. To remove in the dev machine,

- in bash, export a variable and set it to true: `PYTHONDONTWRITEBYTECODE=true`, and 
- run this command to remove any existing `__pycache__` folders: `find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf`




