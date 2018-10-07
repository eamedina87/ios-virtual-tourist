//
//  ViewController.swift
//  virtualtourist
//
//  Created by Erick Medina on 12/9/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mMap: MKMapView!
    
    var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.title = ""
        setMap()
    }
    
    //MARK: MAP DELEGATE
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if (isFirstLoad){
            setRegion(mapView)
            isFirstLoad = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveRegion()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation as? MKPointAnnotation
        performSegue(withIdentifier: "showAlbum", sender: annotation?.coordinate)
    }
    
    
    //MAP: PRIVATE FUNCTIONS
    
    func setMap(){
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onMapTapped(gestureRecognizer:)))
        let holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onMapTapped(gestureRecognizer:)))
        mMap.delegate = self
        mMap.addGestureRecognizer(singleTapRecognizer)
        mMap.addGestureRecognizer(holdRecognizer)
        mMap.showsScale = true
        mMap.isZoomEnabled = true
    }
    
    @objc func onMapTapped(gestureRecognizer:UITapGestureRecognizer){
        guard gestureRecognizer.view != nil else { return }
        let tappedLocation = gestureRecognizer.location(in: mMap)
        let tappedCoordinate = mMap.convert(tappedLocation, toCoordinateFrom: mMap)
        addLocation(tappedCoordinate: tappedCoordinate)
    }
    
    func addLocation(tappedCoordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate
        mMap.addAnnotation(annotation)
    }
    
    func saveRegion(){
        UserDefaults.standard.set(mMap.region.center.latitude, forKey: Constants.DEFAULTS_KEY_LATITUDE)
        UserDefaults.standard.set(mMap.region.center.longitude, forKey: Constants.DEFAULTS_KEY_LONGITUDE)
        UserDefaults.standard.set(mMap.region.span.latitudeDelta, forKey: Constants.DEFAULTS_KEY_SPAN_LAT)
        UserDefaults.standard.set(mMap.region.span.longitudeDelta, forKey: Constants.DEFAULTS_KEY_SPAN_LON)
    }
    
    func setRegion(_ mapView: MKMapView) {
        if let centerLat = UserDefaults.standard.value(forKey: Constants.DEFAULTS_KEY_LATITUDE) as! Double?,
            let centerLon = UserDefaults.standard.value(forKey: Constants.DEFAULTS_KEY_LONGITUDE) as! Double?,
            let spanLat = UserDefaults.standard.value(forKey: Constants.DEFAULTS_KEY_SPAN_LAT) as! Double?,
            let spanLon = UserDefaults.standard.value(forKey: Constants.DEFAULTS_KEY_SPAN_LON) as! Double?
        {
            let center = CLLocationCoordinate2DMake(centerLat, centerLon)
            let region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(spanLat, spanLon))
            mapView.setRegion(region, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showAlbum"){
            let destinationVC = segue.destination as! AlbumViewController
            destinationVC.coordinate = sender as? CLLocationCoordinate2D
        }
    }
}

