//
//  UploadManager.swift
//  PlayCam
//
//  Created by Shraddha on 28/01/26.
//

import Foundation

import UIKit


enum UploadError: Error {
    case invalidResponse
    case uploadFailed
}

struct FileUploader {
    
    static func upload(
        image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        let url = URL(string: "https://dev.www.trelleborg.com/apps/piancapi/poc/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        
        //        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
        //            completion(.failure(NSError(domain: "ImageError", code: 0)))
        //            return
        //        }
        
        //        guard let imageData = compressedImageData(
        //            from: image,
        //            maxWidth: 1024,
        //            quality: 0.4
        //        ) else {
        //            completion(.failure(NSError(domain: "ImageError", code: 0)))
        //            return
        //        }
        //
        
        guard let imageData = ultraCompress(image: image, maxKB: 150) else {
            completion(.failure(NSError(domain: "CompressionError", code: 0)))
            return
        }
        
        
        
        
        var body = Data()
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        // USE CUSTOM SESSION
        
        let session = URLSession(
            configuration: .default,
            delegate: UnsafeSSLDelegate(),
            delegateQueue: nil
        )
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let fileURL = json["fileUrl"] as? String {
                    
                    // Send only image URL back
                    completion(.success(fileURL))
                    
                } else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: 0)))
                }
                
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    //        let session = URLSession(
    //            configuration: .default,
    //            delegate: UnsafeSSLDelegate(),
    //            delegateQueue: nil
    //        )
    //
    //        session.dataTask(with: request) { data, response, error in
    //            if let error = error {
    //                print("❌ Upload failed:", error.localizedDescription)
    //                completion(.failure(error))
    //                return
    //            }
    //
    //            let responseString = String(data: data ?? Data(), encoding: .utf8) ?? ""
    //            print("✅ Response:", responseString)
    //
    //            completion(.success(responseString))
    //        }
    //        .resume()
    
    
    static func ultraCompress(image: UIImage, maxKB: Int = 600) -> Data? {
        
        var compression: CGFloat = 0.9
        var imageData = image.jpegData(compressionQuality: compression)
        
        guard imageData != nil else {
            print("❌ Failed to create JPEG")
            return nil
        }
        
        // Reduce quality gradually
        while let data = imageData, data.count > maxKB * 1024, compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
}



final class UnsafeSSLDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}


//struct ImgBBUploader {
//
//    static func upload(
//        image: UIImage,
//        apiKey: String,
//        completion: @escaping (Result<String, Error>) -> Void
//    ) {
//
//        let url = URL(string: "https://api.imgbb.com/1/upload")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let boundary = UUID().uuidString
//        request.setValue(
//            "multipart/form-data; boundary=\(boundary)",
//            forHTTPHeaderField: "Content-Type"
//        )
//
//        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
//            completion(.failure(NSError()))
//            return
//        }
//
//        var body = Data()
//
//        // API KEY
//        body.append("--\(boundary)\r\n")
//        body.append("Content-Disposition: form-data; name=\"key\"\r\n\r\n")
//        body.append("\(apiKey)\r\n")
//
//        // IMAGE
//        body.append("--\(boundary)\r\n")
//        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n")
//        body.append("Content-Type: image/jpeg\r\n\r\n")
//        body.append(imageData)
//        body.append("\r\n")
//
//        body.append("--\(boundary)--\r\n")
//
//        request.httpBody = body
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NSError()))
//                return
//            }
//
//            do {
//                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//                if let data = json?["data"] as? [String: Any],
//                   let url = data["url"] as? String {
//                    completion(.success(url))
//                } else {
//                    completion(.failure(NSError()))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//
//        }.resume()
//    }
//}


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
