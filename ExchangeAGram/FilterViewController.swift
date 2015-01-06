//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Gary Edgcombe on 12/12/2014.
//  Copyright (c) 2014 Gary Edgcombe Code. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // Properties
    
    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    var context:CIContext = CIContext(options: nil)
    
    var filters: [CIFilter] = []
    
    // Constants
    
    let tmp = NSTemporaryDirectory()
    let placeHolderImage = UIImage(named: "Placeholder")
    let kIntensity = 0.7
    
    
    // Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        filters = photoFilters()
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 19, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        self.view.addSubview(collectionView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // UICollectionView DataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let filterCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        filterCell.imageView.image = self.placeHolderImage
        
        let filterQueue: dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        dispatch_async(filterQueue, { () -> Void in
//            let filterImage = self.getCachedImage(indexPath.row)
            let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbnail, filter: self.filters[indexPath.row])
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                filterCell.imageView.image = filterImage
            })
        })
        
        return filterCell
    }
    
    
    
    // UICollectionView Delegate Methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        println("Filtered Image Tapped!")
        
        let filteredImage = self.filteredImageFromImage(thisFeedItem.image, filter: self.filters[indexPath.row])
        self.thisFeedItem.image = UIImageJPEGRepresentation(filteredImage, 1.0)
        self.thisFeedItem.thumbnail = UIImageJPEGRepresentation(filteredImage, 0.1)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    
    // Helper
    
    func photoFilters() ->[CIFilter] {
        
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        // Composite Filter
       
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)

        
        
        //let photoFilters: [CIFilter] = [blur, instant, noir, transfer, unsharpen, monochrome]
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
        
        
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        
        let finalImage = UIImage(CGImage: cgImage)
        
        
        return finalImage!
    }
    
    // Caching Functions
    
    func cacheImage(imageNumber: Int) {
        
        let fileName = "\(imageNumber)"
        
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            let data = self.thisFeedItem.thumbnail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)"
        
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
            
        }
        else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
    }
    
    
}




















