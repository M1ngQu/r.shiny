describe('Given Todo.Processing',{
  it('exist',{
    # Given
    Todo.Processing |> expect.exist()
  })
})

describe('When processors <- storage |> Todo.Processing()',{
  it('then processors is a list',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    processors <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()

    # Then
    processors |> expect.list()
  })
  it('then processors contains retrieve processor',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    processors <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()

    # Then
    processors[['retrieve']] |> expect.exist()
  })
  it('then processors contains upsert processor',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    processors <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()

    # Then
    processors[['upsert']] |> expect.exist()
  })
  it('then processors contains remove processor',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    processors <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()

    # Then
    processors[['remove']] |> expect.exist()
  })
})

describe("when process[['retrieve']]()",{
  it("then a data.frame with all Todos are returned",{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    process <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()


    # modified
    table  <- "Todo"

    actual.todos   <- table |> storage[['retrieve']](fields)
    expected.todos <- actual.todos

    # When
    retrieved.todos <- process[['retrieve']]()

    # Then
    retrieved.todos |> expect.equal(expected.todos)
  })
})

describe("when todo |> process[['upsert']]()",{
  it("then todo is added to todos if not exist",{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    process <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()

    random.todo   <- 'Task' |> Todo.Model()
    new.todo      <- random.todo 

    expected.todo <- new.todo
    
    # When
    new.todo |> process[['upsert']]()


    # modified
    table  <- "Todo"

    # Then
    retrieved.todos <- table |> storage[['retrieve']](fields)
    retrieved.todos |> expect.contain(expected.todo)
  })
  it("then todo is updated if exist",{
    # Given    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')
    
    process <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()

    # modified
    table  <- "Todo"

    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)

    updated.todo  <- existing.todo
    updated.todo[['task']] <- 'updated Task'

    expected.todo <- updated.todo

    # When
    updated.todo |> process[['upsert']]()

    # Then
    retrieved.todo <- updated.todo[['id']] |> storage[['retrieve.where.id']](table, fields)

    retrieved.todo[['id']]     |> expect_equal(expected.todo[['id']])
    retrieved.todo[['task']]   |> expect_equal(expected.todo[['task']])
    retrieved.todo[['status']] |> expect_equal(expected.todo[['status']])
  })
})

describe("then id |> process[['remove']]()",{
  it("then todo is removed from todos",{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    process <- storage |> Todo.Broker() |> Todo.Service() |> Todo.Processing()

    # modified
    table  <- "Todo"
    
    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)

    # When
    existing.todo[['id']] |> process[['remove']]()

    # Then
    existing.todo[['id']] |> storage[['retrieve.where.id']](table, fields) |> expect.empty()
  })
})