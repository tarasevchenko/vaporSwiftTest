//
//  File.swift
//  
//
//  Created by Тарас Евченко on 03.09.2021.
//

import Fluent
import Vapor

final class Note: Model, Content {
    
    struct Public: Content {
        let id: UUID
        let title: String
        let text: String
        let host: User.Public
        let createdAt: Date?
        let updatedAt: Date?
    }
    
    static let schema = "notes"
    
    @ID(key: "id")
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "text")
    var text: String
    
    @Parent(key: "host_id")
    var host: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, title: String, text: String, hostId: User.IDValue) {
        self.id = id
        self.title = title
        self.text = text
        self.$host.id = hostId
    }
}

extension Note {
    func asPublic() throws -> Public {
        Public(id: try requireID(),
               title: title,
               text: text,
               host: try host.asPublic(),
               createdAt: createdAt,
               updatedAt: updatedAt)
    }
}
