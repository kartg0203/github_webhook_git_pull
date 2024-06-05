FROM python:3.12.3-alpine3.20

RUN apk add --no-cache git openssh

RUN pip install Flask

WORKDIR /app

COPY app.py /app/app.py

COPY git-pull.sh /app/git-pull.sh

RUN chmod +x /app/git-pull.sh

COPY .ssh/id_rsa /root/.ssh/id_rsa

RUN chmod 600 /root/.ssh/id_rsa

COPY .ssh/known_hosts /root/.ssh/known_hosts

RUN chmod 600 /root/.ssh/known_hosts


ENV FLASK_APP=app.py

RUN mkdir -p /app/repositories

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
