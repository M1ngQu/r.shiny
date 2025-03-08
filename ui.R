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