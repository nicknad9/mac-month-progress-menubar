import AppKit

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
    private var selectedLanguageIndex = 0

    private func makeInfoItem(_ text: String) -> (NSMenuItem, NSTextField) {
        let label = NSTextField(labelWithString: text)
        label.font = NSFont.menuFont(ofSize: 0)
        label.textColor = .labelColor
        label.sizeToFit()

        let container = NSView(frame: NSRect(
            x: 0, y: 0,
            width: label.frame.width + 28,
            height: label.frame.height + 8
        ))
        label.frame.origin = NSPoint(x: 14, y: 4)
        container.addSubview(label)

        let item = NSMenuItem()
        item.view = container
        return (item, label)
    }

    private func updateLabel(_ label: NSTextField, _ text: String) {
        label.stringValue = text
        label.sizeToFit()
        label.superview?.frame.size = NSSize(
            width: label.frame.width + 28,
            height: label.frame.height + 8
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let (monthPercent, monthDaysLeft, monthName, yearPercent, yearDaysLeft, year) = computeProgress()
        let lang = languages[selectedLanguageIndex]

        let menu = NSMenu()
        var item: NSMenuItem

        (item, monthPercentLabel) = makeInfoItem(lang.monthFormat(monthPercent))
        menu.addItem(item)
        (item, monthInfoLabel) = makeInfoItem(lang.monthDaysFormat(monthDaysLeft, monthName))
        menu.addItem(item)
        menu.addItem(NSMenuItem.separator())
        (item, yearPercentLabel) = makeInfoItem(lang.yearFormat(yearPercent))
        menu.addItem(item)
        (item, yearDaysLabel) = makeInfoItem(lang.yearDaysFormat(yearDaysLeft, year))
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

        statusItem.button?.title = "\(monthPercent)%"
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func computeProgress() -> (Int, Int, String, Int, Int, String) {
        let calendar = Calendar.current
        let now = Date()

        let day = calendar.component(.day, from: now)
        let totalDaysInMonth = calendar.range(of: .day, in: .month, for: now)!.count
        let monthPercent = Int(round(Double(day) / Double(totalDaysInMonth) * 100))

        let formatter = DateFormatter()
        formatter.locale = languages[selectedLanguageIndex].locale
        let monthName = formatter.monthSymbols[calendar.component(.month, from: now) - 1]

        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now)!
        let totalDaysInYear = calendar.range(of: .day, in: .year, for: now)!.count
        let yearPercent = Int(round(Double(dayOfYear) / Double(totalDaysInYear) * 100))
        let year = calendar.component(.year, from: now)

        return (monthPercent, totalDaysInMonth - day, monthName, yearPercent, totalDaysInYear - dayOfYear, String(year))
    }

    @objc private func languageSelected(_ sender: NSMenuItem) {
        selectedLanguageIndex = sender.tag
        for item in languageMenuItems { item.state = .off }
        sender.state = .on
        updateProgress()
    }

    private func updateProgress() {
        let (monthPercent, monthDaysLeft, monthName, yearPercent, yearDaysLeft, year) = computeProgress()
        let lang = languages[selectedLanguageIndex]

        statusItem.button?.title = "\(monthPercent)%"
        updateLabel(monthPercentLabel, lang.monthFormat(monthPercent))
        updateLabel(monthInfoLabel, lang.monthDaysFormat(monthDaysLeft, monthName))
        updateLabel(yearPercentLabel, lang.yearFormat(yearPercent))
        updateLabel(yearDaysLabel, lang.yearDaysFormat(yearDaysLeft, year))
        languageMenuItem.title = lang.languageLabel
        quitMenuItem.title = lang.quitLabel
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
