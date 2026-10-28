########## BUILD STAGE
FROM python:3.11-slim AS build

WORKDIR /build 

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt 

### MAIN STAGE 
FROM python:3.11-slim as runner 

WORKDIR /app 

# creating a non-root user and switching to it 
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /sbin/nologin -M appuser 


COPY --from=build /root/.local  /home/appuser/.local 

COPY app.py .

# adding permissions to the non-root user for the application directory and home directory
RUN chown -R appuser:appgroup /app /home/appuser 


ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1



# switching to the non-root user
USER appuser 

EXPOSE 8080 

CMD ["uvicorn" , "app:app" , "--host" , "0.0.0.0" , "--port" , "8080" ]

