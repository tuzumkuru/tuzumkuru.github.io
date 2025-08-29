# Use a Node.js base image to get npm and a stable OS
FROM node:20-bullseye-slim

# Set the Hugo version from your GitHub Actions workflow
ARG HUGO_VERSION=0.124.1
# Set an env var for Hugo version
ENV HUGO_VERSION=${HUGO_VERSION}

# Set Dart Sass version for direct download
ARG SASS_VERSION=1.75.0

# Install dependencies needed for Hugo
# Install dependencies, Hugo, and then clean up in a single layer to optimize image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    ca-certificates \
    golang \
    && wget "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" -O /tmp/hugo.deb \
    && dpkg -i /tmp/hugo.deb \
    # Download and install Dart Sass directly to avoid npm overhead
    && wget "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz" -O /tmp/sass.tar.gz \
    && tar -xzf /tmp/sass.tar.gz -C /usr/local \
    && ln -s /usr/local/dart-sass/sass /usr/local/bin/sass \
    # Clean up downloaded files and packages to reduce image size
    && apt-get purge -y --auto-remove wget \
    && rm -rf /var/lib/apt/lists/* /tmp/hugo.deb /tmp/sass.tar.gz

# Set the working directory inside the container
WORKDIR /src

# If you use npm packages, you can uncomment the following lines.
# This requires a `package.json` and `package-lock.json` file in your project root.
# ---------------------------------------------------------------------
# COPY package.json package-lock.json* ./
# RUN if [ -f package-lock.json ]; then npm ci; fi

# Expose the Hugo server port
EXPOSE 1313

# The command to run for development.
ENTRYPOINT ["hugo"]
CMD ["server", "-D", "--bind", "0.0.0.0", "--baseURL", "http://localhost:1313/", "--noHTTPCache", "--poll=700ms"]
