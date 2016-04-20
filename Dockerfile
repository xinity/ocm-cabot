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

# cleanup local cache
RUN rm -rf /root/.cache

# Set env var
ENV PATH $PATH:/cabot/
ENV PYTHONPATH $PYTHONPATH:/cabot/

COPY conf/env_vars /cabot/

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
