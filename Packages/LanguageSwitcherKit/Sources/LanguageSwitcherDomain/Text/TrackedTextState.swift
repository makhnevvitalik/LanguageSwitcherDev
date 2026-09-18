// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public enum TrackedTextRecordingResult: Equatable, Sendable {
    case appended
    case startedNewSegment
}

public struct TrackedTextSnapshot: Equatable, Sendable {
    public let generation: UInt64
    public let applicationID: String
    public let text: String

    public init(
        generation: UInt64,
        applicationID: String,
        text: String
    ) {
        self.generation = generation
        self.applicationID = applicationID
        self.text = text
    }
}

public struct TrackedTextState: Sendable {
    private var generation: UInt64 = 0
    private var applicationID: String?
    private var text = ""
    private var startsNewSegmentOnNextInput = false

    public init() {}

    public var snapshot: TrackedTextSnapshot? {
        guard let applicationID, !text.isEmpty else {
            return nil
        }
        return TrackedTextSnapshot(
            generation: generation,
            applicationID: applicationID,
            text: text
        )
    }

    @discardableResult
    public mutating func recordPrintableText(
        _ newText: String,
        applicationID: String
    ) -> TrackedTextRecordingResult? {
        guard !newText.isEmpty else { return nil }

        let startsNewSegment = self.applicationID != applicationID
            || startsNewSegmentOnNextInput
        if startsNewSegment {
            self.applicationID = applicationID
            text = ""
            startsNewSegmentOnNextInput = false
        }
        text += newText
        generation &+= 1
        return startsNewSegment ? .startedNewSegment : .appended
    }

    public mutating func recordBackspace(applicationID: String) {
        guard self.applicationID == applicationID, !text.isEmpty else {
            invalidate()
            return
        }

        text.removeLast()
        startsNewSegmentOnNextInput = false
        generation &+= 1
    }

    public mutating func commitReplacement(
        _ replacement: String,
        expected: TrackedTextSnapshot
    ) -> Bool {
        guard snapshot == expected else { return false }

        text = replacement
        startsNewSegmentOnNextInput = true
        generation &+= 1
        return true
    }

    public mutating func invalidate() {
        generation &+= 1
        applicationID = nil
        text = ""
        startsNewSegmentOnNextInput = false
    }
}
