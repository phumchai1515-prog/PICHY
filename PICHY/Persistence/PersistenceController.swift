//
//  PersistenceController.swift
//  PICHY
//
//  Owns the SwiftData stack and provides snapshot load / save.
//  Mutation of @Model entities is confined to this file so the rest of the
//  app keeps working with immutable domain structs.
//

import Foundation
import SwiftData

/// In-memory snapshot of everything the app persists.
struct DataSnapshot {
    var shifts: [Shift]
    var transactions: [Transaction]
    var activities: [Activity]
    var rates: PayRates
    var profile: UserProfile
    var settings: AppSettings
    var quota: LeaveQuota
    var hasOnboarded: Bool
}

@MainActor
final class PersistenceController {
    let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    // Last-persisted collections, so persist() only rewrites what actually
    // changed instead of deleting and re-inserting every row on every edit.
    private var lastShifts: [Shift] = []
    private var lastTransactions: [Transaction] = []
    private var lastActivities: [Activity] = []

    /// Shared production stack. Falls back to in-memory if the on-disk store
    /// can't be opened so the app still launches instead of crashing.
    static let shared = PersistenceController()

    init(inMemory: Bool = false) {
        let schema = Schema([
            ShiftEntity.self,
            TransactionEntity.self,
            ActivityEntity.self,
            AppStateEntity.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            // Last-resort fallback: an ephemeral store keeps the app usable.
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            // swiftlint:disable:next force_try
            container = try! ModelContainer(for: schema, configurations: fallback)
            assertionFailure("SwiftData store failed to open: \(error)")
        }
    }

    // MARK: - Load

    /// Loads the persisted snapshot, creating a default AppState row on first launch.
    func loadSnapshot() -> DataSnapshot {
        let state = fetchOrCreateState()
        let snapshot = DataSnapshot(
            shifts: fetchShiftEntities().map(\.asDomain).sorted { $0.date < $1.date },
            transactions: fetchTransactionEntities().map(\.asDomain).sorted { $0.date > $1.date },
            activities: fetchActivityEntities().map(\.asDomain).sorted { $0.time < $1.time },
            rates: state.rates,
            profile: state.profile,
            settings: state.settings,
            quota: state.quota,
            hasOnboarded: state.hasOnboarded
        )
        // Seed the change-tracking caches so the first persist after launch
        // doesn't needlessly rewrite collections that haven't changed.
        lastShifts = snapshot.shifts
        lastTransactions = snapshot.transactions
        lastActivities = snapshot.activities
        return snapshot
    }

    // MARK: - Save (mirror current arrays into the store)

    func persist(_ snapshot: DataSnapshot) {
        if snapshot.shifts != lastShifts {
            replaceShifts(snapshot.shifts)
            lastShifts = snapshot.shifts
        }
        if snapshot.transactions != lastTransactions {
            replaceTransactions(snapshot.transactions)
            lastTransactions = snapshot.transactions
        }
        if snapshot.activities != lastActivities {
            replaceActivities(snapshot.activities)
            lastActivities = snapshot.activities
        }

        let state = fetchOrCreateState()
        state.apply(rates: snapshot.rates)
        state.apply(profile: snapshot.profile)
        state.apply(settings: snapshot.settings)
        state.apply(quota: snapshot.quota)
        state.hasOnboarded = snapshot.hasOnboarded

        save()
    }

    // MARK: - Fetch helpers

    private func fetchShiftEntities() -> [ShiftEntity] {
        (try? context.fetch(FetchDescriptor<ShiftEntity>())) ?? []
    }

    private func fetchTransactionEntities() -> [TransactionEntity] {
        (try? context.fetch(FetchDescriptor<TransactionEntity>())) ?? []
    }

    private func fetchActivityEntities() -> [ActivityEntity] {
        (try? context.fetch(FetchDescriptor<ActivityEntity>())) ?? []
    }

    private func fetchOrCreateState() -> AppStateEntity {
        if let existing = try? context.fetch(FetchDescriptor<AppStateEntity>()).first {
            return existing
        }
        let fresh = AppStateEntity.makeDefault()
        context.insert(fresh)
        save()
        return fresh
    }

    // MARK: - Replace collections

    private func replaceShifts(_ shifts: [Shift]) {
        for e in fetchShiftEntities() { context.delete(e) }
        for s in shifts { context.insert(ShiftEntity.make(from: s)) }
    }

    private func replaceTransactions(_ transactions: [Transaction]) {
        for e in fetchTransactionEntities() { context.delete(e) }
        for t in transactions { context.insert(TransactionEntity.make(from: t)) }
    }

    private func replaceActivities(_ activities: [Activity]) {
        for e in fetchActivityEntities() { context.delete(e) }
        for a in activities { context.insert(ActivityEntity.make(from: a)) }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            assertionFailure("SwiftData save failed: \(error)")
        }
    }
}
