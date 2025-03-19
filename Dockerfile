# Stage 1: Build stage
FROM rocker/r-ver:latest AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e 'install.packages(c("devtools", "shiny", "shinydashboard", "dplyr", "DT", "shinytest2", "uuid"))'

# Install packages from GitHub
RUN R -e 'devtools::install_github(c("FlippieCoetser/Validate", "FlippieCoetser/Environment", "FlippieCoetser/Query", "FlippieCoetser/Storage"))'

# Stage 2: Final stage
FROM rocker/shiny:latest

# Copy R packages from builder
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Set working directory
WORKDIR /srv/shiny-server

# Copy application files
COPY . .

# Expose port
EXPOSE 3838

# Set the command to run the app
CMD ["R", "-e", "shiny::runApp(host = '0.0.0.0', port = 3838)"]