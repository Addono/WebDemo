FROM python:3

WORKDIR /app

# Install requirements
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy source code
COPY demoapp/ ./demoapp/

EXPOSE 7272

ENTRYPOINT ["python", "demoapp/server.py"]
