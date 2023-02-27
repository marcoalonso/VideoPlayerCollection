//
//  ViewController.swift
//  VideoPlayerCollection
//
//  Created by Marco Alonso Rodriguez on 26/02/23.
// https://www.youtube.com/watch?v=81e9HElWaGM&ab_channel=SwiftCourse

import UIKit
import Kingfisher
import ProgressHUD
import AVKit

class VideosViewController: UIViewController {
    
    
    @IBOutlet weak var nameVideosLabel: UILabel!
    @IBOutlet weak var videosCollection: UICollectionView!
    @IBOutlet weak var categoryVideosSegmentedControl: UISegmentedControl!
    
    var videos: [Video] = []

    var manager = VideoManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videosCollection.dataSource = self
        videosCollection.delegate = self
        
        manager.delegate = self
        
        setupCollection()
        
        getVideos(category: "\(categoryVideosSegmentedControl.titleForSegment(at: 0)!)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.videosCollection.reloadData()
    }
    
    private func setupCollection(){
        videosCollection.collectionViewLayout = UICollectionViewFlowLayout()
        
        if let flowLayout = videosCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    func getVideos(category: String){
        Task {
            await manager.findVideos(topic: category)
        }
    }

    //MARK: Actions
    @IBAction func searchVideos(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchVideosViewController") as! SearchVideosViewController
        if let sheet = vc.presentationController as? UISheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true ///Indicador horizontal de enmedio
        }
        present(vc, animated: true)
    }
    
    
    
    @IBAction func categorySelectedAction(_ sender: UISegmentedControl) {
        ProgressHUD.show("Buscando...", icon: .privacy)
        
        nameVideosLabel.text = "Categories"
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


//MARK: Protocol VideoManagerDelegate
extension VideosViewController: VideoManagerDelegate {
    func showError(error: String) {
        self.mostrarAlerta(titulo: "Error", mensaje: error)
    }
    
    
    
    func showVideos(listOfVideos: [Video]) {
        self.videos = listOfVideos
        
        DispatchQueue.main.async {
            self.videosCollection.reloadData()
            
            ProgressHUD.remove()
            
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let defaultVideo = "https://player.vimeo.com/external/342571552.hd.mp4?s=6aa6f164de3812abadff3dde86d19f7a074a8a66&profile_id=175&oauth2_token_id=57447761"
        guard let url = URL(string: "\(videos[indexPath.row].videoFiles.first?.link ?? defaultVideo)") else { return }
        
        let avPlayer = AVPlayer(url: url)
        let avController = AVPlayerViewController()
        avController.player = avPlayer
        present(avController, animated: true) {
            avPlayer.play()
        }
    }
    
}


