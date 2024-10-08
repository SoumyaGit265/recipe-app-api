FROM python:3.9-alpine3.13
LABEL maintainer="soumya"

ENV PYTHONBUFFERED 1
#  you’re telling Python to disable output buffering. But what does that mean?
# Output buffering is a mechanism where Python collects output (such as print statements or log messages) 
# and holds it in memory before actually displaying or writing it. This buffering can introduce delays, 
# especially when dealing with large amounts of output.

# By setting PYTHONUNBUFFERED to a non-zero value (in this case, 1), you ensure that the output from your 
# Python application is immediately displayed or written without any delays. It’s like turning off the “wait and see”
# behavior for output.

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
# copy the mentioned files from the location where the dockerfile is present to thhe mentioned folders inside container

WORKDIR /app
# it sets the working directory for any RUN, CMD, ENTRYPOINT, COPY, and ADD instructions that follow it

EXPOSE 8000

ARG DEV=false
# Here we are specifing DEV is false which will be default value, but when docker-compose file will run it will override the image DEV=false
# to DEV=true that we have mentioned in the docker-compose file.

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

# First, created virtual environments that where we used to store dependencies
# Second, We specifying the full path of our virtual env, so we want to upgrade PIP for the virtual environment that we just created.
# Third, we install our requirements files, it will install the list of dependencies requirements inside the Docker image.
# Fourth, we remove the /tmp directory, the reason we did this because we don't want any extra dependencies on our image, it is better practice to keep docker images as lightas possible
# Fifth, adduser do is adds a new user inside our image, the reason we do this because it's best practice not to use the rot user.
# If we don't add user the user that left is the rot user. And this root user has the full access and permissions to do everything on the server there are no restrictions and limitations for root users
# Note: DON'T RUN YOUR APLICATION USING THE ROOT USER... We have specified the diable passord because we are not going to be using a passowrd to log on to this
# We also don't create Home directory for the user because it's not necessary an we want to keep the Docker images like where its possible
# django-user is the name of the user who don't have this privileges.

# if [ $DEV = "true" ]; \
#   then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
# fi && \
# This is logic that we are using to install all the requirements that are present in the requirements.dev.txt only when env is dev.

ENV PATH="/py/bin:$PATH"
# This udates the environment variable inside the image and we are updating the path environment variable

USER django-user
# This specify the user that we are switching to this specified user.
# Before this line everything is done by the root user and the containers are made out of this imagewho run using the last user that the
# image switched to i.e. "django-user". So anytime you run anything will be run by django-user.