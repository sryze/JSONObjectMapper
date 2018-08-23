//
//  Post.swift
//  JSONObjectMapper_Example
//
//  Created by Sergey on 21/08/2018.
//

import CoreData
import UIKit

@objc(Post)
public class Post: NSManagedObject, JSONMappingProtocol {

    @NSManaged var postID: NSNumber
    @NSManaged var content: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var viewCount: NSNumber?
    @NSManaged var author: User?
    @NSManaged var comments: Set<Comment>
    
    public class func defaultMapping() -> JSONObjectMapping! {
        return JSONObjectMapping(dictionary: [
            "postID": "post_id",
            "content": "content",
            "rating": "rating",
            "viewCount": "view_count",
            "author": JSONRelationshipMapping(jsonKey: "author_id"),
            "comments": JSONRelationshipMapping(jsonKey: "comments"),
        ])
    }
    
    public class func primaryKey() -> String! {
        return "postID"
    }
}
