Todo.Broker <- \(storage){
  sql.utilities <- Query::SQL.Utilities()
  sql.functions <- Query::SQL.Functions()

  table <- 'ToDo'
  fields <- list(
    'id'     |> sql.utilities[['BRACKET']]() |> sql.functions[['LOWER']]('id'),
    'task'   |> sql.utilities[['BRACKET']](),
    'status' |> sql.utilities[['BRACKET']]()
  )
  
  operations <- list()
  operations[['insert']]        <- \(todo) {
    todo |> storage[['add']](table)
  }
  operations[['select']]        <- \(...)  {
    table |> storage[['retrieve']](fields)
  }
  operations[['select.by.id']]    <- \(id)   {
    id |> storage[['retrieve.where.id']](table, fields)
  }
  operations[['update']]        <- \(todo) {
    todo |> storage[['modify']](table)
  }
  operations[['delete']]        <- \(id)   {
    id |> storage[['remove']](table)
  }
  return(operations)
}