#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{personal_information_history_start_date: "2023-01-01", worker_position_history_start_date: "2023-01-01", worker_history_start_date: "2023-01-01",  worker_position_organization_history_start_date: "2023-01-01"}' --target "$db" --full-refresh
dbt test --target "$db"
dbt run --target "$db"
dbt test --target "$db"

dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"