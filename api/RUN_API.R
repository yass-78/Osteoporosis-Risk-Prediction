# Load the necessary library for creating REST APIs in R
library(plumber)

# Load the API script located at the specified path
# The `plumb` function reads the R script and prepares it for use as an API.
pr <- plumb("api/API.R")

# Run the API on port 8000
# The `run` method starts a local server on the specified port, allowing access to the API.
pr$run(port = 8000)

