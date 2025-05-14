describe('Given Todo.Structure.Validation',{
  it('exist',{
    # Given
    Todo.Structure.Validation |> expect.exist()
  })
})

describe("When validators <- Todo.Structure.Validation()",{
  it('then validators is a list',{
    # Given
    validators <- Todo.Structure.Validation()

    # Then
    validators |> expect.list()
  })
  it('then validators contains TodoExist validator',{
    # Given
    validators <- Todo.Structure.Validation()

    # Then
    validators[['TodoExist']] |> expect.exist()
  })
  it('then validators contains HasId validator',{
    # Given
    validators <- Todo.Structure.Validation()

    # Then
    validators[['HasId']] |> expect.exist()
  })
  it('then validators contains HasTask validator',{
    # Given
    validators <- Todo.Structure.Validation()

    # Then
    validators[['HasTask']] |> expect.exist()
  })
  it('then validators contains HasStatus validator',{
    # Given
    validators <- Todo.Structure.Validation()

    # Then
    validators[['HasStatus']] |> expect.exist()
  })
  it('then validators contains Todo validator',{
    # Given
    validators <- Todo.Structure.Validation()

    # Then
    validators[['Todo']] |> expect.exist()
  })
  it('then validators contains IdExist validator',{
    # Given
    validators <- Todo.Structure.Validation()

    # Then
    validators[['IdExist']] |> expect.exist()
  })
})

describe("When todo |> validate[['TodoExist']]()",{
  it('then no exception is thrown if todo exist',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame()

    # Then
    todo |> validate[['TodoExist']]() |> expect.no.error()
  })
  it('then an exception is thrown if todo is null',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- NULL

    expected.error <- 'successful validation requires a data frame with todo'

    # Then
    todo |> validate[['TodoExist']]() |> expect.error(expected.error)
  })
})
describe("When todo |> validate[['HasId']]()",{
  it('then no exception is thrown if todo has Id',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame(
      id = 'Id'
    )

    # Then
    todo |> validate[['HasId']]() |> expect.no.error()
  })
  it('then an exception is thrown if todo has no id',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame()

    expected.error <- 'todo data frame has no id'

    # Then
    todo |> validate[['HasId']]() |> expect.error(expected.error)
  })
})
describe("When todo |> validate[['HasTask']]()",{
  it('then no exception is thrown if todo has task',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame(
      task = 'Task'
    )

    # Then
    todo |> validate[['HasTask']]() |> expect.no.error()
  })
  it('then an exception is thrown if todo has no task',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame()

    expected.error <- 'todo data frame has no task'

    # Then
    todo |> validate[['HasTask']]() |> expect.error(expected.error)
  })
})
describe("When todo |> validate[['HasStatus']]()",{
  it('then no exception is thrown if todo has status',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame(
      status = 'Status'
    )

    # Then
    todo |> validate[['HasStatus']]() |> expect.no.error()
  })
  it('then an exception is thrown if todo has no status',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame()

    expected.error <- 'todo data frame has no status'

    # Then
    todo |> validate[['HasStatus']]() |> expect.error(expected.error)
  })
})
describe("When todo |> validate[['Todo']]()",{
  it('then no exception is thrown if todo is valid',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame(
      id     = 'Id',
      task   = 'Task',
      status = 'Status'
    )

    # Then
    todo |> validate[['Todo']]() |> expect.no.error()
  })
  it('then an exception is thrown if todo is null',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- NULL

    expected.error <- 'successful validation requires a data frame with todo'

    # Then
    todo |> validate[['Todo']]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo has no id',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame()

    expected.error <- 'todo data frame has no id'

    # Then
    todo |> validate[['Todo']]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo has no task',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame(
      id = 'Id'
    )

    expected.error <- 'todo data frame has no task'

    # Then
    todo |> validate[['Todo']]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo has no status',{
    # Given
    validate <- Todo.Structure.Validation()

    todo  <- data.frame(
      id     = 'Id',
      task   = 'Task'
    )

    expected.error <- 'todo data frame has no status'

    # Then
    todo |> validate[['Todo']]() |> expect.error(expected.error)
  })
})
describe("When id |> validate[['IdExist']]()",{
  it('then no exception is thrown if id exist',{
    # Given
    validate <- Todo.Structure.Validation()

    id  <- uuid::UUIDgenerate()

    # Then
    id |>
      validate[['IdExist']]() |>
        expect.no.error()
  })
  it('then an exception is thrown if id is null',{
    # Given
    validate <- Todo.Structure.Validation()

    id  <- NULL

    expected.error <- 'successful validation requires an id'

    # Then
    id |>
      validate[['IdExist']]() |>
        expect.error(expected.error)
  })
})