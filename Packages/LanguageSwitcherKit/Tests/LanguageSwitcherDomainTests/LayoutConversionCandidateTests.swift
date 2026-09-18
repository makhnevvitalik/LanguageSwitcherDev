// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain
import XCTest

final class LayoutConversionCandidateTests: XCTestCase {
    func testCharacterCoverageWinsBeforeLanguageScores() {
        let candidates = [
            LayoutConversionCandidate(
                inputSourceID: "ru",
                characterCoverageScore: 4,
                spellingScore: 0,
                frequencyScore: 0
            ),
            LayoutConversionCandidate(
                inputSourceID: "en",
                characterCoverageScore: 0,
                spellingScore: 1,
                frequencyScore: 1
            )
        ]

        XCTAssertEqual(LayoutConversionCandidateSelector.best(in: candidates), candidates[0])
    }

    func testSpellingScoreWinsBeforeFrequency() {
        let candidates = [
            LayoutConversionCandidate(
                inputSourceID: "en",
                spellingScore: 0,
                frequencyScore: 1.0
            ),
            LayoutConversionCandidate(
                inputSourceID: "ru",
                spellingScore: 1,
                frequencyScore: 0.1
            )
        ]

        XCTAssertEqual(LayoutConversionCandidateSelector.best(in: candidates), candidates[1])
    }

    func testFrequencyBreaksEqualSpellingScore() {
        let candidates = [
            LayoutConversionCandidate(
                inputSourceID: "en",
                spellingScore: 1,
                frequencyScore: 0.2
            ),
            LayoutConversionCandidate(
                inputSourceID: "ru",
                spellingScore: 1,
                frequencyScore: 0.8
            )
        ]

        XCTAssertEqual(LayoutConversionCandidateSelector.best(in: candidates), candidates[1])
    }

    func testExactTieKeepsFirstCandidate() {
        let candidates = [
            LayoutConversionCandidate(
                inputSourceID: "en",
                spellingScore: 0,
                frequencyScore: 0
            ),
            LayoutConversionCandidate(
                inputSourceID: "ru",
                spellingScore: 0,
                frequencyScore: 0
            )
        ]

        XCTAssertEqual(LayoutConversionCandidateSelector.best(in: candidates), candidates[0])
    }
}
