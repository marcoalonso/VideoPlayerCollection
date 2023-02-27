//
//  VideoManager.swift
//  VideoPlayerCollection
//
//  Created by Marco Alonso Rodriguez on 26/02/23.
// Documentation: https://www.pexels.com/api/documentation/#videos-overview

import Foundation

protocol VideoManagerDelegate{
    func showVideos(listOfVideos: [Video])
    func showError(error: String)
}


struct VideoManager {
    
    var delegate: VideoManagerDelegate?
    
    func findVideos(topic: String) async {
        do {
            guard let url = URL(string: "https://api.pexels.com/videos/search?query=\(topic)&locale=es-ES&per_page=80&orientation=portrait") else {
                print("Error al buscar videos")
                delegate?.showError(error: "Error al buscar videos relacionados con tu búsqueda, favor de intentar con otra palabra o categoría.")
                return
            }
            
            print("Debug: url\(url)")
            
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("BPuUOkpCZlGHv4bo9kU1mepVkcFUFcnG4LxF1bI4dk6iTSkWbR6wcjzU", forHTTPHeaderField: "Authorization")
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("Error fetching data")
            }
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(ResponseBody.self, from: data)
            
            print(decodedData.videos)
            let listOfVideos = decodedData.videos
            delegate?.showVideos(listOfVideos: listOfVideos)
            
        } catch {
            print("Debug: error \(error.localizedDescription)")
        }
    }
}
