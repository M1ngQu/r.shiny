#' Todo Orchestration service
#' 
#' @description
#'  This is the service is the primary access point of the data access layer.
#'
#' @usage NULL
#' @export
Todo.Orchestration <- \(storage) {
  process <- storage |> 
    Todo.Broker()    |> 
    Todo.Service()   |> 
    Todo.Processing()

  orchestrations <- list()
  orchestrations[['upsertretrieve']] <- \(todo) {
    todo |> process[['upsert']]()

    todos <- process[['retrieve']]()
    return(todos)
  }
  orchestrations[['retrieve']]       <- \() {
    todos <- process[['retrieve']]()
    return(todos)
  }
  orchestrations[['deleteretrieve']] <- \(id) {
    id |> process[['remove']]()

    todos <- process[['retrieve']]()
    return(todos)
  }
  return(orchestrations)
}