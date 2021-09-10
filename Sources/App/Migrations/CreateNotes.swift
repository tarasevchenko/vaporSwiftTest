//
//  File.swift
//  
//
//  Created by Тарас Евченко on 03.09.2021.
//

import Fluent
import FluentPostgresDriver

struct CreateNotes: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("notes")
            .id()
            .field("title", .string, .required)
            .field("text", .string, .required)
            .field("host_id", .uuid, .references("users", "id"), .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("notes").delete()
    }
}
