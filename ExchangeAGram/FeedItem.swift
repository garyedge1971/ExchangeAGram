//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Gary Edgcombe on 18/12/2014.
//  Copyright (c) 2014 Gary Edgcombe Code. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbnail: NSData

}
