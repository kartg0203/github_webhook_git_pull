FROM python:3.12.3-alpine3.20

RUN pip install Flask

WORKDIR /app

COPY . /app

RUN chmod +x /app/git_pull.sh

ENV FLASK_APP=app.py

RUN mkdir -p /app/repositories

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
