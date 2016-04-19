#!/bin/bash

# first we need to load env vars

# Set env var
export PATH=$PATH:/cabot/
export PYTHONPATH=$PYTHONPATH:/cabot/

source /cabot/env_vars

python manage.py collectstatic --noinput &&\
python manage.py compress --force &&\
python manage.py syncdb --noinput && \
python manage.py migrate && \
python manage.py loaddata /cabot/fixture.json 

service nginx restart &&\
gunicorn cabot.wsgi:application --config gunicorn.conf --log-level info --log-file /var/log/gunicorn &\
celery worker -B -A cabot --loglevel=INFO --concurrency=8 -Ofair
