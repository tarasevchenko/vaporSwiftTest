//
//  File.swift
//  
//
//  Created by Тарас Евченко on 03.09.2021.
//

import Fluent
import Vapor

struct NoteController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("content")
        
        let tokenProtected = usersRoute.grouped(Token.authenticator(), Token.guardMiddleware())
        
        tokenProtected.get("notes", use: index)
        tokenProtected.post("addNote", use: create)
        tokenProtected.on(.DELETE, "notes", use: deleteAll)
        tokenProtected.on(.DELETE, "notes", ":id", use: delete)
        tokenProtected.get("notes", ":id", use: getSingle)
        tokenProtected.on(.PATCH, "notes", ":id", use: update)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[NoteAPIModel]> {
        return Note.query(on: req.db)
            .all()
            .flatMapThrowing { notes in
                try notes.map { try NoteAPIModel($0) }
            }
    }
    
    struct CreateNoteRequestBody: Content {
        let text: String
        let title: String
        
        func makeNote(user: User) -> Note {
            return Note(title: title, text: text, hostId: user.id!)
        }
    }
    
    func create(req: Request) throws -> EventLoopFuture<NoteAPIModel> {
        let createNoteRequestBody = try req.content.decode(CreateNoteRequestBody.self)
        
        guard let user = req.auth.get(User.self) else {
            throw Abort(.badRequest, reason: "Invalid user")
        }
        
        let todo = createNoteRequestBody.makeNote(user: user)
        
        return todo.save(on: req.db)
            .flatMapThrowing { try NoteAPIModel(todo) }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Note.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
    
    func deleteAll(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Note.query(on: req.db)
            .delete()
            .transform(to: .ok)
    }
    
    func getSingle(req: Request) throws -> EventLoopFuture<NoteAPIModel> {
        guard let noteIDString = req.parameters.get("id"),
              let noteID = UUID(noteIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter id")
        }
        return Note.find(noteID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { try NoteAPIModel($0) }
    }
    
    struct PatchNoteRequestBody: Content {
        let text: String?
        let title: String?
    }
    
    func update(req: Request) throws -> EventLoopFuture<NoteAPIModel> {
        guard let noteIDString = req.parameters.get("id"),
              let noteID = UUID(noteIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `noteID`")
        }
        
        let patchTodoRequestBody = try req.content.decode(PatchNoteRequestBody.self)
        
        return Note.find(noteID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { note in
                if let text = patchTodoRequestBody.text {
                    note.text = text
                }
                if let title = patchTodoRequestBody.title {
                    note.title = title
                }
                
                return note.update(on: req.db)
                    .transform(to: note)
            }
            .flatMapThrowing { try NoteAPIModel($0) }
    }
}
