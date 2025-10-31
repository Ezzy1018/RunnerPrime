//
//  CalendarView.swift
//  RunnerPrime
//
//  Streak calendar with day drill-down to runs.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject private var localStore = LocalStore.shared
    @State private var selectedDate: Date? = nil
    @State private var showDaySheet = false
    @State private var monthOffset: Int = 0
    @State private var showMonthPicker: Bool = false

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 16) {
            // Header with month navigation
            HStack {
                Button(action: { monthOffset -= 1 }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.rpWhiteLiteral)
                        .padding(8)
                }

                Spacer()
                Button(action: { showMonthPicker = true }) {
                    HStack(spacing: 6) {
                        Text(monthTitle)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.rpWhiteLiteral)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                    }
                }
                Spacer()

                Button(action: { monthOffset += 1 }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.rpWhiteLiteral)
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, -40)

            // Streak summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.subheadline)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                    Text("\(currentStreak) days")
                        .font(.title2).bold()
                        .foregroundColor(.rpLimeLiteral)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Longest Streak")
                        .font(.subheadline)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                    Text("\(longestStreak) days")
                        .font(.title3).bold()
                        .foregroundColor(.rpWhiteLiteral)
                }
            }
            .padding(.horizontal, 20)

            // Month grid
            MonthGridView(dates: monthDates, runDates: runDates) { date in
                selectedDate = date
                showDaySheet = true
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.rpWhiteLiteral.opacity(0.06))
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                            .opacity(0.6)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.rpWhiteLiteral.opacity(0.12), lineWidth: 1)
            )
            .padding(.horizontal, 12)

            Spacer()
        }
        .background(Color.rpEerieBlackLiteral.ignoresSafeArea())
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width < -40 { monthOffset += 1 }
                if value.translation.width > 40 { monthOffset -= 1 }
            }
        )
        .sheet(isPresented: $showDaySheet) {
            if let date = selectedDate {
                DayRunsSheetView(date: date, runs: runs(on: date))
            }
        }
        // Custom bottom sheet (supports iOS 15+)
        .overlay(alignment: .bottom) {
            if showMonthPicker {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeInOut) { showMonthPicker = false } }
                VStack(spacing: 12) {
                    Capsule()
                        .fill(Color.rpWhiteLiteral.opacity(0.3))
                        .frame(width: 44, height: 5)
                        .padding(.top, 8)
                    Text("Select Month")
                        .font(.headline)
                        .foregroundColor(.rpWhiteLiteral)
                    MonthYearInlinePicker(
                        calendar: calendar,
                        initial: displayedMonthStart,
                        onCancel: { withAnimation { showMonthPicker = false } },
                        onDone: { selected in
                            let y1 = calendar.component(.year, from: currentMonthStart)
                            let m1 = calendar.component(.month, from: currentMonthStart)
                            let y2 = calendar.component(.year, from: selected)
                            let m2 = calendar.component(.month, from: selected)
                            monthOffset = (y2 - y1) * 12 + (m2 - m1)
                            withAnimation { showMonthPicker = false }
                        }
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.rpWhiteLiteral.opacity(0.12), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 12)
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            localStore.loadRuns()
        }
    }

    // MARK: - Data helpers

    private var monthDates: [Date] {
        let start = displayedMonthStart
        let range = calendar.range(of: .day, in: .month, for: start) ?? 1..<2
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) }
    }

    private var displayedMonthStart: Date {
        let now = Date()
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        return calendar.date(byAdding: .month, value: monthOffset, to: currentMonthStart) ?? currentMonthStart
    }

    private var currentMonthStart: Date {
        let now = Date()
        return calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
    }

    private var monthTitle: String {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        return df.string(from: displayedMonthStart)
    }

    private var runDates: Set<String> {
        Set(localStore.allRuns.map { dayKey($0.startTime) })
    }

    private func runs(on date: Date) -> [RunModel] {
        let key = dayKey(date)
        return localStore.allRuns.filter { dayKey($0.startTime) == key }
    }

    private func dayKey(_ date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }

    private var currentStreak: Int {
        // Count consecutive days ending today with at least one run
        var count = 0
        var date = Date()
        let runDays = runDates
        while runDays.contains(dayKey(date)) {
            count += 1
            if let prev = calendar.date(byAdding: .day, value: -1, to: date) { date = prev } else { break }
        }
        return count
    }

    private var longestStreak: Int {
        // Sliding window over sorted unique run days
        let sorted = localStore.allRuns.map { calendar.startOfDay(for: $0.startTime) }.removingDuplicates().sorted()
        guard !sorted.isEmpty else { return 0 }
        var longest = 1
        var current = 1
        for i in 1..<sorted.count {
            if let prev = calendar.date(byAdding: .day, value: -1, to: sorted[i]) , prev == sorted[i - 1] {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }
}

// MARK: - Month Grid

private struct MonthGridView: View {
    let dates: [Date]
    let runDates: Set<String>
    let onSelect: (Date) -> Void
    private let calendar = Calendar.current

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(weekdayHeaders(), id: \.self) { label in
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
            ForEach(paddedMonth(), id: \.self) { cell in
                if let date = cell {
                    let key = dayKey(date)
                    Button(action: { onSelect(date) }) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundColor(.rpWhiteLiteral)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill((runDates.contains(key) ? Color.rpLimeLiteral.opacity(0.35) : Color.rpWhiteLiteral.opacity(0.06)))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    private func weekdayHeaders() -> [String] {
        let symbols = calendar.shortWeekdaySymbols
        // Ensure starts on Sunday like iOS calendar
        return symbols
    }

    private func paddedMonth() -> [Date?] {
        guard let first = dates.first else { return [] }
        let weekday = calendar.component(.weekday, from: first) // 1..7
        let padding = (weekday - 1) // number of leading blanks
        let blanks = Array(repeating: Optional<Date>.none, count: padding)
        return blanks + dates.map { Optional($0) }
    }

    private func dayKey(_ date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }
}

// MARK: - Day Sheet

private struct DayRunsSheetView: View {
    let date: Date
    let runs: [RunModel]
    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if runs.isEmpty {
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 48))
                        .foregroundColor(.rpWhiteLiteral.opacity(0.5))
                    Text("No runs this day")
                        .foregroundColor(.rpWhiteLiteral)
                    Spacer()
                } else {
                    List(runs, id: \.id) { run in
                        NavigationLink(destination: RunDetailView(run: run)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: "%.2f km", run.distance / 1000))
                                    .font(.headline)
                                Text(TimeInterval(run.duration).formattedDuration)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color.rpEerieBlackLiteral.ignoresSafeArea())
            .navigationTitle(titleString)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var titleString: String {
        let df = DateFormatter()
        df.dateStyle = .full
        return df.string(from: date)
    }
}

// MARK: - Helpers

private extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

#Preview {
    CalendarView()
        .preferredColorScheme(.dark)
}
// MARK: - Inline Month/Year Picker (bottom sheet content)

private struct MonthYearInlinePicker: View {
    let calendar: Calendar
    let initial: Date
    var onCancel: () -> Void
    var onDone: (Date) -> Void
    @State private var tempDate: Date

    init(calendar: Calendar, initial: Date, onCancel: @escaping () -> Void, onDone: @escaping (Date) -> Void) {
        self.calendar = calendar
        self.initial = initial
        self.onCancel = onCancel
        self.onDone = onDone
        _tempDate = State(initialValue: initial)
    }

    var body: some View {
        VStack(spacing: 12) {
            DatePicker("Select Month", selection: $tempDate, displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .padding(.horizontal)
            HStack {
                Button("Cancel") { onCancel() }
                    .foregroundColor(.rpWhiteLiteral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.rpWhiteLiteral.opacity(0.08))
                    )
                Button("Done") {
                    let selectedStart = calendar.date(from: calendar.dateComponents([.year, .month], from: tempDate)) ?? initial
                    onDone(selectedStart)
                }
                    .foregroundColor(.rpEerieBlackLiteral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.rpLimeLiteral)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}



