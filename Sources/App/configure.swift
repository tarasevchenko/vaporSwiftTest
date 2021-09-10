import Fluent
import FluentPostgresDriver
import Vapor



public func configure(_ app: Application) throws {
  let encoder = JSONEncoder()
  encoder.keyEncodingStrategy = .convertToSnakeCase
  encoder.dateEncodingStrategy = .iso8601
  
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  decoder.dateDecodingStrategy = .iso8601
  
  ContentConfiguration.global.use(encoder: encoder, for: .json)
  ContentConfiguration.global.use(decoder: decoder, for: .json)
  
    try app.databases.use(.postgres(hostname: "localhost", username: "postgres", password: "", database: "notesdb"), as: .psql)
  
  app.middleware.use(ErrorMiddleware.default(environment: app.environment))
  
  app.migrations.add(CreateUsers())
  app.migrations.add(CreateTokens())
  app.migrations.add(CreateNotes())

  try app.autoMigrate().wait()

  try routes(app)
}
