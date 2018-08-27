//
//  ViewController.swift
//  JSONObjectMapper_Example
//
//  Created by Sergey on 21/08/2018.
//

import CoreData
import UIKit

let SomeAPIURL = "https://gist.githubusercontent.com/sryze/fd6ce4e472e261e3ad56f5b8bcf8d091/raw/9c0a1ba1c02f38ec7831ede4ea60537943838ae5/api.json"

class ViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let objectMapper = JSONObjectMapper(managedObjectContext: managedObjectContext) else {
            return
        }
        
        // Register a date transformer. You have to define a DateTransformer if you're mapping NSDate properties
        // from JSON.
        //
        // Other types of transformers (custom transformers) are supported as well - use the Core Data model editor
        // to set them via user-defined attributes on those entity attributes that you want to transform.
        //
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateTransformer = DateTransformer(dateFormatter: dateFormatter)
        objectMapper.setValueTransformer(dateTransformer, forName: JSONDateTransformerName)
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.urlCache = nil
        
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: URL(string: SomeAPIURL)!) { (data, response, error) in
            guard error == nil else {
                print("Error fetching data from API: \(error!)")
                return
            }
            
            var responseDictionary: Dictionary<String, Any?>? = nil
            do {
                responseDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any?>
                print("API response: \(responseDictionary!)")
            } catch {
                print("Could not parse JSON data: \(error)")
                return
            }
            guard responseDictionary != nil else {
                return
            }
            guard let responseData = responseDictionary else {
                return
            }
            
            let posts = objectMapper.mapArray(responseData["posts"] ?? nil, toEntityClass: Post.self) as? [Post]
            let _ = objectMapper.mapArray(responseData["users"] ?? nil, toEntityClass: User.self) as? [User]
            
            // After mapping both posts and users, post and comment objects are actually connected to user objects
            // (through the author_id and user_id relationship in JSON, or author and user in the Core Data model).
            //
            if let posts = posts {
                for post in posts {
                    print("Post: postID=\(post.postID), content=\(post.content ?? "-"), rating=\(post.rating ?? 0), viewCount=\(post.viewCount ?? 0), author=\(post.author?.username ?? "-")")
                    for comment in post.comments {
                        print("- Comment: commentID=\(comment.commentID), message=\(comment.message ?? "-"), date=\(String(describing: comment.date)), user=\(comment.user?.username ?? "-")")
                    }
                }
            }
        }
        task.resume()
    }
}
