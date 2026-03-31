import AppKit

struct Language {
    let name: String
    let locale: Locale
    let monthFormat: (Int) -> String
    let monthRemainingFormat: (String, String) -> String
    let yearFormat: (Int) -> String
    let yearRemainingFormat: (String, String) -> String
    let languageLabel: String
    let launchAtLoginLabel: String
    let quitLabel: String
}

let languages: [Language] = [
    Language(name: "English", locale: Locale(identifier: "en"),
             monthFormat: { "Month: \($0)%" },
             monthRemainingFormat: { "\($0) left in \($1)" },
             yearFormat: { "Year: \($0)%" },
             yearRemainingFormat: { "\($0) left in \($1)" },
             languageLabel: "Language", launchAtLoginLabel: "Launch at Login", quitLabel: "Quit"),
    Language(name: "Italiano", locale: Locale(identifier: "it"),
             monthFormat: { "Mese: \($0)%" },
             monthRemainingFormat: { "Mancano \($0) alla fine di \($1)" },
             yearFormat: { "Anno: \($0)%" },
             yearRemainingFormat: { "Mancano \($0) alla fine del \($1)" },
             languageLabel: "Lingua", launchAtLoginLabel: "Avvia al login", quitLabel: "Esci"),
    Language(name: "Español", locale: Locale(identifier: "es"),
             monthFormat: { "Mes: \($0)%" },
             monthRemainingFormat: { "Quedan \($0) de \($1)" },
             yearFormat: { "Año: \($0)%" },
             yearRemainingFormat: { "Quedan \($0) de \($1)" },
             languageLabel: "Idioma", launchAtLoginLabel: "Abrir al iniciar sesión", quitLabel: "Salir"),
    Language(name: "Français", locale: Locale(identifier: "fr"),
             monthFormat: { "Mois : \($0) %" },
             monthRemainingFormat: { "Il reste \($0) en \($1)" },
             yearFormat: { "Année : \($0) %" },
             yearRemainingFormat: { "Il reste \($0) en \($1)" },
             languageLabel: "Langue", launchAtLoginLabel: "Ouvrir à la connexion", quitLabel: "Quitter"),
    Language(name: "Português", locale: Locale(identifier: "pt"),
             monthFormat: { "Mês: \($0)%" },
             monthRemainingFormat: { "Faltam \($0) para o fim de \($1)" },
             yearFormat: { "Ano: \($0)%" },
             yearRemainingFormat: { "Faltam \($0) para o fim de \($1)" },
             languageLabel: "Idioma", launchAtLoginLabel: "Abrir ao iniciar sessão", quitLabel: "Sair"),
    Language(name: "Deutsch", locale: Locale(identifier: "de"),
             monthFormat: { "Monat: \($0) %" },
             monthRemainingFormat: { "Noch \($0) im \($1)" },
             yearFormat: { "Jahr: \($0) %" },
             yearRemainingFormat: { "Noch \($0) in \($1)" },
             languageLabel: "Sprache", launchAtLoginLabel: "Beim Anmelden öffnen", quitLabel: "Beenden"),
    Language(name: "简体中文", locale: Locale(identifier: "zh-Hans"),
             monthFormat: { "月进度: \($0)%" },
             monthRemainingFormat: { "\($1)还剩\($0)" },
             yearFormat: { "年进度: \($0)%" },
             yearRemainingFormat: { "\($1)年还剩\($0)" },
             languageLabel: "语言", launchAtLoginLabel: "登录时打开", quitLabel: "退出"),
    Language(name: "繁體中文", locale: Locale(identifier: "zh-Hant"),
             monthFormat: { "月進度: \($0)%" },
             monthRemainingFormat: { "\($1)還剩\($0)" },
             yearFormat: { "年進度: \($0)%" },
             yearRemainingFormat: { "\($1)年還剩\($0)" },
             languageLabel: "語言", launchAtLoginLabel: "登入時打開", quitLabel: "結束"),
    Language(name: "日本語", locale: Locale(identifier: "ja"),
             monthFormat: { "今月: \($0)%" },
             monthRemainingFormat: { "\($1)はあと\($0)" },
             yearFormat: { "今年: \($0)%" },
             yearRemainingFormat: { "\($1)年はあと\($0)" },
             languageLabel: "言語", launchAtLoginLabel: "ログイン時に開く", quitLabel: "終了"),
    Language(name: "한국어", locale: Locale(identifier: "ko"),
             monthFormat: { "이번 달: \($0)%" },
             monthRemainingFormat: { "\($1) \($0) 남음" },
             yearFormat: { "올해: \($0)%" },
             yearRemainingFormat: { "\($1)년 \($0) 남음" },
             languageLabel: "언어", launchAtLoginLabel: "로그인 시 열기", quitLabel: "종료"),
]

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var monthPercentLabel: NSTextField!
    private var monthInfoLabel: NSTextField!
    private var yearPercentLabel: NSTextField!
    private var yearDaysLabel: NSTextField!
    private var languageMenuItems: [NSMenuItem] = []
    private var languageMenuItem: NSMenuItem!
    private var launchAtLoginMenuItem: NSMenuItem!
    private var quitMenuItem: NSMenuItem!
    private var timer: Timer?

    private let launchAgentLabel = "com.newmonthsresolution.launcher"
    private var launchAgentPath: String {
        NSHomeDirectory() + "/Library/LaunchAgents/\(launchAgentLabel).plist"
    }

    private var isLaunchAtLoginEnabled: Bool {
        FileManager.default.fileExists(atPath: launchAgentPath)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        if enabled {
            let appPath = Bundle.main.bundlePath
            let plist: [String: Any] = [
                "Label": launchAgentLabel,
                "ProgramArguments": ["/usr/bin/open", appPath],
                "RunAtLoad": true
            ]
            let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            FileManager.default.createFile(atPath: launchAgentPath, contents: data)
        } else {
            try? FileManager.default.removeItem(atPath: launchAgentPath)
        }
    }
    private var selectedLanguageIndex: Int = {
        let saved = UserDefaults.standard.integer(forKey: "selectedLanguageIndex")
        return saved < languages.count ? saved : 0
    }()

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

        let (monthPercent, monthRemaining, monthName, yearPercent, yearRemaining, year) = computeProgress()
        let lang = languages[selectedLanguageIndex]

        let menu = NSMenu()
        var item: NSMenuItem

        (item, monthPercentLabel) = makeInfoItem(lang.monthFormat(monthPercent))
        menu.addItem(item)
        (item, monthInfoLabel) = makeInfoItem(lang.monthRemainingFormat(monthRemaining, monthName))
        menu.addItem(item)
        menu.addItem(NSMenuItem.separator())
        (item, yearPercentLabel) = makeInfoItem(lang.yearFormat(yearPercent))
        menu.addItem(item)
        (item, yearDaysLabel) = makeInfoItem(lang.yearRemainingFormat(yearRemaining, year))
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

        launchAtLoginMenuItem = NSMenuItem(title: lang.launchAtLoginLabel, action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginMenuItem.target = self
        launchAtLoginMenuItem.state = isLaunchAtLoginEnabled ? .on : .off
        menu.addItem(launchAtLoginMenuItem)

        menu.addItem(NSMenuItem.separator())
        quitMenuItem = NSMenuItem(title: lang.quitLabel, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitMenuItem)
        statusItem.menu = menu

        statusItem.button?.title = "\(monthPercent)%"
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProgress()
        }

        NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func computeProgress() -> (Int, String, String, Int, String, String) {
        let calendar = Calendar.current
        let now = Date()

        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: now)
        let hourFraction = Double(hour) / 24.0
        guard let monthRange = calendar.range(of: .day, in: .month, for: now),
              let dayOfYear = calendar.ordinality(of: .day, in: .year, for: now),
              let yearRange = calendar.range(of: .day, in: .year, for: now) else {
            return (0, "", "", 0, "", "")
        }
        let totalDaysInMonth = monthRange.count
        let monthPercent = Int(round((Double(day - 1) + hourFraction) / Double(totalDaysInMonth) * 100))

        let dateFormatter = DateFormatter()
        dateFormatter.locale = languages[selectedLanguageIndex].locale
        let monthName = dateFormatter.monthSymbols[calendar.component(.month, from: now) - 1]

        let totalDaysInYear = yearRange.count
        let yearPercent = Int(round((Double(dayOfYear - 1) + hourFraction) / Double(totalDaysInYear) * 100))
        let year = calendar.component(.year, from: now)

        let locale = languages[selectedLanguageIndex].locale
        let monthDaysLeft = totalDaysInMonth - day
        let yearDaysLeft = totalDaysInYear - dayOfYear

        let timeFormatter = DateComponentsFormatter()
        timeFormatter.unitsStyle = .full
        timeFormatter.calendar = { var c = Calendar.current; c.locale = locale; return c }()

        let monthRemaining: String
        if monthDaysLeft == 0 {
            timeFormatter.allowedUnits = [.hour]
            var components = DateComponents()
            components.hour = max(24 - hour, 1)
            monthRemaining = timeFormatter.string(from: components) ?? ""
        } else {
            timeFormatter.allowedUnits = [.day]
            var components = DateComponents()
            components.day = monthDaysLeft
            monthRemaining = timeFormatter.string(from: components) ?? ""
        }

        let yearRemaining: String
        if yearDaysLeft == 0 {
            timeFormatter.allowedUnits = [.hour]
            var components = DateComponents()
            components.hour = max(24 - hour, 1)
            yearRemaining = timeFormatter.string(from: components) ?? ""
        } else {
            timeFormatter.allowedUnits = [.day]
            var components = DateComponents()
            components.day = yearDaysLeft
            yearRemaining = timeFormatter.string(from: components) ?? ""
        }

        return (monthPercent, monthRemaining, monthName, yearPercent, yearRemaining, String(year))
    }

    @objc private func toggleLaunchAtLogin() {
        let newState = !isLaunchAtLoginEnabled
        setLaunchAtLogin(newState)
        launchAtLoginMenuItem.state = newState ? .on : .off
    }

    @objc private func languageSelected(_ sender: NSMenuItem) {
        selectedLanguageIndex = sender.tag
        UserDefaults.standard.set(selectedLanguageIndex, forKey: "selectedLanguageIndex")
        for item in languageMenuItems { item.state = .off }
        sender.state = .on
        updateProgress()
    }

    private func updateProgress() {
        let (monthPercent, monthRemaining, monthName, yearPercent, yearRemaining, year) = computeProgress()
        let lang = languages[selectedLanguageIndex]

        statusItem.button?.title = "\(monthPercent)%"
        updateLabel(monthPercentLabel, lang.monthFormat(monthPercent))
        updateLabel(monthInfoLabel, lang.monthRemainingFormat(monthRemaining, monthName))
        updateLabel(yearPercentLabel, lang.yearFormat(yearPercent))
        updateLabel(yearDaysLabel, lang.yearRemainingFormat(yearRemaining, year))
        languageMenuItem.title = lang.languageLabel
        launchAtLoginMenuItem.title = lang.launchAtLoginLabel
        quitMenuItem.title = lang.quitLabel
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
