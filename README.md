# etl-python

## Setup

Create a virtualenv:
`$ mkvirtualenv --python=$(which python3) etl`

Deactivate the virtualenv:
`(etl)etl-python$ deactivate etl`
`etl-python$ workon etl`

Switch back to the virtualenv
`(etl)etl-python $`

Install the dependencies:
`pip install -r requirements.txt`
`pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U`

Write new dependencies:
`pip freeze > requirements.txt`


## Add new libraries to `requirements.txt`

$ 