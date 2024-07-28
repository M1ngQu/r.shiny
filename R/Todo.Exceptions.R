Todo.Exceptions <- \(){
  exceptions <- list()
  exceptions[["TodoIsNull"]]       <- \(invoke) {
    if (invoke) { stop("successful validation requires a data frame with todo")}
  }
  exceptions[["TodoIdIsNull"]]     <- \(invoke) {
    if (invoke) { stop("todo data frame has no id")}
  }
  exceptions[["TodoTaskIsNull"]]   <- \(invoke) {
    if (invoke) { stop("todo data frame has no task")}
  }
  exceptions[["TodoStatusIsNull"]] <- \(invoke) {
    if (invoke) { stop("todo data frame has no status")}
  }
  exceptions[["IdIsNull"]]         <- \(invoke) {
    if (invoke) { stop("successful validation requires an id")}
  }
  exceptions[["DuplicateKey"]]     <- \(invoke) {
    if (invoke) { stop("todo already exist, duplicate key not allowed") }
  }
  return(exceptions)
}