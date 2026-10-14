//
//  PhotoLibrary.swift
//  Guitars
//
//  The app never stores image bytes. Guitars keep Photos-library identifiers
//  and everything here turns those identifiers back into images.
//

import Foundation
import Photos

nonisolated enum PhotoLibrary {
    /// How much of the library the app can read. With limited access, photos
    /// chosen in the picker are NOT added to the allowed set, so their
    /// identifiers can't be loaded. The app needs full access to show them.
    enum Access {
        case full, limited, denied, notDetermined
    }

    static var access: Access {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized: .full
        case .limited: .limited
        case .notDetermined: .notDetermined
        default: .denied
        }
    }

    /// Asks for read/write access the first time; later calls just return the status.
    @discardableResult
    static func requestAccess() async -> PHAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .notDetermined else { return status }
        return await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }

    /// Maps device-specific local identifiers to cross-device cloud identifiers.
    /// Identifiers that can't be mapped (iCloud Photos off, asset gone) are left out.
    static func cloudIdentifiers(for localIdentifiers: [String]) -> [String: String] {
        guard !localIdentifiers.isEmpty else { return [:] }
        let mappings = PHPhotoLibrary.shared().cloudIdentifierMappings(forLocalIdentifiers: localIdentifiers)
        var result: [String: String] = [:]
        for (localID, mapping) in mappings {
            if case .success(let cloudID) = mapping {
                result[localID] = cloudID.stringValue
            }
        }
        return result
    }

    /// Maps cloud identifiers from another device to this device's local identifiers.
    static func localIdentifiers(forCloudIdentifiers cloudIdentifiers: [String]) -> [String: String] {
        guard !cloudIdentifiers.isEmpty else { return [:] }
        let ids = cloudIdentifiers.map { PHCloudIdentifier(stringValue: $0) }
        let mappings = PHPhotoLibrary.shared().localIdentifierMappings(for: ids)
        var result: [String: String] = [:]
        for (cloudID, mapping) in mappings {
            if case .success(let localID) = mapping {
                result[cloudID.stringValue] = localID
            }
        }
        return result
    }

    /// Finds the asset by local identifier, falling back to the cloud identifier
    /// when the reference came from another device.
    static func asset(for image: GuitarImage) -> PHAsset? {
        if let asset = fetchAsset(localIdentifier: image.localIdentifier) {
            return asset
        }
        guard let cloudID = image.cloudIdentifier,
              let localID = localIdentifiers(forCloudIdentifiers: [cloudID])[cloudID] else {
            return nil
        }
        return fetchAsset(localIdentifier: localID)
    }

    /// Loads the image for a reference, or nil when it isn't in this device's library.
    static func image(for image: GuitarImage, targetSize: CGSize) async -> PlatformImage? {
        guard let asset = asset(for: image) else { return nil }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat   // one callback, not a degraded one first
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true       // pull originals down from iCloud Photos
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { result, _ in
                continuation.resume(returning: result)
            }
        }
    }

    /// Saves a photo from the camera into the user's library and returns its local identifier.
    static func saveImage(data: Data) async throws -> String {
        let created = IdentifierBox()
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
            created.value = request.placeholderForCreatedAsset?.localIdentifier
        }
        guard let localID = created.value else {
            throw CocoaError(.fileWriteUnknown)
        }
        return localID
    }

    private static func fetchAsset(localIdentifier: String) -> PHAsset? {
        PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
    }
}

/// Carries the new asset's identifier out of the `performChanges` block.
private nonisolated final class IdentifierBox: @unchecked Sendable {
    var value: String?
}
