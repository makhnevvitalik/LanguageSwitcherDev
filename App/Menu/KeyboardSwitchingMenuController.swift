// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit
import Foundation
import LanguageSwitcherDomain
import LanguageSwitcherMacOS

@MainActor
final class KeyboardSwitchingMenuController: NSObject {
    private let isShortcutEnabled: (ModifierShortcut) -> Bool
    private let setShortcutEnabled: (ModifierShortcut, Bool) -> Void
    private let currentTapDuration: () -> TimeInterval
    private let setTapDuration: (TimeInterval) -> Void
    private let durationOptions: [TimeInterval]
    private let defaultDuration: TimeInterval

    private var shortcutButtons: [ModifierShortcut: NSButton] = [:]
    private let durationButton = NSPopUpButton(frame: .zero, pullsDown: false)

    let view = NSBox()

    init(
        isShortcutEnabled: @escaping (ModifierShortcut) -> Bool,
        setShortcutEnabled: @escaping (ModifierShortcut, Bool) -> Void,
        currentTapDuration: @escaping () -> TimeInterval,
        setTapDuration: @escaping (TimeInterval) -> Void,
        durationOptions: [TimeInterval],
        defaultDuration: TimeInterval
    ) {
        self.isShortcutEnabled = isShortcutEnabled
        self.setShortcutEnabled = setShortcutEnabled
        self.currentTapDuration = currentTapDuration
        self.setTapDuration = setTapDuration
        self.durationOptions = durationOptions
        self.defaultDuration = defaultDuration
        super.init()
        configureView()
    }

    func refresh() {
        for shortcut in ModifierShortcut.allCases {
            guard let button = shortcutButtons[shortcut] else { continue }
            let isEnabled = isShortcutEnabled(shortcut)
            button.state = isEnabled ? .on : .off
            MenuCardLayout.styleCompactControl(
                button,
                title: shortcut == .functionGlobe ? "fn" : "⌘",
                isActive: isEnabled
            )
        }

        MenuCardLayout.configureTimeIntervalOptions(
            for: durationButton,
            options: durationOptions,
            selectedValue: currentTapDuration(),
            defaultValue: defaultDuration
        )
    }

    private func configureView() {
        view.boxType = .custom
        view.borderWidth = 0
        view.fillColor = .controlBackgroundColor
        view.cornerRadius = MenuCardLayout.cardCornerRadius
        view.contentViewMargins = .zero

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        let heading = MenuCardLayout.sectionHeading(
            title: localized("Keyboard switching"),
            symbolName: "keyboard"
        )
        stack.addArrangedSubview(heading)

        let buttons = NSStackView()
        buttons.orientation = .horizontal
        buttons.alignment = .centerY
        buttons.spacing = MenuCardLayout.compactControlSpacing
        for shortcut in ModifierShortcut.allCases {
            let button = NSButton(
                title: shortcut == .functionGlobe ? "fn" : "⌘",
                target: self,
                action: #selector(toggleShortcut(_:))
            )
            button.setButtonType(.toggle)
            MenuCardLayout.configureCompactControl(button)
            button.tag = ModifierShortcut.allCases.firstIndex(of: shortcut) ?? 0
            button.toolTip = toolTip(for: shortcut)
            shortcutButtons[shortcut] = button
            buttons.addArrangedSubview(button)
        }

        let shortcutRow = MenuCardLayout.row(
            title: localized("Switch language with"),
            detail: nil,
            trailing: buttons
        )
        stack.addArrangedSubview(shortcutRow)
        MenuCardLayout.addSeparator(to: stack)

        durationButton.target = self
        durationButton.action = #selector(selectDuration(_:))
        MenuCardLayout.configurePopUpControl(durationButton)
        let durationRow = MenuCardLayout.row(
            title: localized("Shortcut tap duration"),
            detail: localized("Maximum time for a switching-key tap"),
            trailing: durationButton
        )
        stack.addArrangedSubview(durationRow)

        guard let contentView = view.contentView else { return }
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            heading.widthAnchor.constraint(equalTo: stack.widthAnchor),
            shortcutRow.widthAnchor.constraint(equalTo: stack.widthAnchor),
            durationRow.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
        refresh()
    }

    private func toolTip(for shortcut: ModifierShortcut) -> String {
        switch shortcut {
        case .functionGlobe:
            localized("Press and release Fn/Globe to switch to the next active input source. Set the macOS Fn/Globe action to Do Nothing.")
        case .command:
            localized("Press and release Command to switch to the next active input source.")
        }
    }

    @objc private func toggleShortcut(_ sender: NSButton) {
        guard ModifierShortcut.allCases.indices.contains(sender.tag) else { return }
        let shortcut = ModifierShortcut.allCases[sender.tag]
        setShortcutEnabled(shortcut, sender.state == .on)
        refresh()
    }

    @objc private func selectDuration(_ sender: NSPopUpButton) {
        guard let duration = sender.selectedItem?.representedObject as? TimeInterval else { return }
        setTapDuration(duration)
        refresh()
    }

}
