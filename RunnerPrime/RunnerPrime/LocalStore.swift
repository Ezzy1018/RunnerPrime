//
//  LocalStore.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import Combine

/// LocalStore handles offline run persistence and local data management
/// Ensures runs are never lost even without internet connectivity
final class LocalStore: ObservableObject {
    static let shared = LocalStore()
    
    @Published private(set) var allRuns: [RunModel] = []
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        decoder.dateDecodingStrategy = .iso8601
        
        // Ensure runs directory exists
        try? fileManager.createDirectory(at: runsDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Directory Management
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var runsDirectory: URL {
        documentsDirectory.appendingPathComponent("runs", isDirectory: true)
    }
    
    private func runFileURL(for runId: String) -> URL {
        runsDirectory.appendingPathComponent("\(runId).json")
    }
    
    private var lastRunURL: URL {
        documentsDirectory.appendingPathComponent("last_run.json")
    }
    
    // MARK: - Run Persistence
    
    /// Save run locally and return file URL
    @discardableResult
    func saveRunLocally(_ run: RunModel) throws -> URL {
        let runFileURL = runFileURL(for: run.id)
        
        do {
            let data = try encoder.encode(run)
            try data.write(to: runFileURL)
            
            // Also save as "last run" for quick access
            try data.write(to: lastRunURL)
            
            print("✅ Run saved locally: \(runFileURL.lastPathComponent)")
            
            // Reload runs to update UI
            DispatchQueue.main.async { [weak self] in
                self?.loadRuns()
            }
            
            return runFileURL
        } catch {
            print("❌ Failed to save run locally: \(error)")
            throw LocalStoreError.saveFailed(error)
        }
    }
    
    /// Load the most recent run
    func loadLastRun() -> RunModel? {
        guard fileManager.fileExists(atPath: lastRunURL.path) else {
            print("📁 No last run found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: lastRunURL)
            let run = try decoder.decode(RunModel.self, from: data)
            print("✅ Loaded last run: \(run.id)")
            return run
        } catch {
            print("❌ Failed to load last run: \(error)")
            return nil
        }
    }
    
    /// Load specific run by ID
    func loadRun(id: String) -> RunModel? {
        let runFileURL = runFileURL(for: id)
        
        guard fileManager.fileExists(atPath: runFileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: runFileURL)
            let run = try decoder.decode(RunModel.self, from: data)
            return run
        } catch {
            print("❌ Failed to load run \(id): \(error)")
            return nil
        }
    }
    
    /// Load all runs from disk into memory
    func loadRuns() {
        allRuns = listSavedRuns()
    }
    
    /// List all saved runs (sorted by date, newest first)
    private func listSavedRuns() -> [RunModel] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: runsDirectory, 
                                                              includingPropertiesForKeys: [.creationDateKey])
            
            let runFiles = fileURLs.filter { $0.pathExtension == "json" }
            var runs: [RunModel] = []
            
            for fileURL in runFiles {
                if let data = try? Data(contentsOf: fileURL),
                   let run = try? decoder.decode(RunModel.self, from: data) {
                    runs.append(run)
                }
            }
            
            // Sort by start time, newest first
            runs.sort { $0.startTime > $1.startTime }
            
            print("📋 Found \(runs.count) saved runs")
            return runs
            
        } catch {
            print("❌ Failed to list saved runs: \(error)")
            return []
        }
    }
    
    /// Delete run file after successful upload
    func deleteRun(id: String) throws {
        let runFileURL = runFileURL(for: id)
        
        guard fileManager.fileExists(atPath: runFileURL.path) else {
            throw LocalStoreError.fileNotFound
        }
        
        do {
            try fileManager.removeItem(at: runFileURL)
            print("🗑️ Deleted run file: \(runFileURL.lastPathComponent)")
        } catch {
            print("❌ Failed to delete run \(id): \(error)")
            throw LocalStoreError.deleteFailed(error)
        }
    }
    
    /// Delete run by file URL
    func deleteRun(at url: URL) throws {
        do {
            try fileManager.removeItem(at: url)
            print("🗑️ Deleted run at: \(url.lastPathComponent)")
        } catch {
            print("❌ Failed to delete run at \(url): \(error)")
            throw LocalStoreError.deleteFailed(error)
        }
    }
    
    // MARK: - Upload Queue Management
    
    /// Get runs that need to be uploaded to Firebase
    func getPendingUploads() -> [RunModel] {
        return listSavedRuns() // For MVP, all local runs are pending uploads
    }
    
    /// Clear all local runs (use with caution)
    func clearAllRuns() throws {
        let runs = listSavedRuns()
        
        for run in runs {
            try deleteRun(id: run.id)
        }
        
        // Also clear last run
        if fileManager.fileExists(atPath: lastRunURL.path) {
            try fileManager.removeItem(at: lastRunURL)
        }
        
        print("🧹 Cleared all local runs")
    }
    
    // MARK: - Storage Stats
    
    /// Get storage usage information
    func getStorageInfo() -> StorageInfo {
        let runs = listSavedRuns()
        var totalSize: Int64 = 0
        
        for run in runs {
            let fileURL = runFileURL(for: run.id)
            if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let fileSize = attributes[.size] as? NSNumber {
                totalSize += fileSize.int64Value
            }
        }
        
        return StorageInfo(
            runCount: runs.count,
            totalSizeBytes: totalSize,
            oldestRun: runs.last?.startTime,
            newestRun: runs.first?.startTime
        )
    }
}

// MARK: - Error Types

enum LocalStoreError: Error, LocalizedError {
    case saveFailed(Error)
    case loadFailed(Error)
    case deleteFailed(Error)
    case fileNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save run: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load run: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete run: \(error.localizedDescription)"
        case .fileNotFound:
            return "Run file not found"
        case .invalidData:
            return "Invalid run data format"
        }
    }
}

// MARK: - Storage Information

struct StorageInfo {
    let runCount: Int
    let totalSizeBytes: Int64
    let oldestRun: Date?
    let newestRun: Date?
    
    var totalSizeMB: Double {
        return Double(totalSizeBytes) / (1024 * 1024)
    }
    
    var formattedSize: String {
        if totalSizeMB < 1.0 {
            return String(format: "%.1f KB", Double(totalSizeBytes) / 1024)
        } else {
            return String(format: "%.1f MB", totalSizeMB)
        }
    }
}