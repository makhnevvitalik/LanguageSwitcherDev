// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
@testable import LanguageSwitcherLexicon
import XCTest

final class BundledWordFrequencyProviderTests: XCTestCase {
    func testUsesFileOrderAsNormalizedRank() throws {
        let provider = BundledWordFrequencyProvider(resourceDirectory: fixtureDirectory())

        XCTAssertEqual(provider.normalizedFrequency(of: "HELLO", languageCode: "en"), 1)
        XCTAssertEqual(
            try XCTUnwrap(provider.normalizedFrequency(of: "world", languageCode: "en")),
            1.0 / 3.0,
            accuracy: 0.000_001
        )
        XCTAssertGreaterThan(
            try XCTUnwrap(provider.normalizedFrequency(of: "can't", languageCode: "en")),
            0
        )
    }

    func testCanonicalizesApostrophesForLookup() {
        let provider = BundledWordFrequencyProvider(resourceDirectory: fixtureDirectory())

        XCTAssertEqual(
            provider.normalizedFrequency(of: "CAN’T", languageCode: "en"),
            provider.normalizedFrequency(of: "can't", languageCode: "en")
        )
    }

    func testLoadsLanguageOnlyOnFirstLookup() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let file = directory.appendingPathComponent("en.txt")
        try "before\n".write(to: file, atomically: true, encoding: .utf8)
        let provider = BundledWordFrequencyProvider(resourceDirectory: directory)

        try "after\n".write(to: file, atomically: true, encoding: .utf8)

        XCTAssertNil(provider.normalizedFrequency(of: "before", languageCode: "en"))
        XCTAssertEqual(provider.normalizedFrequency(of: "after", languageCode: "en"), 1)
    }

    func testPrepareLoadsRequestedLanguageIntoCache() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("en.txt")
        try "ready\n".write(to: file, atomically: true, encoding: .utf8)
        let provider = BundledWordFrequencyProvider(resourceDirectory: directory)

        provider.prepare(languageCodes: ["en"])
        try "changed\n".write(to: file, atomically: true, encoding: .utf8)

        XCTAssertEqual(provider.normalizedFrequency(of: "ready", languageCode: "en"), 1)
        XCTAssertNil(provider.normalizedFrequency(of: "changed", languageCode: "en"))
    }

    func testMissingLanguageIsUnsupported() {
        let provider = BundledWordFrequencyProvider(resourceDirectory: fixtureDirectory())

        XCTAssertTrue(provider.supports(languageCode: "ru"))
        XCTAssertFalse(provider.supports(languageCode: "ja"))
        XCTAssertNil(provider.normalizedFrequency(of: "言葉", languageCode: "ja"))
    }

    func testRetainsVerifiedRussianSingleCharacterWord() {
        let provider = BundledWordFrequencyProvider(resourceDirectory: fixtureDirectory())

        XCTAssertNotNil(provider.normalizedFrequency(of: "я", languageCode: "ru"))
    }

    func testBundledResourcesContainEveryAgreedLanguage() {
        let provider = BundledWordFrequencyProvider()
        let languageCodes = (
            "af bg br bs ca cs da de el en eo es et eu fi fr gl hr hu hy id is it ka "
                + "kk lt lv mk ms nl no pl pt pt_br ro ru sk sl sq sr sv tl tr uk"
        ).split(separator: " ").map(String.init)

        XCTAssertTrue(languageCodes.allSatisfy(provider.supports(languageCode:)))
        XCTAssertNotNil(provider.normalizedFrequency(of: "я", languageCode: "ru"))
    }

    private func fixtureDirectory() -> URL {
        Bundle.module.resourceURL!.appendingPathComponent("Fixtures", isDirectory: true)
    }
}
