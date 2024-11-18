//
//  CloudKitGenericDataManager.swift
//  ZeroBeta4
//
//

import Foundation
import CloudKit

class CloudKitGenericDataManager<T: CloudKitableProtocol>: ObservableObject {
    @Published var items: [T] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Fetch
    @MainActor
    func fetchAll(predicate: NSPredicate = NSPredicate(value: true)) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Perform fetch operation outside the actor context
            let fetchedItems = try await performFetch(predicate: predicate)
            
            // Update the state on the MainActor
            self.items = fetchedItems
        } catch {
            // Handle errors and update the error message
            self.errorMessage = "Error fetching items: \(error.localizedDescription)"
        }
    }

    private func performFetch(predicate: NSPredicate) async throws -> [T] {
        // This function operates outside MainActor
        try await CloudKitCrudUtility.fetch(predicate: predicate, recordType: T.recordType)
    }

    // MARK: - Add
    func add(item: T) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await CloudKitCrudUtility.saveOrUpdate(item: item)
            await fetchAll() // Reload after adding
        } catch {
            self.errorMessage = "Error adding item: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete
    func delete(item: T) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await CloudKitCrudUtility.delete(item: item)
            await fetchAll() // Reload after deleting
        } catch {
            self.errorMessage = "Error deleting item: \(error.localizedDescription)"
        }
    }

    // MARK: - Update
    func update(item: T) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await CloudKitCrudUtility.saveOrUpdate(item: item)
            await fetchAll() // Reload after updating
        } catch {
            self.errorMessage = "Error updating item: \(error.localizedDescription)"
        }
    }
}
