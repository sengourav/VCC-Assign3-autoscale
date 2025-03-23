GNU nano 7.2
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the app files
COPY app.py /app

# Install dependencies
RUN pip install Flask

# Expose port 80
EXPOSE 80

# Run the app
CMD ["python", "app.py"]
