Todo.Processing <- \(service) {
  processors <- list()
  processors[['retrieve']] <- \() {
    service[['retrieve']]()
  }
  processors[['upsert']]   <- \(todo) {
    todo.exist <- todo[['id']] |> service[['retrieve.by.id']]() |> nrow() > 0

    if(todo.exist) {
      todo |> service[['modify']]()
    } else {
      todo |> service[['add']]()
    }
  }
  processors[['remove']]   <- \(id) {
    id |> service[['remove']]()
  }
  return(processors)
}
