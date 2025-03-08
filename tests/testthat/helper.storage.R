# Mock Broker table name, fields, and data
sql.utilities <- Query::SQL.Utilities()
sql.functions <- Query::SQL.Functions()

table <- 'Todo'
fields <- list(
  'id'     |> sql.utilities[['BRACKET']]() |> sql.functions[['LOWER']]('id'),
  'task'   |> sql.utilities[['BRACKET']](),
  'status' |> sql.utilities[['BRACKET']]()
)