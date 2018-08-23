//
//  User.swift
//  JSONObjectMapper_Example
//
//  Created by Sergey on 21/08/2018.
//

import CoreData
import UIKit

@objc(User)
public class User: NSManagedObject, JSONMappingProtocol {

    @NSManaged var userID: NSNumber
    @NSManaged var username: String?
    @NSManaged var email: String?
    @NSManaged var posts: Set<Post>
    @NSManaged var comments: Set<Comment>
    
    public class func defaultMapping() -> JSONObjectMapping! {
        return JSONObjectMapping(dictionary: [
            "userID": "user_id",
            "username": "username",
            "email": "email"
        ])
    }
    
    public class func primaryKey() -> String! {
        return "userID"
    }
}
