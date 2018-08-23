//
//  Comment.swift
//  JSONObjectMapper_Example
//
//  Created by Sergey on 21/08/2018.
//

import CoreData
import UIKit

@objc(Comment)
public class Comment: NSManagedObject, JSONMappingProtocol {

    @NSManaged var commentID: NSNumber
    @NSManaged var message: String?
    @NSManaged var date: Date?
    @NSManaged var user: User?
    @NSManaged var post: Post?
    
    public class func defaultMapping() -> JSONObjectMapping! {
        return JSONObjectMapping(dictionary: [
            "commentID": "comment_id",
            "message": "message",
            "date": "date",
            "user": JSONRelationshipMapping(jsonKey: "user_id")
        ])
    }
    
    public class func primaryKey() -> String! {
        return "commentID"
    }
}
