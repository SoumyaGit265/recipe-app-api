FROM python:3.9-alpine3.13
LABEL maintainer="soumya"

# We are instructing Python to not buffer it's standard output and error streams.
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# If we are mentioning a WORKDIR then we are saying that from now on run everything inside this folder in the container.
# - Any command that follows (RUN, CMD, COPY, etc.) will happen relative to that directory.
WORKDIR /app 
EXPOSE 8000

ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# The RUN command runs a command on the Alpine image that we are using when we are building our image
# So we have broken the commands down onto one run block, so we could techinically specify run and then each one of the lines individually
# In this case it creates a new image layer for every single command that we run and we want to avoid doing that to keep our images lightweight

# RUN python -m venv /py && /py/bin/pip install --upgrade pip && /py/bin/pip install -r /tmp/requirements.txt && rm -rf /tmp && \
    # adduser --no-create-home --disabled-password django-user
    # The adduser will add an user name as django-user with no home directory and disabling the password.
    # We have a root user by default then why we need custom user?
    # IF we didn't specify the user, then the only user available inside the alpine image that we are using would be the root user.
    # The root user is the user that has the full access and permissions to do everything on the server. So there will be no restrictions and limitations


ENV PATH="/py/bin:$PATH"
# This updated the environment variable inside the image. The PATH is the env variables that is automatically created on Linux operating systems.
# What it does? - It defines all of the directories where executables can be run. So when we run any Python command in our proiject, 
# it will run automatically from our virtual environment. - It tells Linux where to look for executables (like python, pip, etc.).
# - By updating PATH, you don’t need to type /py/bin/python or /py/bin/pip every time instead you can run "python app.py".

USER django-user
# - This tells Docker: “From now on, run all commands in this container as the django-user instead of root.”
# So when the container starts, your Django app (or any process) runs under that non‑root account.