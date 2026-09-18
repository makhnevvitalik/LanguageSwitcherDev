// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit
import LanguageSwitcherLocalization

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let languageStore = AppLanguageStore()
    private lazy var applicationCoordinator = ApplicationCoordinator(
        identity: AppCompositionRoot.identity,
        appController: AppCompositionRoot.makeAppController(),
        languageStore: languageStore
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppLocalization.configure(language: languageStore.selectedLanguage)
        applicationCoordinator.start()
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        applicationCoordinator.applicationShouldHandleReopen(
            sender,
            hasVisibleWindows: flag
        )
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        applicationCoordinator.applicationDidBecomeActive()
    }

    func applicationWillTerminate(_ notification: Notification) {
        applicationCoordinator.stop()
    }
}
