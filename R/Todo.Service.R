Todo.Service <- \(broker){
  validate.structure <- Todo.Structure.Validation()
  validate.logic     <- Todo.Logic.Validation()
  
  services <- list()
  services[["add"]]          <- \(todo) {
    todos <- broker[['select']]()
    
    todo |>
      validate.structure[['Todo']]() |>
      validate.logic[['IsDuplicate']](todos)
    
    todo |>
      broker[['insert']]()

    return(data.frame())
  }
  services[['retrieve']]     <- \(...) {
    ... |> broker[['select']]()
  }
  services[["retrieve.by.id"]] <- \(id) {
    id |>
      validate.structure[['IdExist']]()

    id |> 
      broker[['select.by.id']]()
  }
  services[['modify']]       <- \(todo) {
    todo |>
      validate.structure[['Todo']]()
    
    todo |>
      broker[['update']]()

    return(data.frame())
  }
  services[['remove']]       <- \(id) {
    id |>
      validate.structure[['IdExist']]()
    
    id |>
      broker[['delete']]()

    return(data.frame())
  }  
  
  return(services)
}