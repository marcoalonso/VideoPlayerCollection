//
//  SearchVideosViewController.swift
//  VideoPlayerCollection
//
//  Created by Marco Alonso Rodriguez on 26/02/23.
//

import UIKit



class SearchVideosViewController: UIViewController {
    
    
    
    
    
    var activityView: UIActivityIndicatorView?
    
    @IBOutlet weak var categoryName: UITextField!
    
    var manager = VideoManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        categoryName.delegate = self
        
    }
    
    //MARK: Functions
    private func search(){
        showActivityIndicator()
        guard let category = categoryName.text else { return }
        
        Task {
            await manager.findVideos(topic: category)
        }
    }
    
    
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        search()
    }
    
    
    

}

extension SearchVideosViewController: VideoManagerDelegate {
    func showVideos(listOfVideos: [Video]) {
        let listOfVideos = listOfVideos
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                print(listOfVideos)
                ///Enviar la lista de videos al VideosViewController
                NotificationCenter.default.post(name: VideosViewController.myNotification, object: listOfVideos)
                print("Send listOfVideos")
                self.hideActivityIndicator()
            }
        }
    }
    
    
}

//MARK: UITextFieldDelegate
extension SearchVideosViewController: UITextFieldDelegate {
    //1.- Habilitar el boton del teclado virtual
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Hacer algo ")
        //ocultar teclado
        textField.endEditing(true)
        return true
    }
    
    //2.- Identificar cuando el usuario termina de editar y que pueda borrar el contenido del textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Hacer algo
        search()
        textField.text = ""
        //ocultar teclado
        textField.endEditing(true)
    }
    
    //3.- Evitar que el usuario no escriba nada
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            //el usuario no escribio nada
            textField.placeholder = "Escribe una categoria..."
            return false
        }
    }
}
