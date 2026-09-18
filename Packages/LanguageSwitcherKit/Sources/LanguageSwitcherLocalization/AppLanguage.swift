// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation

public enum AppLanguage: String, CaseIterable, Sendable {
    case english = "en"
    case russian = "ru"

    public static let fallback: AppLanguage = .english

    public var displayName: String {
        switch self {
        case .english: "English"
        case .russian: "Русский"
        }
    }

    static func preferred(from preferredLanguages: [String]) -> AppLanguage {
        let identifiers = allCases.map(\.rawValue)
        let match = Bundle.preferredLocalizations(
            from: identifiers,
            forPreferences: preferredLanguages
        ).first
        return match.flatMap(AppLanguage.init(rawValue:)) ?? fallback
    }
}

public final class AppLanguageStore {
    public static let userDefaultsKey = "app.language"

    private let userDefaults: UserDefaults
    public private(set) var selectedLanguage: AppLanguage

    public init(
        userDefaults: UserDefaults = .standard,
        preferredLanguages: () -> [String] = { Locale.preferredLanguages }
    ) {
        self.userDefaults = userDefaults
        if let storedIdentifier = userDefaults.string(forKey: Self.userDefaultsKey),
           let storedLanguage = AppLanguage(rawValue: storedIdentifier) {
            selectedLanguage = storedLanguage
        } else {
            let detectedLanguage = AppLanguage.preferred(from: preferredLanguages())
            selectedLanguage = detectedLanguage
            userDefaults.set(detectedLanguage.rawValue, forKey: Self.userDefaultsKey)
        }
    }

    public func select(_ language: AppLanguage) {
        selectedLanguage = language
        userDefaults.set(language.rawValue, forKey: Self.userDefaultsKey)
    }
}
