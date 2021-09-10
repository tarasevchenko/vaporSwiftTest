import Vapor

struct Task: Content {
    let name: String
    let deadline: String
}

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    try app.register(collection: UserController())
    try app.register(collection: NoteController())
}

