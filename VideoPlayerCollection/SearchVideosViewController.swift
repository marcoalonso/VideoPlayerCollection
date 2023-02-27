//
//  SearchVideosViewController.swift
//  VideoPlayerCollection
//
//  Created by Marco Alonso Rodriguez on 26/02/23.
/// Documentation Guide: https://betterprogramming.pub/5-ways-to-pass-data-between-view-controllers-18acb467f5ec

import UIKit
import ProgressHUD

class SearchVideosViewController: UIViewController {
    
    
    var activityView: UIActivityIndicatorView?
    var categoryToSearch: String = ""
    
    @IBOutlet weak var categoryName: UITextField!
    
    var manager = VideoManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        categoryName.delegate = self
        
    }
    
    //MARK: Functions
    private func search(){
        ProgressHUD.show("Buscando...", icon: .privacy)
        guard let category = categoryName.text else { return }
        
        Task {
            await manager.findVideos(topic: category)
        }
    }
    
    
    
    @IBAction func searchButton(_ sender: UIButton) {
        search()
    }
    
    
    

}

extension SearchVideosViewController: VideoManagerDelegate {
    func showError(error: String) {
        DispatchQueue.main.async {
            self.mostrarAlerta(titulo: "Error", mensaje: error)
        }
    }
    
    func showVideos(listOfVideos: [Video]) {
        
        DispatchQueue.main.async {
            ProgressHUD.remove()
            
            if let vc = self.presentingViewController as? VideosViewController {
                self.dismiss(animated: true) {
                    vc.videos = listOfVideos
                    vc.nameVideosLabel.text = "Videos de \(self.categoryToSearch)"
                    DispatchQueue.main.async {
                        vc.videosCollection.reloadData()
                    }
                }
            }
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
            categoryToSearch = textField.text!
            return true
        } else {
            //el usuario no escribio nada
            textField.placeholder = "Escribe una categoria..."
            categoryToSearch = ""
            return false
        }
    }
}
