# Cabotapp Dockerfile
# VERSION 1.0

FROM python:2-alpine

MAINTAINER Rachid Zarouali <rzarouali@gmail.com>

RUN apk update 
RUN apk add --update \
    python \
    python-dev \
    build-base \
    nodejs \
    nginx \
    curl \
    git\
    libpq \
    openldap-dev \
    libsasl \
    supervisor \
    tar \
    postgresql-dev 

RUN curl https://www.npmjs.com/install.sh -o "install.sh"
RUN chmod +x install.sh
RUN sh install.sh


# Deploy cabot
RUN git clone https://github.com/arachnys/cabot.git /cabot

# Install dependencies
RUN pip install -e /cabot/

# if you need specific python libs, add them to the specified file
RUN pip install -f /conf/requirements.txt
RUN npm install --no-color -g coffee-script less@1.3 --registry http://registry.npmjs.org/

# tweak celery config
RUN echo "CELERYD_MAX_TASKS_PER_CHILD = os.environ['CELERY_MAX_TASKS']" >> /cabot/cabot/celeryconfig.py

# Set env var
ENV PATH $PATH:/cabot/
ENV PYTHONPATH $PYTHONPATH:/cabot/

# Cabot settings
ENV DJANGO_SETTINGS_MODULE cabot.settings
ENV HIPCHAT_URL https://api.hipchat.com/v1/rooms/message
ENV LOG_FILE /var/log/cabot
ENV PORT 5000
ENV ADMIN_EMAIL you@example.com
ENV CABOT_FROM_EMAIL noreply@example.com
ENV DEBUG t

# URL of calendar to synchronise rota with
ENV CALENDAR_ICAL_URL http://www.google.com/calendar/ical/example.ics

ENV DJANGO_SECRET_KEY 2FL6ORhHwr5eX34pP9mMugnIOd3jzVuT45f7w430Mt5PnEwbcJgma0q8zUXNZ68A

# Hostname of your Graphite server instance
ENV GRAPHITE_API http://graphite.example.com/
ENV GRAPHITE_USER username
ENV GRAPHITE_PASS password

# Hipchat integration
ENV HIPCHAT_ALERT_ROOM 48052
ENV HIPCHAT_API_KEY your_hipchat_api_key

# Jenkins integration
ENV JENKINS_API https://jenkins.example.com/
ENV JENKINS_USER username
ENV JENKINS_PASS password

# SMTP settings
ENV SES_HOST email-smtp.us-east-1.amazonaws.com
ENV SES_USER username
ENV SES_PASS password
ENV SES_PORT 465

# Twilio integration for SMS and telephone alerts
ENV TWILIO_ACCOUNT_SID your_account_sid
ENV TWILIO_AUTH_TOKEN your_auth_token
ENV TWILIO_OUTGOING_NUMBER +14155551234

# Ovh Integration for SMS alerts
ENV OVH_ID myid
ENV OVH_LOGIN mylogin
ENV OVH_PASS mypass
ENV OVH_SENDER mysender

# Used for pointing links back in alerts etc.
ENV WWW_HTTP_HOST cabot.example.com
ENV WWW_SCHEME http

ADD conf/env_vars /cabot/

# create log directories
RUN mkdir -p /var/log/{cabotapp,nginx}

#Create a dummy run.sh script
COPY scripts/run.sh /srv/run.sh
RUN chmod +x /srv/run.sh

#expose app port
EXPOSE 8000 

#set WORKDIR as /cabot
WORKDIR /cabot/

# Run cabot
CMD ["/bin/sh"]
ENTRYPOINT ["/srv/run.sh"]
