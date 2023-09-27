FROM python:3.11-slim

WORKDIR /app

RUN pip install Flask Flask-Cors

COPY app.py .

EXPOSE 5000

CMD [ "flask", "run","--host","0.0.0.0","--port","5000"]