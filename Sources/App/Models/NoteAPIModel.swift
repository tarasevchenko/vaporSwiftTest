//
//  File.swift
//  
//
//  Created by Тарас Евченко on 03.09.2021.
//

import Vapor

struct NoteAPIModel: Content {
    let id: Note.IDValue
    let title: String
    let text: String
    let createdAt: Date?
    let updatedAt: Date?
}

extension NoteAPIModel {
    init(_ note: Note) throws {
        self.id = try note.requireID()
        self.title = note.title
        self.text = note.text
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }
}
