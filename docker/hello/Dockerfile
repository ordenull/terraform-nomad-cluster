FROM python:3.7.6-buster

COPY . /opt
WORKDIR /opt
RUN pip install -e .

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/xeraweb-service", "--port", "8080"]