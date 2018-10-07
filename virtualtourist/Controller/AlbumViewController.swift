//
//  AlbumViewController.swift
//  virtualtourist
//
//  Created by Erick Medina on 12/9/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import UIKit
import MapKit

class AlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 3
    var region : MKCoordinateRegion? = nil
    var coordinate : CLLocationCoordinate2D? = nil
    var isCollectionSet = false
    var images = [Data]()
    @IBOutlet weak var mMap: MKMapView!
    @IBOutlet weak var mImageCollection: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backItem?.title = "OK"
        mMap.delegate = self
        if (!self.isCollectionSet){
            self.setCollection()
        }
    }
    
    //MARK: MapView Delegate
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        setMap()
        getAlbumForLocation()
    }
    
    //MARK: API Methods
    
    func getAlbumForLocation(){
        if let coordinate = coordinate {
            FlickrClient.sharedInstance().getImagesForLocation(latitude: coordinate.latitude, longitude: coordinate.longitude){
                result,error in
                //Incoming result is in form of Data
                
                
                guard (error==nil) else{
                    if (error?.userInfo[NSLocalizedDescriptionKey] as? String == "No Images Found"){
                        self.showAlert(nil, message: "No Images found for this location. Please select another one"){
                            self.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    print(error)
                    return
                }
                
                guard let data=result else {
                    print("Data obtained is null")
                    return
                }
                
                self.images.append(data)
                performUIUpdatesOnMain {
                    self.mImageCollection.reloadData()
                 }
            }
        }
    }
    
    //MARK: Map Methods
    
    func setMap(){
        if let coordinate = coordinate {
            addLocation(coordinate: coordinate)
            setRegion(coordinate: coordinate)
        }
    }
    
    func addLocation(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mMap.addAnnotation(annotation)
    }
    
    func setRegion(coordinate: CLLocationCoordinate2D){
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mMap.setRegion(region, animated: true)
    }
    
    //MARK: Collection View
    
    func setCollection() {
        mImageCollection.dataSource = self
        mImageCollection.delegate = self
        isCollectionSet = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mImageCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionCell
        if indexPath.row < images.count  {
            let imageData = images[indexPath.row]
            cell.mImage.image = UIImage(data: imageData)
            cell.mLoadingIndicator.stopAnimating()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    //MARK: ALert
    func showAlert(_ title:String?, message:String, completionHandler: @escaping (()->Void)){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel){ action in
            alertController.dismiss(animated: true, completion: completionHandler)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}


