# Base R Shiny image
FROM rocker/shiny

# Install R dependencies
RUN R -e "install.packages(c('httr', 'jsonlite', 'shinythemes', 'DT', 'shinycssloaders', 'shinyjs'))"

# Copy the model and any other necessary files into the container
COPY ./shiny-app.R /app.R

# Set the working directory
WORKDIR /app

# Expose the application port
EXPOSE 8180

# Run the R Shiny app
CMD Rscript -e "shiny::runApp('/app.R', host = '0.0.0.0', port = 8180)"