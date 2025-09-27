# Use Ruby 3.2.0 as base image
FROM ruby:3.2.0

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile
COPY Gemfile ./

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Create necessary directories
RUN mkdir -p tmp/pids

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]