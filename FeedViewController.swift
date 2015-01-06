//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Gary Edgcombe on 10/12/2014.
//  Copyright (c) 2014 Gary Edgcombe Code. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData


class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Global Properties
    
    var feedArray: [AnyObject] = []
    
    
    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let fetchRequest = NSFetchRequest(entityName: "FeedItem")
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDelegate.managedObjectContext!
        
        feedArray = context.executeFetchRequest(fetchRequest, error: nil)!
        
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileBarButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("ProfileSegue", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // UICollectionView DataSource Methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
        
        let feed = feedArray[indexPath.item] as FeedItem
        
        let dataAsImage = UIImage(data: feed.image)
        
        cell.imageView.image = dataAsImage
        cell.caption.text = feed.caption
        
        return cell
    }
    
    @IBAction func snapbarButtonPressed(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
            
        }
        
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        }
        
        else {
            var alertController = UIAlertController(title: "Opps", message: "Your device does not support camera or library", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    // UIImagePickerController Delegate Method
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        // Convert UIImage to data
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbnailData = UIImageJPEGRepresentation(image, 0.1)
        
        // Save to CoreData
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext)
        
        let feed = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        feed.image = imageData
        feed.caption = "myImage"
        feed.thumbnail = thumbnailData
        
        appDelegate.saveContext()
        
        self.feedArray.append(feed)
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.collectionView.reloadData()
    }
    
    // UICollectionView Delegate Methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedFeedItem = feedArray[indexPath.row] as FeedItem
        
        var filterVC = FilterViewController()
        
        filterVC.thisFeedItem = selectedFeedItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
        
    }
    
    
    
    
    
    
    
}
