import AppKit

// MARK: - Constants

private enum Layout {
    static let horizontalPadding: CGFloat = 28
    static let verticalPadding: CGFloat = 8
    static let labelLeading: CGFloat = 14
    static let labelTop: CGFloat = 4
}

private enum Defaults {
    static let selectedLanguageKey = "selectedLanguageIndex"
}

private let updateIntervalSeconds: TimeInterval = 3600

// MARK: - Models

struct ProgressData {
    let monthPercent: Int
    let monthDaysLeft: Int
    let monthName: String
    let yearPercent: Int
    let yearDaysLeft: Int
    let year: String
}

struct Language {
    let name: String
    let locale: Locale
    let monthFormat: (Int) -> String
    let monthDaysFormat: (Int, String) -> String
    let yearFormat: (Int) -> String
    let yearDaysFormat: (Int, String) -> String
    let languageLabel: String
    let quitLabel: String
}

// MARK: - Language Definitions

let languages: [Language] = [
    Language(name: "English", locale: Locale(identifier: "en"),
             monthFormat: { "Month: \($0)%" },
             monthDaysFormat: { "\($0) days left in \($1)" },
             yearFormat: { "Year: \($0)%" },
             yearDaysFormat: { "\($0) days left in \($1)" },
             languageLabel: "Language", quitLabel: "Quit"),
    Language(name: "Italiano", locale: Locale(identifier: "it"),
             monthFormat: { "Mese: \($0)%" },
             monthDaysFormat: { "Mancano \($0) giorni alla fine di \($1)" },
             yearFormat: { "Anno: \($0)%" },
             yearDaysFormat: { "Mancano \($0) giorni alla fine del \($1)" },
             languageLabel: "Lingua", quitLabel: "Esci"),
    Language(name: "Español", locale: Locale(identifier: "es"),
             monthFormat: { "Mes: \($0)%" },
             monthDaysFormat: { "Quedan \($0) días de \($1)" },
             yearFormat: { "Año: \($0)%" },
             yearDaysFormat: { "Quedan \($0) días de \($1)" },
             languageLabel: "Idioma", quitLabel: "Salir"),
    Language(name: "Français", locale: Locale(identifier: "fr"),
             monthFormat: { "Mois : \($0) %" },
             monthDaysFormat: { "Il reste \($0) jours en \($1)" },
             yearFormat: { "Année : \($0) %" },
             yearDaysFormat: { "Il reste \($0) jours en \($1)" },
             languageLabel: "Langue", quitLabel: "Quitter"),
    Language(name: "Português", locale: Locale(identifier: "pt"),
             monthFormat: { "Mês: \($0)%" },
             monthDaysFormat: { "Faltam \($0) dias para o fim de \($1)" },
             yearFormat: { "Ano: \($0)%" },
             yearDaysFormat: { "Faltam \($0) dias para o fim de \($1)" },
             languageLabel: "Idioma", quitLabel: "Sair"),
    Language(name: "Deutsch", locale: Locale(identifier: "de"),
             monthFormat: { "Monat: \($0) %" },
             monthDaysFormat: { "Noch \($0) Tage im \($1)" },
             yearFormat: { "Jahr: \($0) %" },
             yearDaysFormat: { "Noch \($0) Tage in \($1)" },
             languageLabel: "Sprache", quitLabel: "Beenden"),
    Language(name: "简体中文", locale: Locale(identifier: "zh-Hans"),
             monthFormat: { "月进度: \($0)%" },
             monthDaysFormat: { "\($1)还剩\($0)天" },
             yearFormat: { "年进度: \($0)%" },
             yearDaysFormat: { "\($1)年还剩\($0)天" },
             languageLabel: "语言", quitLabel: "退出"),
    Language(name: "繁體中文", locale: Locale(identifier: "zh-Hant"),
             monthFormat: { "月進度: \($0)%" },
             monthDaysFormat: { "\($1)還剩\($0)天" },
             yearFormat: { "年進度: \($0)%" },
             yearDaysFormat: { "\($1)年還剩\($0)天" },
             languageLabel: "語言", quitLabel: "結束"),
    Language(name: "日本語", locale: Locale(identifier: "ja"),
             monthFormat: { "今月: \($0)%" },
             monthDaysFormat: { "\($1)はあと\($0)日" },
             yearFormat: { "今年: \($0)%" },
             yearDaysFormat: { "\($1)年はあと\($0)日" },
             languageLabel: "言語", quitLabel: "終了"),
    Language(name: "한국어", locale: Locale(identifier: "ko"),
             monthFormat: { "이번 달: \($0)%" },
             monthDaysFormat: { "\($1) \($0)일 남음" },
             yearFormat: { "올해: \($0)%" },
             yearDaysFormat: { "\($1)년 \($0)일 남음" },
             languageLabel: "언어", quitLabel: "종료"),
]

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var monthPercentLabel: NSTextField!
    private var monthInfoLabel: NSTextField!
    private var yearPercentLabel: NSTextField!
    private var yearDaysLabel: NSTextField!
    private var languageMenuItems: [NSMenuItem] = []
    private var languageMenuItem: NSMenuItem!
    private var quitMenuItem: NSMenuItem!
    private var timer: Timer?
    private var monthFormatter = DateFormatter()
    private var selectedLanguageIndex: Int = {
        let saved = UserDefaults.standard.integer(forKey: Defaults.selectedLanguageKey)
        return saved < languages.count ? saved : 0
    }()

    private func makeInfoItem(_ text: String) -> (NSMenuItem, NSTextField) {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.menuFont(ofSize: NSFont.systemFontSize)
        label.textColor = .labelColor
        label.sizeToFit()

        let container = NSView(frame: NSRect(
            x: 0, y: 0,
            width: label.frame.width + Layout.horizontalPadding,
            height: label.frame.height + Layout.verticalPadding
        ))
        label.frame.origin = NSPoint(x: Layout.labelLeading, y: Layout.labelTop)
        container.addSubview(label)

        let item = NSMenuItem()
        item.view = container
        return (item, label)
    }

    private func updateLabel(_ label: NSTextField, _ text: String) {
        label.stringValue = text
        label.sizeToFit()
        label.superview?.frame.size = NSSize(
            width: label.frame.width + Layout.horizontalPadding,
            height: label.frame.height + Layout.verticalPadding
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let progress = computeProgress()
        let lang = languages[selectedLanguageIndex]

        let menu = NSMenu()
        var item: NSMenuItem

        (item, monthPercentLabel) = makeInfoItem(lang.monthFormat(progress.monthPercent))
        menu.addItem(item)
        (item, monthInfoLabel) = makeInfoItem(lang.monthDaysFormat(progress.monthDaysLeft, progress.monthName))
        menu.addItem(item)
        menu.addItem(NSMenuItem.separator())
        (item, yearPercentLabel) = makeInfoItem(lang.yearFormat(progress.yearPercent))
        menu.addItem(item)
        (item, yearDaysLabel) = makeInfoItem(lang.yearDaysFormat(progress.yearDaysLeft, progress.year))
        menu.addItem(item)
        menu.addItem(NSMenuItem.separator())

        let langSubmenu = NSMenu()
        for (i, l) in languages.enumerated() {
            let langItem = NSMenuItem(title: l.name, action: #selector(languageSelected(_:)), keyEquivalent: "")
            langItem.target = self
            langItem.tag = i
            if i == selectedLanguageIndex { langItem.state = .on }
            langSubmenu.addItem(langItem)
            languageMenuItems.append(langItem)
        }
        languageMenuItem = NSMenuItem(title: lang.languageLabel, action: nil, keyEquivalent: "")
        languageMenuItem.submenu = langSubmenu
        menu.addItem(languageMenuItem)

        menu.addItem(NSMenuItem.separator())
        quitMenuItem = NSMenuItem(title: lang.quitLabel, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitMenuItem)
        statusItem.menu = menu

        statusItem.button?.title = "\(progress.monthPercent)%"
        timer = Timer.scheduledTimer(withTimeInterval: updateIntervalSeconds, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func computeProgress() -> ProgressData {
        let calendar = Calendar.current
        let now = Date()

        let day = calendar.component(.day, from: now)
        guard let monthRange = calendar.range(of: .day, in: .month, for: now),
              let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now),
              let yearRange = calendar.range(of: .day, in: .year, for: now) else {
            return ProgressData(monthPercent: 0, monthDaysLeft: 0, monthName: "", yearPercent: 0, yearDaysLeft: 0, year: "")
        }
        let totalDaysInMonth = monthRange.count
        let monthPercent = Int(round(Double(day) / Double(totalDaysInMonth) * 100))

        monthFormatter.locale = languages[selectedLanguageIndex].locale
        let monthName = monthFormatter.monthSymbols[calendar.component(.month, from: now) - 1]

        let totalDaysInYear = yearRange.count
        let yearPercent = Int(round(Double(dayOfYear) / Double(totalDaysInYear) * 100))
        let year = calendar.component(.year, from: now)

        return ProgressData(
            monthPercent: monthPercent,
            monthDaysLeft: totalDaysInMonth - day,
            monthName: monthName,
            yearPercent: yearPercent,
            yearDaysLeft: totalDaysInYear - dayOfYear,
            year: String(year)
        )
    }

    @objc private func languageSelected(_ sender: NSMenuItem) {
        selectedLanguageIndex = sender.tag
        UserDefaults.standard.set(selectedLanguageIndex, forKey: Defaults.selectedLanguageKey)
        for item in languageMenuItems { item.state = .off }
        sender.state = .on
        updateProgress()
    }

    private func updateProgress() {
        let progress = computeProgress()
        let lang = languages[selectedLanguageIndex]

        statusItem.button?.title = "\(progress.monthPercent)%"
        updateLabel(monthPercentLabel, lang.monthFormat(progress.monthPercent))
        updateLabel(monthInfoLabel, lang.monthDaysFormat(progress.monthDaysLeft, progress.monthName))
        updateLabel(yearPercentLabel, lang.yearFormat(progress.yearPercent))
        updateLabel(yearDaysLabel, lang.yearDaysFormat(progress.yearDaysLeft, progress.year))
        languageMenuItem.title = lang.languageLabel
        quitMenuItem.title = lang.quitLabel
    }
}

// MARK: - Entry Point

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
