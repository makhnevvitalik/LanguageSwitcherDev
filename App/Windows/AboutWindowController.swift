// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

//
//  AboutWindowController.swift
//  LanguageSwitcher
//
//  Created by Vitalik Makhnev on 11.06.2026.
//

import AppKit
import Foundation
import LanguageSwitcherEdition

@MainActor
final class AboutWindowController: NSObject, NSWindowDelegate {
    private let identity: AppIdentity
    private var aboutWindow: NSWindow?
    private var licensesWindowController: LicensesAcknowledgementsWindowController?
    private var updateButton: NSButton?
    private var updateProgressIndicator: NSProgressIndicator?
    private var updateStatusLabel: NSTextField?
    private var updateTask: URLSessionDataTask?
    private var activeUpdateRequestID: UUID?
    private var downloadURL: URL?
    private var isCheckingForUpdates = false

    init(identity: AppIdentity) {
        self.identity = identity
        super.init()
    }

    func showWindow() {
        if aboutWindow == nil {
            aboutWindow = makeAboutWindow()
        }

        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        updateTask?.cancel()
        resetUpdateState()
    }

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? localized("Unknown version")
        return localizedFormat("Version %@", version)
    }

    private var copyrightText: String {
        Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? ""
    }

    private func makeAboutWindow() -> NSWindow {
        let windowWidth: CGFloat = 500
        let windowHeight: CGFloat = 280
        let windowContent = NSView()

        let iconView = NSImageView(image: NSApp.applicationIconImage)
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 76),
            iconView.heightAnchor.constraint(equalToConstant: 76)
        ])

        let nameLabel = NSTextField(labelWithString: identity.brandName)
        nameLabel.font = AppStyle.Font.aboutTitle

        let editionLabel = NSTextField(labelWithString: identity.editionName)
        editionLabel.font = AppStyle.Font.emphasizedBody
        editionLabel.textColor = .secondaryLabelColor

        let versionLabel = NSTextField(labelWithString: versionText)
        versionLabel.font = AppStyle.Font.body
        versionLabel.textColor = .secondaryLabelColor

        let copyrightLabel = NSTextField(labelWithString: copyrightText)
        copyrightLabel.font = AppStyle.Font.caption
        copyrightLabel.textColor = .tertiaryLabelColor

        let taglineLabel = NSTextField(
            wrappingLabelWithString: localized("Switch keyboard layouts and fix text typed in the wrong layout or case.")
        )
        taglineLabel.font = AppStyle.Font.body
        taglineLabel.textColor = .secondaryLabelColor
        taglineLabel.maximumNumberOfLines = 3

        let updateButton = NSButton(
            title: localized("Check for Updates"),
            target: self,
            action: #selector(updateButtonPressed)
        )
        updateButton.bezelStyle = .rounded
        updateButton.keyEquivalent = "\r"
        updateButton.widthAnchor.constraint(equalToConstant: 170).isActive = true
        self.updateButton = updateButton

        let gitHubButton = NSButton(title: "GitHub ↗", target: self, action: #selector(openGitHub))
        gitHubButton.isBordered = false
        gitHubButton.contentTintColor = .linkColor
        gitHubButton.font = AppStyle.Font.emphasizedBody
        gitHubButton.focusRingType = .none

        let licensesButton = NSButton(
            title: localized("Licenses & Acknowledgements…"),
            target: self,
            action: #selector(showLicenses)
        )
        licensesButton.isBordered = false
        licensesButton.contentTintColor = .linkColor
        licensesButton.font = AppStyle.Font.control
        licensesButton.focusRingType = .none

        let progressIndicator = NSProgressIndicator()
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .small
        progressIndicator.isDisplayedWhenStopped = false
        progressIndicator.isHidden = true
        self.updateProgressIndicator = progressIndicator

        let actionStack = NSStackView(views: [updateButton, progressIndicator, gitHubButton])
        actionStack.orientation = .horizontal
        actionStack.alignment = .centerY
        actionStack.spacing = 12
        actionStack.detachesHiddenViews = true

        let statusLabel = NSTextField(wrappingLabelWithString: "")
        statusLabel.font = AppStyle.Font.status
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.maximumNumberOfLines = 2
        self.updateStatusLabel = statusLabel

        let detailsStack = NSStackView(views: [
            nameLabel,
            editionLabel,
            versionLabel,
            copyrightLabel,
            taglineLabel,
            actionStack,
            statusLabel,
            licensesButton
        ])
        detailsStack.orientation = .vertical
        detailsStack.alignment = .leading
        detailsStack.spacing = 6
        detailsStack.setCustomSpacing(12, after: copyrightLabel)
        detailsStack.setCustomSpacing(16, after: taglineLabel)
        detailsStack.setCustomSpacing(7, after: actionStack)

        let contentStack = NSStackView(views: [iconView, detailsStack])
        contentStack.orientation = .horizontal
        contentStack.alignment = .top
        contentStack.spacing = 22
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        windowContent.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: windowContent.leadingAnchor, constant: 30),
            contentStack.trailingAnchor.constraint(equalTo: windowContent.trailingAnchor, constant: -30),
            contentStack.topAnchor.constraint(equalTo: windowContent.topAnchor, constant: 28),
            detailsStack.widthAnchor.constraint(equalToConstant: 342),
            contentStack.bottomAnchor.constraint(
                lessThanOrEqualTo: windowContent.bottomAnchor,
                constant: -24
            )
        ])

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = localizedFormat("About %@", identity.productName)
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentView = windowContent
        window.center()

        return window
    }

    @objc private func openGitHub() {
        aboutWindow?.close()
        NSWorkspace.shared.open(identity.repositoryURL)
    }

    @objc private func showLicenses() {
        if licensesWindowController == nil {
            licensesWindowController = LicensesAcknowledgementsWindowController(identity: identity)
        }
        licensesWindowController?.showWindow()
    }

    @objc private func updateButtonPressed() {
        if let downloadURL {
            NSWorkspace.shared.open(downloadURL)
            return
        }
        checkForUpdates()
    }

    private func checkForUpdates() {
        guard !isCheckingForUpdates else {
            return
        }

        isCheckingForUpdates = true
        downloadURL = nil
        updateButton?.title = localized("Checking…")
        updateButton?.isEnabled = false
        updateStatusLabel?.stringValue = ""
        updateProgressIndicator?.isHidden = false
        updateProgressIndicator?.startAnimation(nil)
        let requestID = UUID()
        activeUpdateRequestID = requestID

        var request = URLRequest(
            url: identity.latestReleaseAPIURL,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self,
                      self.activeUpdateRequestID == requestID else {
                    return
                }
                self.showUpdateResult(
                    self.updateCheckResult(data: data, response: response, error: error)
                )
            }
        }
        updateTask = task
        task.resume()
    }

    private func updateCheckResult(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> UpdateCheckResult {
        if error != nil {
            return .failure(localized("Could not contact GitHub. Please try again."))
        }

        guard let response = response as? HTTPURLResponse else {
            return .failure(localized("GitHub returned an invalid response."))
        }

        guard (200...299).contains(response.statusCode) else {
            return .failure(localizedFormat("GitHub returned HTTP %d.", response.statusCode))
        }

        guard let data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let latestVersionTag = json["tag_name"] as? String,
              let latestVersion = AppVersion(latestVersionTag) else {
            return .failure(localized("GitHub returned invalid update information."))
        }

        guard let currentVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let currentVersion = AppVersion(currentVersionString) else {
            return .failure(localized("Could not determine the installed app version."))
        }

        if latestVersion > currentVersion {
            let releaseURL = (json["html_url"] as? String).flatMap(URL.init(string:))
                ?? identity.latestReleaseURL
            return .updateAvailable(tag: latestVersionTag, url: releaseURL)
        }

        return .upToDate
    }

    private func showUpdateResult(_ result: UpdateCheckResult) {
        isCheckingForUpdates = false
        activeUpdateRequestID = nil
        updateTask = nil
        updateProgressIndicator?.stopAnimation(nil)
        updateProgressIndicator?.isHidden = true
        updateButton?.isEnabled = true

        switch result {
        case .upToDate:
            downloadURL = nil
            updateButton?.title = localized("Check for Updates")
            updateStatusLabel?.textColor = .systemGreen
            updateStatusLabel?.stringValue = localized("You’re up to date.")

        case let .updateAvailable(tag, url):
            downloadURL = url
            updateButton?.title = localizedFormat("View Release %@", tag)
            updateStatusLabel?.textColor = .labelColor
            updateStatusLabel?.stringValue = localizedFormat("%@ is available.", tag)

        case let .failure(message):
            downloadURL = nil
            updateButton?.title = localized("Try Again")
            updateStatusLabel?.textColor = .systemRed
            updateStatusLabel?.stringValue = message
        }
    }

    private func resetUpdateState() {
        isCheckingForUpdates = false
        activeUpdateRequestID = nil
        updateTask = nil
        downloadURL = nil
        updateProgressIndicator?.stopAnimation(nil)
        updateProgressIndicator?.isHidden = true
        updateButton?.isEnabled = true
        updateButton?.title = localized("Check for Updates")
        updateStatusLabel?.textColor = .secondaryLabelColor
        updateStatusLabel?.stringValue = ""
    }
}

@MainActor
private final class LicensesAcknowledgementsWindowController: NSObject, NSWindowDelegate {
    private struct Document {
        let title: String
        let text: String
    }

    private let identity: AppIdentity
    private var window: NSWindow?
    private let textView = NSTextView()
    private var documents: [Document] = []

    init(identity: AppIdentity) {
        self.identity = identity
        super.init()
    }

    func showWindow() {
        if window == nil {
            window = makeWindow()
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makeWindow() -> NSWindow {
        documents = loadDocuments()

        let contentView = NSView()
        let documentPicker = NSPopUpButton(frame: .zero, pullsDown: false)
        documentPicker.addItems(withTitles: documents.map(\.title))
        documentPicker.target = self
        documentPicker.action = #selector(selectDocument(_:))

        let heading = NSTextField(labelWithString: localized("Licenses & Acknowledgements"))
        heading.font = AppStyle.Font.windowTitle

        let intro = NSTextField(
            wrappingLabelWithString: localized("Language Switcher materials and bundled language data are covered by separate license terms.")
        )
        intro.font = AppStyle.Font.status
        intro.textColor = .secondaryLabelColor

        let header = NSStackView(views: [heading, intro, documentPicker])
        header.orientation = .vertical
        header.alignment = .leading
        header.spacing = 7
        header.setCustomSpacing(14, after: intro)
        header.translatesAutoresizingMaskIntoConstraints = false

        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = AppStyle.Font.example
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.isAutomaticLinkDetectionEnabled = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: 0,
            height: CGFloat.greatestFiniteMagnitude
        )

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        scrollView.documentView = textView
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(header)
        contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            header.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            documentPicker.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        showDocument(at: 0)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 650, height: 520),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = localized("Licenses & Acknowledgements")
        window.minSize = NSSize(width: 520, height: 380)
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentView = contentView
        window.center()
        return window
    }

    @objc private func selectDocument(_ sender: NSPopUpButton) {
        showDocument(at: sender.indexOfSelectedItem)
    }

    private func showDocument(at index: Int) {
        guard documents.indices.contains(index) else { return }
        textView.string = documents[index].text
        textView.scrollToBeginningOfDocument(nil)
    }

    private func loadDocuments() -> [Document] {
        var result = [
            Document(
                title: localizedFormat("License for %@", identity.productName),
                text: resourceText(named: "LICENSE")
                    ?? localizedFormat("The %@ license is unavailable.", identity.productName)
            ),
            Document(
                title: localized("Third-Party Materials & Notices"),
                text: resourceText(named: "THIRD_PARTY_NOTICES", extension: "md")
                    ?? localized("Third-party notices are unavailable.")
            )
        ]

        if let resourceBundle = lexiconResourceBundle() {
            if let attribution = resourceText(
                named: "ATTRIBUTION",
                extension: "md",
                bundle: resourceBundle
            ) {
                result.append(Document(title: localized("Frequency Data Attribution"), text: attribution))
            }
            if let license = resourceText(
                named: "LICENSE-CC-BY-SA-4.0",
                extension: "txt",
                bundle: resourceBundle
            ) {
                result.append(Document(title: localized("CC BY-SA 4.0 Legal Code"), text: license))
            }
        }
        return result
    }

    private func resourceText(
        named name: String,
        extension fileExtension: String? = nil,
        bundle: Bundle = .main
    ) -> String? {
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    private func lexiconResourceBundle() -> Bundle? {
        guard let url = Bundle.main.url(
            forResource: "LanguageSwitcherKit_LanguageSwitcherLexicon",
            withExtension: "bundle"
        ) else {
            return nil
        }
        return Bundle(url: url)
    }
}

private enum UpdateCheckResult {
    case upToDate
    case updateAvailable(tag: String, url: URL)
    case failure(String)
}

private struct AppVersion: Comparable {
    private let components: [Int]

    init?(_ rawValue: String) {
        var normalizedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedValue.lowercased().hasPrefix("v") {
            normalizedValue.removeFirst()
        }

        let components = normalizedValue.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard !components.isEmpty else {
            return nil
        }

        var parsedComponents = [Int]()
        for component in components {
            guard !component.isEmpty,
                  let parsedComponent = Int(component),
                  parsedComponent >= 0 else {
                return nil
            }

            parsedComponents.append(parsedComponent)
        }

        self.components = parsedComponents
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let componentCount = max(lhs.components.count, rhs.components.count)
        for index in 0..<componentCount {
            let leftComponent = lhs.component(at: index)
            let rightComponent = rhs.component(at: index)

            if leftComponent != rightComponent {
                return leftComponent < rightComponent
            }
        }

        return false
    }

    private func component(at index: Int) -> Int {
        guard index < components.count else {
            return 0
        }

        return components[index]
    }
}
