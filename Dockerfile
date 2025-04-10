FROM python:3.9-slim

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean

RUN pip install --no-cache-dir flask kubernetes

WORKDIR /app

COPY getResources.py /app/getResources.py
COPY placement.py /app/placement.py
COPY mcplacement.py /app/mcplacement.py
COPY app.py /app/app.py


EXPOSE 8000
ENTRYPOINT ["python3", "app.py"]
