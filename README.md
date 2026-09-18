<!-- SPDX-FileCopyrightText: 2026 Vitalik Makhnev -->
<!-- SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0 -->

# Language Switcher Plus

Language Switcher Plus lets you switch input languages with a quick Fn/Globe or Command tap and fix text typed in the wrong layout or case with customizable global shortcuts.

[Download the latest release](https://github.com/makhnevvitalik/LanguageSwitcherPlus/releases/latest)

## Contents

- [English](#english)
  - [Features](#features)
  - [Install and start](#install-and-start)
  - [Text action shortcuts](#text-action-shortcuts)
  - [Permissions](#permissions)
  - [License](#license)
- [Русский](#русский)
  - [Возможности](#возможности)
  - [Установка и запуск](#установка-и-запуск)
  - [Сочетания для действий с текстом](#сочетания-для-действий-с-текстом)
  - [Разрешения](#разрешения)
  - [Лицензия](#лицензия)

## English

### Features

- Switch between selected macOS input sources with Fn/Globe, Command, or both.
- Choose which input sources participate in switching and text conversion.
- Convert text typed in the wrong keyboard layout.
- Change text to Uppercase, Lowercase, Capitalize Words, or Invert Case.
- Assign flexible global shortcuts using modifier keys and F1–F20 with Once, Twice, and Hold + twice press patterns.
- Apply shortcut actions to recently typed text, the last word, or selected text.

### Install and start

Language Switcher Plus requires macOS 12 or later.

1. Download the universal DMG from the [latest release](https://github.com/makhnevvitalik/LanguageSwitcherPlus/releases/latest).
2. Open the DMG and drag **Language Switcher Plus.app** to **Applications**.
3. Open the app from **Applications** or Spotlight. It runs in the menu bar.
4. Make sure at least two input sources are enabled in macOS System Settings.
5. Open the Language Switcher Plus menu, choose active inputs under **General**, then enable Fn/Globe, Command, or both under **Keyboard switching**.
6. Grant the permissions requested by the app.

The release also includes a ZIP archive if you prefer to unzip the app manually and move it to **Applications**.

The downloadable app is self-signed and is not notarized by Apple. If macOS blocks the first launch, try opening the app once, then go to **System Settings → Privacy & Security**, find the security message for Language Switcher Plus, and select **Open Anyway**. On macOS 12, use **System Preferences → Security & Privacy → General → Open Anyway**.

When using Fn/Globe, set its macOS action to **Do Nothing** under Keyboard settings so the system action does not conflict with Language Switcher Plus.

### Text action shortcuts

Text action shortcuts run **Convert Layout**, **Uppercase**, **Lowercase**, **Capitalize Words**, or **Invert Case** without opening the menu.

Open **Text actions → Shortcuts → Configure…** to assign shortcuts. Supported keys are Shift, Control, Option, Command, and F1–F20. No text-action shortcuts are assigned by default.

#### Press patterns

- **Once** — press and release the shortcut once. Example: press and release `⇧⌥`.
- **Twice** — press and release the entire shortcut twice. Example: press `⇧⌥`, release it, then press and release `⇧⌥` again.
- **Hold + twice** — hold one or more modifier keys and tap the final modifier or F-key twice. Example: hold `⇧` and tap `⌥` twice.

The direction of **Hold + twice** matters: holding `⇧` and tapping `⌥` is different from holding `⌥` and tapping `⇧`.

Once and Twice may use the same keys for different actions. In that case, the Once action waits for the configured double-press interval. If no Twice action uses those keys, Once runs immediately after release.

#### Apply to

**Apply to** determines which text a shortcut action targets:

- **Typed text** — all tracked typed text.
- **Last word** — only the most recently typed word.
- **Selection** — selected text.

**Selected text takes priority in every mode.** If text is selected, the action applies to the selection regardless of **Apply to**. Menu actions also always apply to selected text.

### Permissions

| Permission | Used for |
| --- | --- |
| **Input Monitoring** | Language switching and global shortcuts |
| **Accessibility** | Reading and replacing text for Text actions |

Language Switcher Plus opens the relevant macOS settings page when a permission is needed. If macOS asks, choose **Quit & Reopen**, then start the action again.

### License

Language Switcher Plus is source-available under the [MIT License with the Commons Clause License Condition v1.0](LICENSE). You may use, modify, and redistribute original or modified builds at no charge. Selling the software—including paid distribution through an app store—or a product or service whose value derives substantially from it is prohibited.

Bundled FrequencyWords data is licensed separately under CC BY-SA 4.0. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for attribution and third-party license details.

## Русский

Language Switcher Plus позволяет быстро переключать языки ввода нажатием Fn/Globe или Command и исправлять текст, набранный в неверной раскладке или регистре, с помощью настраиваемых глобальных сочетаний клавиш.

[Скачать последнюю версию](https://github.com/makhnevvitalik/LanguageSwitcherPlus/releases/latest)

### Возможности

- Переключение между выбранными источниками ввода macOS с помощью Fn/Globe, Command или обеих клавиш.
- Выбор источников ввода, участвующих в переключении и преобразовании текста.
- Исправление текста, набранного в неверной раскладке.
- Преобразование текста в верхний и нижний регистр, написание слов с прописной буквы или инвертирование регистра.
- Настраиваемые глобальные сочетания из клавиш-модификаторов и F1–F20 с вариантами «Один раз», «Дважды» и «Удержание + двойное нажатие».
- Применение действий к недавно набранному тексту, последнему слову или выделенному тексту.

### Установка и запуск

Language Switcher Plus требует macOS 12 или новее.

1. Скачайте universal DMG из [последнего релиза](https://github.com/makhnevvitalik/LanguageSwitcherPlus/releases/latest).
2. Откройте DMG и перетащите **Language Switcher Plus.app** в папку **Applications**.
3. Откройте приложение из **Applications** или через Spotlight. Оно работает в строке меню.
4. Убедитесь, что в настройках macOS включены как минимум два источника ввода.
5. Откройте меню Language Switcher Plus, выберите используемые источники в разделе **Основные**, затем включите Fn/Globe, Command или обе клавиши в разделе **Переключение раскладки**.
6. Предоставьте запрошенные приложением разрешения.

В релиз также входит ZIP-архив: его можно распаковать вручную и переместить приложение в **Applications**.

Загружаемое приложение подписано собственным сертификатом и не нотаризовано Apple. Если macOS блокирует первый запуск, попробуйте один раз открыть приложение, затем перейдите в **Системные настройки → Конфиденциальность и безопасность**, найдите сообщение о Language Switcher Plus и выберите **Всё равно открыть**. В macOS 12 используйте **Системные настройки → Защита и безопасность → Основные → Всё равно открыть**.

При использовании Fn/Globe установите для неё действие **Ничего не делать** в настройках клавиатуры macOS, чтобы системное действие не конфликтовало с Language Switcher Plus.

### Сочетания для действий с текстом

Сочетания позволяют запускать действия **Сменить раскладку**, **Верхний регистр**, **Нижний регистр**, **С прописной буквы** и **Инвертировать регистр**, не открывая меню.

Откройте **Действия с текстом → Сочетания клавиш → Настроить…**, чтобы назначить сочетания. Поддерживаются Shift, Control, Option, Command и F1–F20. По умолчанию сочетания для действий с текстом не назначены.

#### Варианты нажатия

- **Один раз** — один раз нажмите и отпустите сочетание. Пример: нажмите и отпустите `⇧⌥`.
- **Дважды** — дважды полностью нажмите и отпустите сочетание. Пример: нажмите `⇧⌥`, отпустите, затем снова нажмите и отпустите `⇧⌥`.
- **Удержание + двойное нажатие** — удерживайте одну или несколько клавиш-модификаторов и дважды нажмите последнюю клавишу-модификатор или F-клавишу. Пример: удерживайте `⇧` и дважды нажмите `⌥`.

Для **Удержания + двойного нажатия** важен порядок: удерживать `⇧` и нажимать `⌥` — не то же самое, что удерживать `⌥` и нажимать `⇧`.

Для разных действий можно назначить варианты **Один раз** и **Дважды** с одинаковыми клавишами. В этом случае действие «Один раз» ждёт окончания настроенного интервала двойного нажатия. Если для этих клавиш нет действия «Дважды», «Один раз» выполняется сразу после отпускания.

#### Обрабатывать

Настройка **Обрабатывать** определяет, к какому тексту применяется действие по сочетанию:

- **Набранное** — весь отслеживаемый набранный текст.
- **Последнее слово** — только последнее введённое слово.
- **Выделение** — выделенный текст.

**Выделенный текст имеет приоритет во всех режимах.** Если что-то выделено, действие применяется к выделению независимо от настройки **Обрабатывать**. Действия из меню также всегда применяются к выделенному тексту.

### Разрешения

| Разрешение | Для чего используется |
| --- | --- |
| **Мониторинг ввода** | Переключение языка и глобальные сочетания |
| **Универсальный доступ** | Чтение и замена текста для действий с текстом |

Когда требуется разрешение, Language Switcher Plus открывает нужный раздел настроек macOS. Если macOS предложит действие **Завершить и открыть снова**, выберите его, а затем повторите нужное действие.

### Лицензия

Исходный код Language Switcher Plus доступен по [лицензии MIT с условием Commons Clause License Condition v1.0](LICENSE). Оригинальные и изменённые сборки можно использовать, изменять и распространять бесплатно. Продажа программы, включая платное распространение через магазины приложений, а также продуктов или услуг, ценность которых в значительной степени основана на ней, запрещена.

Встроенные данные FrequencyWords распространяются отдельно по лицензии CC BY-SA 4.0. Авторские сведения и условия сторонних лицензий приведены в [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
