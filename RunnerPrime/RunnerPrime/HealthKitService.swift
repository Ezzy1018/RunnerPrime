//
//  HealthKitService.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import HealthKit
import Combine

/// HealthKitService handles Apple Health integration for RunnerPrime
/// Allows users to import workout history and save runs to Health app
final class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var isAvailable: Bool
    
    private init() {
        // Check if HealthKit is available on this device
        isAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Authorization
    
    /// Request HealthKit authorization for reading and writing workout data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isAvailable else {
            completion(false, HealthKitError.notAvailable)
            return
        }
        
        // Define the data types we want to read and write
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                completion(success, error)
                
                if success {
                    print("✅ HealthKit authorization granted")
                } else {
                    print("❌ HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown")")
                }
            }
        }
    }
    
    // MARK: - Save Workout
    
    /// Save a run to HealthKit as a workout
    func saveRunToHealthKit(
        _ run: RunModel,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard isAuthorized else {
            completion(false, HealthKitError.notAuthorized)
            return
        }
        
        guard let endTime = run.endTime else {
            completion(false, HealthKitError.invalidRunData)
            return
        }
        
        // Create workout
        let workout = HKWorkout(
            activityType: .running,
            start: run.startTime,
            end: endTime,
            duration: run.duration,
            totalEnergyBurned: nil,
            totalDistance: HKQuantity(unit: .meter(), doubleValue: run.distance),
            metadata: [
                "app_name": "RunnerPrime",
                "run_id": run.id
            ]
        )
        
        // Save to HealthKit
        healthStore.save(workout) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Run saved to HealthKit: \(run.id)")
                } else {
                    print("❌ Failed to save run to HealthKit: \(error?.localizedDescription ?? "Unknown")")
                }
                completion(success, error)
            }
        }
    }
    
    // MARK: - Import Workouts
    
    /// Import recent running workouts from HealthKit
    func importRecentWorkouts(
        limit: Int = 10,
        completion: @escaping (Result<[HKWorkout], Error>) -> Void
    ) {
        guard isAuthorized else {
            completion(.failure(HealthKitError.notAuthorized))
            return
        }
        
        // Query for running workouts
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to import workouts: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let workouts = samples as? [HKWorkout] ?? []
                print("✅ Imported \(workouts.count) workouts from HealthKit")
                completion(.success(workouts))
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Convert HealthKit Workout to RunModel
    
    /// Convert HealthKit workout to RunModel for import
    func convertWorkoutToRun(_ workout: HKWorkout) -> RunModel? {
        guard workout.workoutActivityType == .running else {
            return nil
        }
        
        var run = RunModel(startTime: workout.startDate)
        run.endTime = workout.endDate
        run.duration = workout.duration
        
        // Get distance if available
        if let distance = workout.totalDistance?.doubleValue(for: .meter()) {
            run.distance = distance
        }
        
        // Note: We don't have GPS points from HealthKit, so territory won't be calculated
        // This is expected for imported workouts
        
        return run
    }
    
    // MARK: - Query Stats
    
    /// Get total running distance from HealthKit
    func getTotalRunningDistance(
        completion: @escaping (Result<Double, Error>) -> Void
    ) {
        guard isAuthorized else {
            completion(.failure(HealthKitError.notAuthorized))
            return
        }
        
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let totalDistance = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
                completion(.success(totalDistance))
            }
        }
        
        healthStore.execute(query)
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case invalidRunData
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit authorization is required"
        case .invalidRunData:
            return "Run data is invalid or incomplete"
        }
    }
}
