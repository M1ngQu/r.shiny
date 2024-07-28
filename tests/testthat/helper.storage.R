# Mock Broker table name, fields, and data
sql.utilities <- Query::SQL.Utilities()
sql.functions <- Query::SQL.Functions()

table <- 'ToDo'
fields <- list(
  'id'     |> sql.utilities[['BRACKET']]() |> sql.functions[['LOWER']]('id'),
  'task'   |> sql.utilities[['BRACKET']](),
  'status' |> sql.utilities[['BRACKET']]()
)