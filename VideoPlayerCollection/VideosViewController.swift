//
//  ViewController.swift
//  VideoPlayerCollection
//
//  Created by Marco Alonso Rodriguez on 26/02/23.
// https://www.youtube.com/watch?v=81e9HElWaGM&ab_channel=SwiftCourse

import UIKit
import Kingfisher
import ProgressHUD

class VideosViewController: UIViewController {
    
    
    @IBOutlet weak var videosCollection: UICollectionView!
    @IBOutlet weak var categoryVideosSegmentedControl: UISegmentedControl!
    
    var videos: [Video] = []

    var manager = VideoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videosCollection.dataSource = self
        videosCollection.delegate = self
        
        manager.delegate = self
        
        videosCollection.collectionViewLayout = UICollectionViewFlowLayout()
        
        if let flowLayout = videosCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        
        print(categoryVideosSegmentedControl.titleForSegment(at: 0)!)

        getVideos(category: "\(categoryVideosSegmentedControl.titleForSegment(at: 0)!)")
    }
    
    func getVideos(category: String){
        Task {
            await manager.findVideos(topic: category)
        }
    }

    
    @IBAction func categorySelectedAction(_ sender: UISegmentedControl) {
        ProgressHUD.show("Buscando...", icon: .privacy)
        
        var category = "nature"
        
        switch sender.selectedSegmentIndex {
        case 0:
            category = "\(sender.titleForSegment(at: 0)!)"
        case 1:
            category = "\(sender.titleForSegment(at: 1)!)"
        case 2:
            category = "\(sender.titleForSegment(at: 2)!)"
        case 3:
            category = "\(sender.titleForSegment(at: 3)!)"
        case 4:
            category = "\(sender.titleForSegment(at: 4)!)"
        default:
            category = "nature"
        }
        
        Task {
            await manager.findVideos(topic: category)
        }
        
    }
    

}

extension VideosViewController: VideoManagerDelegate {
    func showVideos(listOfVideos: [Video]) {
        self.videos = listOfVideos
        
        DispatchQueue.main.async {
            self.videosCollection.reloadData()
            ProgressHUD.remove()
        }
    }
    
    
}

//UICollectionViewDelegateFlowLayout
extension VideosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 200)
    }
}

extension VideosViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        
        if let urlImage = URL(string: videos[indexPath.row].image) {
            celda.videoImage.kf.setImage(with: urlImage)
            celda.videoImage.layer.cornerRadius = 25
        }
        
        return celda
    }
    
    
}
