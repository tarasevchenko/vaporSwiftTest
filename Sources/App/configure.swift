import Fluent
import FluentPostgresDriver
import Vapor


extension Environment {
    
    static var databaseURL: URL {
        guard let urlString = Environment.get("DATABASE_URL"), let url = URL(string: urlString) else {
            fatalError("DATABASE_URL not configured")
        }
        return url
    }
}

public func configure(_ app: Application) throws {
  let encoder = JSONEncoder()
  encoder.keyEncodingStrategy = .convertToSnakeCase
  encoder.dateEncodingStrategy = .iso8601
  
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  decoder.dateDecodingStrategy = .iso8601
  
  ContentConfiguration.global.use(encoder: encoder, for: .json)
  ContentConfiguration.global.use(decoder: decoder, for: .json)
    
try app.databases.use(.postgres(url: Environment.databaseURL), as: .psql)
  
  app.middleware.use(ErrorMiddleware.default(environment: app.environment))
  
  app.migrations.add(CreateUsers())
  app.migrations.add(CreateTokens())
  app.migrations.add(CreateNotes())

  try app.autoMigrate().wait()

  try routes(app)
}
