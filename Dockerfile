# syntax=docker/dockerfile:1



# Set up the base image
ARG PYTHON_VERSION=3.12.2
FROM python:${PYTHON_VERSION}-slim as base

# Prevents Python from writing pyc files and keeps Python from buffering stdout and stderr.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set up the environment variables for AWS
# Note: Replace the placeholders with each user's own AWS credentials
#WHERE ACCESS KEYS CAN GO FOR TESTING
#Region set may need to vary if we want region selection
ENV AWS_DEFAULT_REGION=us-west-1

# Set up work directory for the application
WORKDIR /app

# Create a non-privileged user
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Install system dependencies including wget and unzip for Terraform
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip \
    && unzip terraform_1.0.0_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_1.0.0_linux_amd64.zip

# Download Python dependencies using cache mount
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

# Prepare session directory for Flask and set permissions
RUN mkdir /app/flask_session && chown -R appuser /app/flask_session

# Switch to the non-privileged user to run the application
USER appuser

# Copy the source code and Terraform files into the container
COPY --chown=appuser:appuser . /app

# Note: Adjust the path if your Terraform files are in a specific subfolder
# For example, if they are directly in the root of your project folder,
# the line below is correct. If not, you might need to use something like:
# COPY --chown=appuser:appuser ./path/to/terraform_files /terraform
WORKDIR /terraform
COPY --chown=appuser:appuser . /terraform

# Set up environment variables for Flask
ENV FLASK_APP=flasktest.py

# Expose the port that the application listens on
EXPOSE 5000

# Default command to run the application
CMD ["flask", "run", "--host", "0.0.0.0"]


###################################################
###OLD WORKING CODE PRE TERRAFORM IMPLEMENTATION###
###################################################
# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/
#
#ARG PYTHON_VERSION=3.12.2
#FROM python:${PYTHON_VERSION}-slim as base

# Prevents Python from writing pyc files.
#ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
#ENV PYTHONUNBUFFERED=1

#WORKDIR /app

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
#ARG UID=10001
#RUN adduser \
#    --disabled-password \
#    --gecos "" \
#    --home "/nonexistent" \
#    --shell "/sbin/nologin" \
#    --no-create-home \
#    --uid "${UID}" \
#   appuser


# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
#RUN --mount=type=cache,target=/root/.cache/pip \
#    --mount=type=bind,source=requirements.txt,target=requirements.txt \
#    python -m pip install -r requirements.txt

#RUN mkdir /app/flask_session && chown -R appuser /app/flask_session

# Switch to the non-privileged user to run the application.
#USER appuser

# Copy the source code into the container.
#COPY . .

#ENV FLASK_APP=flasktest.py


# Expose the port that the application listens on.
#EXPOSE 5000

# Run the application.
#CMD ["flask", "run", "--host", "0.0.0.0"]
