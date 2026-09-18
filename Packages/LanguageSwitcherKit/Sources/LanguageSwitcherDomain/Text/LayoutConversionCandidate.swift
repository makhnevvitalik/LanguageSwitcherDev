// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public struct LayoutConversionCandidate: Equatable, Sendable {
    public let inputSourceID: String
    public let characterCoverageScore: Int
    public let spellingScore: Int
    public let frequencyScore: Double

    public init(
        inputSourceID: String,
        characterCoverageScore: Int = 0,
        spellingScore: Int,
        frequencyScore: Double
    ) {
        self.inputSourceID = inputSourceID
        self.characterCoverageScore = characterCoverageScore
        self.spellingScore = spellingScore
        self.frequencyScore = frequencyScore
    }
}

public enum LayoutConversionCandidateSelector {
    public static func best(
        in candidates: [LayoutConversionCandidate]
    ) -> LayoutConversionCandidate? {
        guard var best = candidates.first else { return nil }

        for candidate in candidates.dropFirst() {
            if candidate.characterCoverageScore > best.characterCoverageScore
                || (
                    candidate.characterCoverageScore == best.characterCoverageScore
                        && candidate.spellingScore > best.spellingScore
                )
                || (
                    candidate.characterCoverageScore == best.characterCoverageScore
                        && candidate.spellingScore == best.spellingScore
                        && candidate.frequencyScore > best.frequencyScore
                ) {
                best = candidate
            }
        }

        return best
    }
}
