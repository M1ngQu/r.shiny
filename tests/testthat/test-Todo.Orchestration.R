describe('Given Todo.Orchestration',{
  it('exist',{
    # Given
    Todo.Orchestration |> expect.exist()
  })
})

describe('When orchestrations <- storage |> Todo.Orchestration()',{
  it('then operations is a list',{
    # When
    orchestrations <- storage |> Todo.Orchestration()

    # Then
    orchestrations |> expect.list()
  })
  it('then orchestrations contain upsert.retrieve orchestration',{
    # When
    orchestrations <- storage |> Todo.Orchestration()

    # Then
    orchestrations[['upsert.retrieve']] |> expect.exist()
  })
  it('then orchestrations contain retrieve orchestration',{
    # When
    orchestrations <- storage |> Todo.Orchestration()

    # Then
    orchestrations[['retrieve']] |> expect.exist()
  })
  it('then orchestrations contain delete.retrieve orchestration',{
    # When
    orchestrations <- storage |> Todo.Orchestration()

    # Then
    orchestrations[['delete.retrieve']] |> expect.exist()
  })
})

describe('When todo |> orchestrate[["upsert.retrieve"]]()',{
  it('then a data.frame with todos containing new todo is returned',{
    # Given    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    orchestrate <- storage |> Todo.Orchestration()

    random.todo <- 'Task' |> Todo.Model()

    new.todo      <- random.todo
    expected.todo <- new.todo 

    # When
    retrieved.todos <- new.todo |> orchestrate[["upsert.retrieve"]]()

    # Then
    retrieved.todos |> expect.contain(expected.todo)
  })
  it("then a data.frame with todos containing update todo is returned",{
    # Given    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    orchestrate <- storage |> Todo.Orchestration()

    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)

    updated.todo  <- existing.todo
    updated.todo[['task']] <- 'updated Task'
    
    expected.todo <- updated.todo

    # When
    retrieved.todos <- updated.todo |> orchestrate[['upsert.retrieve']]()
    retrieved.todo  <- retrieved.todos[retrieved.todos[['id']] == updated.todo[['id']],] 

    # Then
    retrieved.todos |> expect.contain(expected.todo)

    retrieved.todo[['id']]     |> expect.equal(expected.todo[['id']])
    retrieved.todo[['task']]   |> expect.equal(expected.todo[['task']])
    retrieved.todo[['status']] |> expect.equal(expected.todo[['status']])
  })
})

describe('When orchestrate[["retrieve"]]()',{
  it('then a data.frame with todos is returned',{
    # Given    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    orchestrate <- storage |> Todo.Orchestration()

    actual.todos   <- table |> storage[['retrieve']](fields)
    expected.todos <- actual.todos

    # When
    retrieved.todos <- orchestrate[['retrieve']]()

    # Then
    retrieved.todos |> expect.equal(expected.todos)
  })
})

describe("When id |> orchestrate[['delete.retrieve']]()",{
  it("then a data.frame with todos excluding todo with id is returned",{
    # Given    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    orchestrate <- storage |> Todo.Orchestration()

    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)
    existing.id <- existing.todo[['id']]

    # When 
    retrieved.todos <- existing.id |> orchestrate[['delete.retrieve']]()

    # Then
    retrieved.todos |> expect.not.contain(existing.todo)
  })
})