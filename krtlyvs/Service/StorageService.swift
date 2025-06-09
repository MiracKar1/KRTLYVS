//
//  StorageService.swift
//  krtlyvs
//
//  Created by Mirac Kar on 22.05.2025.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()
    
    private init() {}
    
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel dönüştürülemedi"])
        }
        
        let imageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await imageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    func deleteImage(at path: String) async throws {
        let imageRef = storage.reference().child(path)
        try await imageRef.delete()
    }
    
    func uploadProfileImage(_ image: UIImage, userUid: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resim dönüştürülemedi"])
        }
        
        let storageRef = storage.reference().child("profile_images/\(userUid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    func uploadPostImage(_ image: UIImage, postId: String) async throws -> String {
        let path = "post_images/\(postId).jpg"
        return try await uploadImage(image, path: path)
    }
    
    func deleteProfileImage(userUid: String) async throws {
        let path = "profile_images/\(userUid).jpg"
        try await deleteImage(at: path)
    }
    
    func deletePostImage(postId: String) async throws {
        let path = "post_images/\(postId).jpg"
        try await deleteImage(at: path)
    }
}
