# Dockerfile (replace your current one)
FROM ruby:3.2

# Install OS packages we need
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      postgresql-client \
      python3 \
      python3-venv \
      ca-certificates \
      curl \
    && rm -rf /var/lib/apt/lists/*

# Create and activate a virtualenv for Python dependencies
ENV VENV_PATH=/opt/venv
RUN python3 -m venv ${VENV_PATH}
ENV PATH="${VENV_PATH}/bin:$PATH"

# Make sure pip/setuptools/wheel are up-to-date
RUN pip install --upgrade pip setuptools wheel

# Install Python libs into the venv
# Pin versions if you want reproducible builds
RUN pip install --no-cache-dir transformers tokenizers

# Set working dir for app
WORKDIR /app

# Copy Ruby gems and install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app files
COPY . .

# Default command (change if you want another)
CMD ["irb"]
