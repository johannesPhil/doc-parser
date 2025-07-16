# Use official Ruby 
FROM ruby:3.2

# Install dependencies
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends build-essential libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["irb"]

