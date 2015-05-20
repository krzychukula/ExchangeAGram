//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Krzysztof Kula on 29/12/14.
//  Copyright (c) 2014 Krzysztof Kula. All rights reserved.
//

import UIKit


class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem: FeedItem!
    
    var collectionView:UICollectionView!
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    
    let kIntensity = 0.7
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        self.view.addSubview(collectionView)
        
        self.filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FilterCell
        

        cell.imageView.image = placeHolderImage

        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)

        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCachedImage(indexPath.row)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })

        
        return cell
    }
    
    //UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        createUIAlertController()
        
//        let filteredImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
//        
//        let imageData = UIImageJPEGRepresentation(filteredImage, 1.0)
//        self.thisFeedItem.image = imageData
//        
//        let thumbData = UIImageJPEGRepresentation(filteredImage, 0.1)
//        self.thisFeedItem.thumbNail = thumbData
//        
//        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
//        
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //UIAlertController helper functions
    
    func createUIAlertController(){
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an options", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false//for secure true
        }
        
        var text:String
        let textField = alert.textFields![0] as! UITextField
        
        if (textField.text != nil) {
            text = textField.text
        }
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive,
        handler: { (UIAlertAction) -> Void in
        
        })
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
        }
        alert.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select Another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            
        }
        alert.addAction(cancelAction)
        
        
        self.presentViewController(alert, animated: true, completion: nil)
    }


    //Helper
    
    
    func photoFilters() -> [CIFilter] {
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
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        
        return [blur, instant, noir, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImageFromImage(imageData:NSData, filter: CIFilter) -> UIImage {
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    //caching functions
    
    func cacheImage(imageNumber: Int) {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            let data = thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let filtered = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(filtered, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            cacheImage(imageNumber)
        }
        image = UIImage(contentsOfFile: uniquePath)!
        return image
    }
}
