//
//  DetailViewController.swift
//  Virtual_Tourist
//
//  Created by AF on 11/28/19.
//  Copyright © 2019 amaf. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController {
    
    var pinTapped: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reloadButton: UIButton!
    
    //Result controller
    var resultController:NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2DMake(pinTapped.latitude, pinTapped.longitude)
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.title = "Photo Album"
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultController()
        
        if (resultController.fetchedObjects?.count)! < 1  {
            reloadImageCollection(nil)
        }
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resultController = nil
    }
    
    fileprivate func setupFetchedResultController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin == %@", pinTapped)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = []
        
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        resultController.delegate = self
        
        do {
            try resultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //reload flickr API
    @IBAction func reloadImageCollection(_ sender: Any?) {
        
        deletePhotos()
        
        reloadButtonEnabled(isEnabled: false)
        
        let request = API.shared.createRequest(pin: pinTapped)
        
        API.shared.makeRequest(request: request) {
            (result, error) in
            
            guard error == nil else {
                self.showAlertMessage(message: error!)
                self.reloadButtonEnabled(isEnabled: true)
                return
            }
            
            guard result!.count > 0 else {
                self.reloadButtonEnabled(isEnabled: true)
                return
            }
            
            self.addPhotos(photos: result!)
            self.reloadButtonEnabled(isEnabled: true)
        }
    }
    
    fileprivate func addPhotos(photos: NSArray) {
        for _ in 1...20 {
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photos.count)))
            let photo = photos[randomPhotoIndex] as! [String:AnyObject]
            guard let imageURL = photo[Constants.FlickrResponseKeys.imageURL] as? String else {
                return
            }
            let photoToAdd = Photo(context: DataController.shared.viewContext)
            photoToAdd.pin = pinTapped
            photoToAdd.imageURL = imageURL
            saveViewContext()
        }
    }
    
    fileprivate func deletePhotos() {
        for photo in (resultController!.fetchedObjects)! {
            DataController.shared.viewContext.delete(photo)
            saveViewContext()
        }
    }
    
    func saveViewContext() {
        try? DataController.shared.viewContext.save()
    }
    
    fileprivate func reloadButtonEnabled(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.reloadButton.isEnabled = isEnabled
        }
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return resultController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = resultController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        cell.imageView.image = nil
        
        if photo.image == nil {
            API.shared.downloadImage(imageURL: photo.imageURL!) {
                (image, error) in
                guard error == nil else {
                    self.showAlertMessage(message: error!)
                    return
                }
                DispatchQueue.main.async {
                    photo.image = image
                    self.saveViewContext()
                }
            }
        } else {
            cell.imageView.image = UIImage(data: photo.image!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            let photo = resultController.object(at: indexPath)
            DataController.shared.viewContext.delete(photo)
            saveViewContext()
        }
    }
}

extension DetailViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        default:
            break
        }
    }
}
