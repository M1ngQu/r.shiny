

# Interactive Applications in R

This repository contains a sample `Shiny` application which can be used as a boilerplate when developing enterprise-level applications using the R programming languages.

The unique feature of the Todo App includes a:

1. Custom Styling
2. Custom Shiny Module
3. Custom Event Handler
4. Custom Data Layer
5. Units Test with 100% Data Layer Coverage
6. Github Workflow with Automated Unit Testing

## Getting Started

### Installation

Whether your development environment is based on RStudio or VS Code the installation follows the same steps:

1. R `devtools` is required. Install and Reboot:

```r
install.packages("devtools")
```

If you have difficulty, please consult this [page](https://www.r-project.org/nosvn/pandoc/devtools.html) for manual installation instructions.

2. Install the application dependencies:

```r
install.packages("shiny")
install.packages("shinydashboard")
install.packages("dplyr")
install.packages("DT")
install.packages("shinytest2")
install.packages("uuid")
```

3. Install a Mock Storage Service from GitHub:

```r
devtools::install_github("https://github.com/FlippieCoetser/Validate")
devtools::install_github("https://github.com/FlippieCoetser/Environment")
devtools::install_github("https://github.com/FlippieCoetser/Query")
devtools::install_github("https://github.com/FlippieCoetser/Storage")
```

4. Clone this repository:

```bash
git clone https://github.com/FlippieCoetser/Shiny.Todo.git
```

### Run Application

Follow these steps to run the application:

1. Open your development environment and ensure your working directory is correct.
   Since the repository is called `Shiny.Todo`, you should have such a directory in the location where your cloned the repository.
   In RStudio or VS Code R terminal, you can use `getwd()` and `setwd()` to get or set the current working directory.
   Example:

```r
getwd()
# Prints: "C:/Data/Shiny.Todo"
```

3. Load mock data

```r
devtools::load_all()
```

4. Load `Shiny` Package

```r
library(shiny)
```

5. Run the application:

```r
runApp()
```

6. Application should open with this screen:

![Enterprise Application Hierarchy](/man/figures/App.Final.PNG)

## Software Architecture

Before jumping into the details of the Todo Application, it is important to understand the software architecture used. This is best explained by functionally decomposing the application into different layers with accompanying diagrams.

### Functional Decomposition

In textbooks focusing on software architecture, it is typical to see a software application segmented into three layers: `User Interface`, `Business Logic`, and `Data`.

![Architecture](/man/figures//Architecture.png)

- The `User Interface (UI)` layer is responsible for the look and feel of the application. It is the layer that the user interacts with.

- The `Business Logic (BL)` layer is responsible for the business rules of the application. It is the layer that contains the application logic.

- The `Data` layer is responsible for the data persistence of the application. It is the layer that contains the data access logic.

### Shiny Application Architecture

The software architecture presented above is not the only approach to designing software. However, as you will see it aligns well with the sample application build using `shiny`. But what is `shiny`? `Shiny` is an open-source framework made available as an R package that allows users to build interactive web applications directly from R. Shiny is intended to simplify the process of producing web-friendly, interactive data visualizations and makes it easier for R users who might not necessarily have the expertise in web development languages like HTML, CSS, and Javascript. In essence just like `vue.js` and `react` in Javascript or `Blazor` in C#, R has the `Shiny` application framework.

However, the `shiny` framework does not include a `data` layer. This is because most application developed with `shiny` only ingests data from an external source once the application starts. The data is then stored in memory and manipulated by the `business logic` layer. Below is a update architecture diagram which better reflects applications build with the `shiny` framework:

![Architecture](/man/figures//Shiny.Architecture.png)

This is not ideal for enterprise-level applications. In enterprise-level applications is more transaction based: data is not only ingested but rather the ability to create, retrieve, update or deleted from storage in very common. This sample application includes a custom `data` layer with all four common data operations: Create, Retrieve, Update and Delete (CRUD). We will look this in more detail later.

For now we return to the typical `shiny` application architecture:

- The `User Interface (UI)` is defined using different `layout`, `input`, `output` widgets and contained in the `ui.R` file. Let's take a look at the `ui.R` file in the repository to see how the UI is defined:

```r
header  <- dashboardHeader(
  title = "Todo App"
)
sidebar <- dashboardSidebar(
  disable = TRUE
)
body    <- dashboardBody(
  Todo.View("todo"),
  Custom.Style()
)

dashboardPage(
  header,
  sidebar,
  body
)
```

From a layout perspective, you can see we have a `dashboardPage` which contains `header`, `sidebar` and `body` widgets. For simplicity, the `sidebar` have been disabled. The `body` element contains a custom shiny widget: `Todo.View` and `Custom.Style()`. Although not used in the main `UI` layer, there are many standard `shiny` widgets which can be used. We will explore some when we look at the custom `Todo.View` widget.

- The `Business Logic (BL)` layer reacts to events from `input` widgets and updating of contents in `output` widgets using some predefined logic. The logic is defined in the `server.R` file. Referring back to the diagram, `3` represent events from `input` widgets captured by reactive function in the `BL` layer, while `2` represent updates pushed by the `BL` layer to `output` widgets.

Let's take a look at the `server.R` file in the repository to see how the `BL` layer is defined:

```r
shinyServer(\(input, output, session) {
  Todo.Controller("todo", data)
})
```

The `shinyServer` is part of the `shiny` framework and takes a function in which all `Business Logic` are defined. If you take a closer look at the arguments on this function you will notice `input` and `output` arguments. These arguments is how one can capture event on `input` widgets or send updates to `output` widgets. The reference to the `Todo.Controller` is part of the custom shiny module we will discuss next.

### Shiny Module Architecture

At this point it should not come as a surprise that custom module architecture is the same as the core architecture. The main difference is that the `UI` and `BL` layers are encapsulated in a module: `Todo.View` and `Todo.Controller`. Here is an update diagram with the custom `shiny` module:

![Architecture](/man/figures//Shiny.Module.Overview.png)

Important point to note: custom shiny modules always come in a pair: `View` and `Controller`. The `View` is the `UI` layer or the module, while the `Controller` is the `BL` layer. Unlike the core application, the `View` and `Controller` modules are not defined in separate files inside the `R` folder. The advantage of using custom shiny modules is that it allows us to build modular UI components, which increase reusability and scalability.

Lets look at the `Todo.View` module in more detail.

![Architecture](/man/figures//Shiny.Module.UI.png)

Here are the contents of the `Todo.View` file:

<details>
  <summary>Module UI Layer</summary>

```r
Todo.View <- \(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = div(icon("house")," Tasks"),
        status = "primary",
        solidHeader = TRUE,
        DT::dataTableOutput(
          ns("todos")
        ),
        textInput(
          ns("newTask"),
          ""
        ),
        On.Enter.Event(
          widget = ns("newTask"),
          trigger = ns("create"))
      )
    ),
    conditionalPanel(
      condition = "output.isSelectedTodoVisible",
      ns = ns,
      fluidRow(
        box(title = "Selected Todo",
            status = "primary",
            solidHeader = TRUE,
            textInput(ns("task"), "Task"),
            textInput(ns("status"), "Status"),
            column(6,
                  align = "right",
                  offset = 5,
                  actionButton(ns("update"), "Update"),
                  actionButton(ns("delete"), "Delete")
            )
        )
      )
    )
  )
}
```

Notice the many different types of UI widgets used:

- Layout: `fluidRow`, `conditionalPanel`, `box`, `column`
- Input: `textInput`
- Output: `dataTableOutput`
- Actions: `actionButton`
- Events: `On.Enter.Event` (example of a custom event)

There are many more widgets available in the Shiny framework. You can find a complete list [here](https://shiny.rstudio.com/gallery/widget-gallery.html).

</details>

Lets look at the `Todo.Controller` module in more detail.

![Architecture](/man/figures//Shiny.Module.BL.png)

Here are the contents of the `Todo.Controller` file:

<details>
  <summary>Module BL Layer</summary>

```r
Todo.Controller <- \(id, data) {
  moduleServer(
    id,
    \(input, output, session) {
      # Local State
      state <- reactiveValues()
      state[["todos"]] <- data[['Retrieve']]()
      state[["todo"]]  <- NULL

      # Input Binding
      observeEvent(input[['create']], { controller[['create']]() })
      observeEvent(input[["todos_rows_selected"]], { controller[["select"]]() }, ignoreNULL = FALSE )
      observeEvent(input[["update"]], { controller[["update"]]() })
      observeEvent(input[["delete"]], { controller[["delete"]]() })

      # Input Verification
      verify <- list()
      verify[["taskEmpty"]]    <- reactive(input[["newTask"]] == '')
      verify[["todoSelected"]] <- reactive(!is.null(input[["todos_rows_selected"]]))

      # User Actions
      controller <- list()
      controller[['create']] <- \() {
        if (!verify[["taskEmpty"]]()) {
          state[["todos"]] <- input[["newTask"]] |> Todo.Model() |> data[['UpsertRetrieve']]()
          # Clear the input
          session |> updateTextInput("task", value = '')
        }
      }
      controller[['select']] <- \() {
        if (verify[["todoSelected"]]()) {
          state[["todo"]] <- state[["todos"]][input[["todos_rows_selected"]],]

          session |> updateTextInput("task", value = state[["todo"]][["Task"]])
          session |> updateTextInput("status", value = state[["todo"]][["Status"]])

        } else {
          state[["todo"]] <- NULL
        }
      }
      controller[['update']] <- \() {
        state[['todo']][["Task"]]   <- input[["task"]]
        state[['todo']][["Status"]] <- input[["status"]]

        state[["todos"]] <- state[['todo']] |> data[["UpsertRetrieve"]]()
      }
      controller[['delete']] <- \() {
        state[["todos"]] <- state[["todo"]][["Id"]] |> data[['DeleteRetrieve']]()
      }

      # Table Configuration
      table.options <- list(
        dom = "t",
        ordering = FALSE,
        columnDefs = list(
          list(visible = FALSE, targets = 0),
          list(width = '50px', targets = 1),
          list(className = 'dt-center', targets = 1),
          list(className = 'dt-left', targets = 2)
        )
      )

      # Output Bindings
      output[["todos"]] <- DT::renderDataTable({
        DT::datatable(
          state[["todos"]],
          selection = 'single',
          rownames = FALSE,
          colnames = c("", ""),
          options = table.options
        )
      })
      output[["isSelectedTodoVisible"]] <- reactive({ is.data.frame(state[["todo"]]) })
      outputOptions(output, "isSelectedTodoVisible", suspendWhenHidden = FALSE)
    }
  )
}
```

The `Todo.Controller` is a `reactive` function which takes two arguments: `id` and `data`. The `id` is used to identify the custom shiny widget, and the `data` is used to inject the data access layer into the business logic. We will look at the data access layer in the next section. Key elements in the `Todo.Controller` are:

1. Input Events: `observeEvent`
2. Input Validation: `reactive`
3. User Actions: `controller`
4. Output Bindings: `output`

From a high level, the module `Business Logic` uses `observerEvent` to capture events from `input` widgets, execute logic using the `controller` and update the `output` using `reactiveValues`.

Many more Reactive programming functions are available as part of the Shiny framework. You can find a complete list under the Reactive Programming section [here](https://shiny.posit.co/r/reference/shiny/latest/).

</details>

### Data Layer

- The `Data (Data)` layer is responsible for `creating`, `retrieving`, `updating` and `deleting` data in long-term storage. Unfortunately, unlike `Entity Framework` in C#, R has no framework to build `Data Layers`. Typically a data access Layer includes features which translate R code to, for example, SQL statements. Input, Output and Structural Validation and Exception handling are also included. Injecting the data access layer into a Shiny application is trivial.

Here is an example of how a data access layer is injected into the sample application:

```r
# Mock Storage
configuration <- data.frame()
storage       <- configuration |> Storage::Storage(type = 'memory')

table <- 'Todo'
Todo.Mock.Data |> storage[['Seed.Table']](table)

# Data Access Layer
data  <- storage |> Todo.Orchestration()

shinyServer(\(input, output, session) {
  Todo.Controller("todo", data)
})
```

> Refer to the `Storage` package documentation for more information [here](https://github.com/FlippieCoetser/Storage)

<details>
  <summary>Custom Data Layer</summary>

The typical components in a Data Layer include:

1. Broker
2. Service
3. Processing
4. Orchestration
5. Validator
6. Exceptions

You can read all about the details of each of these components [here](https://github.com/hassanhabib/The-Standard). Here is an high-level overview of each component:

The Todo application uses a Mock Storage Service. The Mock Storage Service is a simple in-memory data structure which implements the Broker interface. The Broker interface is used to perform primitive operations against the data in storage, while the service is used to perform input and output validation. The Validator Service is used to perform structural and logic validation. The Exception Service is used to handle exceptions. The Processing Service is used to perform higher-order operations, and lastly, the Orchestration Service is used to perform a sequence of operations as required by the application.

Also, if you look closely at the `Todo.Controller` code previously presented, you will notice the use of the data layer:

1. Create Todo: `state[["todos"]] <- input[["newTask"]] |> Todo.Model() |> data[['UpsertRetrieve']]()`
2. Retrieve Todo: `state[["todos"]] <- data[['Retrieve']]()`
3. Update Todo: `state[["todos"]] <- state[['todo']] |> data[["UpsertRetrieve"]]()`
4. Delete Todo: `state[["todos"]] <- state[["todo"]][["Id"]] |> data[['DeleteRetrieve']]()`

</details> 

The complete sample application architecture is presented below:

![Architecture](/man/figures//Custom.Data.Layer.png)

Application architecture is a complex topic. This section aimed to provide a high-level overview of enterprise-level software development with a focus on R and its ecosystem. The information presented is simplified and generalized as much as possible. The best way to learn Shiny is by experimenting: clone the sample application and start playing with the code.

## Cloud Deployment

This application can be deployed to Azure using the provided scripts and GitHub Actions workflows. This section explains the deployment process and infrastructure setup for production environments.

### Azure Infrastructure Setup

The project includes bash scripts to provision and manage the required Azure infrastructure:

#### Prerequisites

Before running the Azure setup scripts, ensure you have:

1. Installed the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. Authenticated with Azure:
   ```bash
   az login
   ```
3. Set the proper execute permissions on the scripts (Linux/macOS/WSL):
   ```bash
   chmod +x scripts/setup-azure.sh
   chmod +x scripts/cleanup-azure.sh
   ```

#### Setup Azure Resources

Use the `scripts/setup-azure.sh` script to create all necessary Azure resources:

```bash
# Run from bash terminal or WSL
./scripts/setup-azure.sh

# For Windows PowerShell, you can use:
# & 'C:\Program Files\Git\bin\bash.exe' -c './scripts/setup-azure.sh'
# or
# wsl -e ./scripts/setup-azure.sh
```

This script creates the following resources:

- Resource Group (`r-shiny-rg`)
- Azure Container Registry (`rshinycr.azurecr.io`)
- App Service Plan (Linux-based)
- Web App configured for containers
- Azure AD App Registration for authentication
- Key Vault for securely storing secrets
- Managed Identity for the Web App

After running the script, it will output all the credentials needed for GitHub Actions configuration and application settings.

#### Clean Up Azure Resources

When you're done with the environment, you can remove all resources using:

```bash
# Run from bash terminal or WSL
./scripts/cleanup-azure.sh

# For Windows PowerShell, you can use:
# & 'C:\Program Files\Git\bin\bash.exe' -c './scripts/cleanup-azure.sh'
# or
# wsl -e ./scripts/cleanup-azure.sh
```

### Containerization

The application is containerized using Docker. The `Dockerfile` in the root of the repository defines how the R Shiny application is packaged into a container image.

#### Dockerfile Structure

The Dockerfile uses a multi-stage build approach to optimize the final image size and improve security:

1. **Builder Stage**: Uses `rocker/r-ver` as base image to install R packages
2. **Final Stage**: Uses `rocker/shiny` as the base image for the application

Here's a breakdown of the key sections in our Dockerfile:

```dockerfile
# Stage 1: Build stage
FROM rocker/r-ver:latest AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GitHub PAT
ARG GITHUB1_PAT
ARG GITHUB2_PAT

# Install R packages
RUN R -e 'install.packages(c("devtools", "shiny", "shinydashboard", "dplyr", "DT", "shinytest2", "uuid"))'

# Install packages from GitHub
RUN R -e 'devtools::install_github(c("FlippieCoetser/Storage"))'

# Stage 2: Final stage with ODBC driver setup
FROM rocker/shiny:latest

# Copy R packages from builder
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Install Microsoft ODBC Driver for SQL Server
# ... ODBC setup commands ...

# Copy all application files
COPY . /srv/shiny-server/
```

#### ODBC Configuration

The application is configured to connect to databases using ODBC. The Dockerfile includes setup for Microsoft SQL Server drivers, which work differently on Linux (container) and Windows environments.

##### Linux (Container) ODBC Setup

In the Docker container (Linux-based), ODBC is configured as follows:

```dockerfile
# Install Microsoft ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y \
       msodbcsql18 \
       mssql-tools18 \
       unixodbc \
       unixodbc-dev

# Create DSN configuration
RUN echo "[Shiny]\n\
Driver=/opt/microsoft/msodbcsql18/lib64/libmsodbcsql-18.5.so.1.1\n\
Server=shiny.database.windows.net,1433\n\
Database=Shiny\n\
UID=shiny\n\
PWD=****\n\
Encrypt=YES\n\
TrustServerCertificate=NO\n\
Connection Timeout=30\n\
" > /root/.odbc.ini
```

##### Windows ODBC Setup

For development on Windows, you'll need to:

1. Download and install the [Microsoft ODBC Driver 18 for SQL Server](https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
2. Configure your DSN through the Windows ODBC Data Source Administrator:
   - Open "ODBC Data Sources (64-bit)" from Windows search
   - Go to "User DSN" tab
   - Click "Add" and select "ODBC Driver 18 for SQL Server"
   - Configure with same parameters as in the Dockerfile:
     - Name: Shiny
     - Server: shiny.database.windows.net,1433
     - Database: Shiny
     - Authentication: SQL Server authentication

3. In your R environment, you can test the connection with:

```r
library(odbc)
con <- dbConnect(odbc::odbc(), "Shiny")
```

#### Building and Running Locally

For local testing, you can build and run the container:

```bash
docker build -t todo-app:local .
docker run -p 3838:3838 todo-app:local
```

To build with GitHub PATs for private repositories:

```bash
docker build --build-arg GITHUB1_PAT=your_pat_here --build-arg GITHUB2_PAT=your_other_pat_here -t todo-app:local .
```

### GitHub Actions Workflows

The application uses two GitHub Actions workflows for CI/CD:

#### 1. Build Docker Image

The workflow defined in `.github/workflows/build-image.yml` handles building and pushing the Docker image to Azure Container Registry:

- **Trigger**: Manual (workflow_dispatch)
- **Environment Variables**:
  - `ACR_NAME`: "rshinycr"
  - `ACR_LOGIN_SERVER`: "rshinycr.azurecr.io"
  - `IMAGE_NAME`: "todo-app"
- **Process**:
  - Logs in to Azure using service principal credentials
  - Builds the Docker image with GitHub PATs for accessing private packages
  - Pushes the image to Azure Container Registry

#### 2. Deploy Application

The workflow defined in `.github/workflows/deploy-app.yml` handles deploying the application to Azure App Service:

- **Trigger**: 
  - Push to main branch (excluding changes to Dockerfile, scripts, build workflow, and README)
  - Manual trigger (workflow_dispatch)
- **Environment Variables**:
  - Resource group, location, ACR login server, etc.
  - Azure AD authentication settings
- **Process**:
  - Updates container settings for the App Service
  - Configures Key Vault references for secure access to secrets
  - Sets up Azure AD Authentication
  - Restarts the App Service
  - Verifies the deployment by checking the health endpoint

### Required Secrets

To run the GitHub workflows, you need to configure the following secrets in your GitHub repository:

- `AZURE_CREDENTIALS`: JSON credentials for Azure authentication (output by setup script)
- `AZURE_TENANT_ID`: Your Azure tenant ID
- `AAD_CLIENT_ID`: Azure AD application client ID
- `GITHUB1_PAT` and `GITHUB2_PAT`: GitHub Personal Access Tokens for private package access

#### Creating GitHub Personal Access Tokens

To create the required GitHub PATs:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token"
3. Give it a name and select the scopes: `repo`, `read:packages`
4. Click "Generate token" and copy the token value
5. Add this token as a repository secret

### Azure AD Authentication

The application is configured with Azure AD authentication:

- Authentication is enabled using the Azure App Service AuthV2 feature
- Microsoft identity provider is configured with your AAD client ID
- Token audience is set to the application's API URI
- Unauthenticated clients are redirected to the login page

### Deployment Sequence

The typical deployment sequence is:

1. Run `scripts/setup-azure.sh` to provision the Azure infrastructure (one-time setup)
2. Configure the required secrets in your GitHub repository
3. Manually trigger the build workflow to build and push the Docker image
4. Automatically or manually trigger the deploy workflow to update the App Service

After deployment, your application will be available at: `https://shiny-web-app.azurewebsites.net`

You can verify your deployment is working properly by checking the health endpoint at:
`https://shiny-web-app.azurewebsites.net/health`

This endpoint should return an HTTP 200 status code if the application is running correctly. The deploy workflow automatically checks this endpoint as part of the deployment verification process.

### Monitoring and Maintenance

Once deployed, you can monitor your application using:

- Azure Portal (App Service logs and metrics)
- Application Insights (if configured)
- Azure Container Registry for image management

To update the application:

1. Make changes to your code
2. Commit and push to the main branch
3. The deploy workflow will automatically trigger
4. For changes to the Docker image, manually trigger the build workflow first

If you need to remove the infrastructure, run `scripts/cleanup-azure.sh`
 
