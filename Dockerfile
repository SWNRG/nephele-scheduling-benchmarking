FROM python:3.9-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        build-essential \
        cmake \
        glpk-utils \
        libglpk-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir flask kubernetes cvxpy cvxopt

WORKDIR /app

COPY getResources.py /app/getResources.py
COPY nodeplacement.py /app/nodeplacement.py
COPY clusterplacement.py /app/clusterplacement.py
COPY app.py /app/app.py


EXPOSE 8000
ENTRYPOINT ["python3", "app.py"]
