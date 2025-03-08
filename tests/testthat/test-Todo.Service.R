describe("Given Todo.Service",{
  it('exist',{
    # Given
    Todo.Service |> expect.exist()
  })
})

describe('When services <- Todo.Service()',{
  it('then services is a list',{
    # Given
    services <- Todo.Service()

    # Then
    services |> expect.list()
  })
  it('then services contains add operation',{
    # Given
    services <- Todo.Service()

    # Then
    services[['add']] |> expect.exist()
  })
  it('then services contains retrieve operation',{
    # Given
    services <- Todo.Service()

    # Then
    services[['retrieve']] |> expect.exist()
  })
  it('then services contains retrieve.by.id operation',{
    # Given
    services <- Todo.Service()

    # Then
    services[['retrieve.by.id']] |> expect.exist()
  })
  it('then services contains modify operation',{
    # Given
    services <- Todo.Service()

    # Then
    services[['modify']] |> expect.exist()
  })
  it('then services contains remove operation',{
    # Given
    services <- Todo.Service()

    # Then
    services[['remove']] |> expect.exist()
  })
})

describe("When todo |> service[['add']]()",{
  it('then todo is added to storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    random.todo <- 'Task' |> Todo.Model()

    new.todo      <- random.todo
    expected.todo <- new.todo

    # When
    new.todo |> service[["add"]]()

    # Then
    retrieved.todo <- new.todo[['id']] |> storage[['retrieve.where.id']](table, fields)

    retrieved.todo |> expect.equal.data(expected.todo)
  })
  it('then an exception is thrown if todo has no id',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    invalid.todo <- data.frame(
      task = 'Task',
      status = 'New'
    )

    new.todo <- invalid.todo
    expected.error <- 'todo data frame has no id'

    # Then
    new.todo |> service[["add"]]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo has no task',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()
    invalid.todo <- data.frame(
      id = uuid::UUIDgenerate(),
      status = 'New'
    )

    new.todo <- invalid.todo
    expected.error <- 'todo data frame has no task'

    # Then
    new.todo |> service[["add"]]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo has no status',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    invalid.todo <- data.frame(
      id = uuid::UUIDgenerate(),
      task = 'Task'
    )

    new.todo <- invalid.todo
    expected.error <- 'todo data frame has no status'

    # Then
    new.todo |> service[["add"]]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo is null',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    invalid.todo <- NULL

    new.todo <- invalid.todo
    expected.error <- 'successful validation requires a data frame with todo'

    # Then
    new.todo |> service[["add"]]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo already exist',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)

    new.todo <- existing.todo
    expected.error <- 'todo already exist, duplicate key not allowed'

    # Then
    new.todo |> service[["add"]]() |> expect.error(expected.error)
  })
})
describe("When service[['retrieve']]()",{
  it('then all todos are retrieved from storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    expected.todos <- table |> storage[['retrieve']](fields)

    # When
    retrieved.todos <- service[['retrieve']]()

    # Then
    retrieved.todos |> expect.equal(expected.todos)
  })
})
describe("When id |> service[['retrieve.by.id']]()",{
  it('then todo with matching id is retrieved from storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)

    input.todo    <- existing.todo
    expected.todo <- existing.todo

    # When
    retrieved.todo <- input.todo[['id']] |> service[['retrieve.by.id']]()

    # Then
    retrieved.todo[['id']]     |> expect.equal(expected.todo[["id"]])
    retrieved.todo[['task']]   |> expect.equal(expected.todo[["task"]])
    retrieved.todo[['status']] |> expect.equal(expected.todo[["status"]])
  })
  it("then an exception is thrown if id is NULL",{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    id <- NULL

    expected.error <- 'successful validation requires an id'

    # Then
    id |> service[['retrieve.by.id']]() |> expect.error(expected.error)
  })
})
describe("When todo |> service[['modify']]()",{
  it('then todo is updated in storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    existing.todo <- table |> storage[['retrieve']](fields) |> head(1)

    updated.todo <- existing.todo
    updated.todo[['status']] <- 'Done'

    expected.todo <- updated.todo

    # When
    updated.todo |> service[['modify']]()

    # Then
    retrieved.todo <- updated.todo[['id']] |> storage[['retrieve.where.id']](table, fields)

    retrieved.todo[['id']]     |> expect_equal(expected.todo[['id']])
    retrieved.todo[['task']]   |> expect_equal(expected.todo[['task']])
    retrieved.todo[['status']] |> expect_equal(expected.todo[['status']])
  })
  it('then an exception is thrown if todo has no id',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    invalid.todo <- data.frame(
      task   = 'Task',
      status = 'New'
    )

    updated.todo <- invalid.todo
    expected.error <- 'todo data frame has no id'

    # Then
    updated.todo |> service[['modify']]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo has no task',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()
    invalid.todo <- data.frame(
      id     = uuid::UUIDgenerate(),
      status = 'New'
    )

    updated.todo <- invalid.todo
    expected.error <- 'todo data frame has no task'

    # Then
    updated.todo |> service[['modify']]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo has no status',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()

    invalid.todo <- data.frame(
      id   = uuid::UUIDgenerate(),
      task = 'Task'
    )

    updated.todo <- invalid.todo
    expected.error <- 'todo data frame has no status'

    # Then
    updated.todo |> service[['modify']]() |> expect.error(expected.error)
  })
  it('then an exception is thrown if todo is null',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()
    invalid.todo <- NULL

    updated.todo <- invalid.todo
    expected.error <- 'successful validation requires a data frame with todo'

    # Then
    updated.todo |> service[['modify']]() |> expect.error(expected.error)
  })
})
describe("When id |> service[['remove']]()",{
  it('then todo is deleted from storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')

    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <-  storage |> Todo.Broker() |> Todo.Service()
    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)

    # When
    existing.todo[['id']] |> service[['remove']]()

    # Then
    existing.todo[['id']] |> storage[['retrieve.where.id']](table, fields) |> expect.empty()
  })
  it('then an exception is thrown if id is null',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')

    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    service <- storage |> Todo.Broker() |> Todo.Service()

    id <- NULL

    expected.error <- 'successful validation requires an id'

    # Then
    id |> service[['remove']]() |> expect.error(expected.error)
  })
})
