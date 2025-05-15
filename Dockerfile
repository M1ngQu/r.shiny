# Stage 1: Build stage
FROM rocker/r-ver:latest AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*


#set GitHub	PAT
ARG GITHUB1_PAT
ARG GITHUB2_PAT


# Install R packages
RUN R -e 'install.packages(c("devtools", "shiny", "shinydashboard", "dplyr", "DT", "shinytest2", "uuid"))'

# Install packages from GitHub
RUN R -e 'devtools::install_github(c("FlippieCoetser/Storage"))'

# Install packages from GitHub private repo
RUN GITHUB_PAT=${GITHUB1_PAT} R -e "devtools::install_github('M1ngQu/r.package')"
RUN GITHUB_PAT=${GITHUB2_PAT} R -e "devtools::install_github(c('Ri-tsuka/Validate', 'Ri-tsuka/Environment', 'Ri-tsuka/Query'))"


# Stage 2: Final stage with ODBC driver setup
FROM rocker/shiny:latest

# Copy R packages from builder
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Install dependencies required by the Microsoft ODBC driver
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver for SQL Server (official Microsoft method)
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y \
       msodbcsql18 \
       mssql-tools18 \
       unixodbc \
       unixodbc-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add SQL Server tools to the PATH environment variable
ENV PATH=$PATH:/opt/mssql-tools18/bin

# Set working directory
WORKDIR /srv/shiny-server

# Create a new .Renviron file with database connection details
# Using connection keywords from Microsoft documentation
RUN echo "ENVIRONMENT=production\n\
DRIVER={ODBC Driver 18 for SQL Server}\n\
SERVER=shiny.database.windows.net,1433\n\
DATABASE=Shiny\n\
UID=shiny\n\
PWD=j*\$bQCCrSj9&J!H2\n\
Encrypt=YES\n\
TrustServerCertificate=NO\n\
Connection Timeout=30\n\
DSN=Shiny" > /srv/shiny-server/.Renviron

# Create DSN configuration
RUN echo "[Shiny]\n\
Driver=/opt/microsoft/msodbcsql18/lib64/libmsodbcsql-18.5.so.1.1\n\
Server=shiny.database.windows.net,1433\n\
Database=Shiny\n\
UID=shiny\n\
PWD=j*\$bQCCrSj9&J!H2\n\
Encrypt=YES\n\
TrustServerCertificate=NO\n\
Connection Timeout=30\n\
" > /root/.odbc.ini

RUN echo "[Shiny]\n\
Driver=ODBC Driver 18 for SQL Server\n\
Server=shiny.database.windows.net,1433\n\
Database=Shiny\n\
UID=shiny\n\
PWD=j*\$bQCCrSj9&J!H2\n\
Encrypt=YES\n\
TrustServerCertificate=NO\n\
Connection Timeout=30\n\
" > /etc/odbc.ini

# Copy all application files
COPY . /srv/shiny-server/

# Install RODBC and odbc packages for R
RUN R -e 'install.packages(c("RODBC", "odbc", "DBI"))'

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose port
EXPOSE 3838

# Create startup script
RUN echo '#!/bin/bash\n\
# Start the Shiny app\n\
exec R -e "options(\"shiny.host\"=\"0.0.0.0\", \"shiny.port\"=3838); shiny::runApp(\"/srv/shiny-server\", host=\"0.0.0.0\", port=3838)"\n\
' > /srv/shiny-server/start.sh \
&& chmod +x /srv/shiny-server/start.sh

# Set the command to run the startup script
CMD ["/srv/shiny-server/start.sh"]