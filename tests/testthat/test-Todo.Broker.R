describe('Given Todo.Broker',{
  it('exist',{
    # Given
    Todo.Broker |> expect.exist()
  })
})

describe('When operations <- storage |> Todo.Broker()',{
  it('then operations is a list',{
    # When
    operations <- storage |> Todo.Broker()

    # Then
    operations |> expect.list()
  })
  it('then operations contains insert operation',{
    # When
    operations <- storage |> Todo.Broker()

    # Then
    operations[['insert']] |> expect.exist()
  })
  it('then operations contains select operation',{
    # When
    operations <- storage |> Todo.Broker()

    # Then
    operations[['select']] |> expect.exist()
  })
  it('then operations contains select.by.id operation',{
    # When
    operations <- storage |> Todo.Broker()

    # Then
    operations[['select.by.id']] |> expect.exist()
  })
  it('then operations contains update operation',{
    # When
    operations <- storage |> Todo.Broker()

    # Then
    operations[['update']] |> expect.exist()
  })
  it('then operations contains delete operation',{
    # When
    operations <- storage |> Todo.Broker()

    # Then
    operations[['delete']] |> expect.exist()
  })
})

describe("When todo |> operation[['insert']]()",{
  it('then todo is inserted into storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    operation <- storage |> Todo.Broker()

    new.todo      <- 'Task' |> Todo.Model()
    expected.todo <- new.todo

    # When
    new.todo |> operation[['insert']]()

    # Then
    retrieved.todo <- new.todo[['id']] |> storage[['retrieve.where.id']](table, fields)
    
    retrieved.todo |> expect.equal.data(expected.todo)
  })
})
describe("When operation[['select']]()",{
  it('then all todos are retrieved from storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    operation <- storage |> Todo.Broker()

    expected.todos <- table |> storage[['retrieve']](fields) 

    # When
    retrieved.todos <- operation[['select']]()

    # Then
    retrieved.todos |> expect.equal(expected.todos)
  })
})
describe("When id |> operation[['select.by.id']]()",{
  it('then todo with matching id is retrieved from storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')

    Todo.Mock.Data |> storage[['seed.table']]('Todo')
    
    operation <- storage |> Todo.Broker()
    
    existing.todo <- table |> storage[['retrieve']](fields) |> head(1)

    input.todo    <- existing.todo
    expected.todo <- existing.todo

    # When
    retrieved.todo <- input.todo[['id']] |> operation[['select.by.id']]()

    # Then
    retrieved.todo |> expect.equal.data(expected.todo)
  })
})
describe("When todo |> operation[['update']]()",{
  it('then todo is updated in storage',{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    operation <- storage |> Todo.Broker()

    existing.todo <- table |> storage[['retrieve']](fields) |> head(1)

    updated.todo <- existing.todo
    updated.todo[['status']] <- 'updated'

    expected.todo <- updated.todo

    # When
    updated.todo |> operation[['update']]()

    # Then
    retrieved.todo <- updated.todo[['id']] |> storage[['retrieve.where.id']](table, fields)

    updated.todo |> expect.equal.data(retrieved.todo)
  })
})
describe("When id |> operation[['delete']]()",{
  it("then todo with matching id is deleted from storage",{
    # When
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage('memory')
    
    Todo.Mock.Data |> storage[['seed.table']]('Todo')

    operation <- storage |> Todo.Broker()

    existing.todo <- table |> storage[['retrieve']](fields) |> tail(1)

    # When
    existing.todo[['id']] |> operation[['delete']]()

    # Then
    retrieved.todo <- existing.todo[['id']] |> storage[['retrieve.where.id']](table, fields)
    
    retrieved.todo |> expect.empty()
  })
})
