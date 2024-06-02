import Cocoa
import SwiftUI

@main
struct BinaryBrewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// Empty view as we don't want to display any UI
struct EmptyView: View {
    var body: some View {
        Text("") // Empty text, nothing to show
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var caffeinateProcess: Process?
    var statusItem: NSStatusItem?
    var caffeinateTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(named: "icon_cup2")
            button.image?.isTemplate = true
        }
        
        // Construct the menu for the status item
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Caffeinate on/off", action: #selector(toggleCaffeinate), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        let durations = [15, 30, 60]
        for duration in durations {
            let menuItem = NSMenuItem(title: "\(duration) Minutes", action: #selector(startCaffeinateForFixedTime(_:)), keyEquivalent: "")
            menuItem.tag = duration
            menu.addItem(menuItem)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func toggleCaffeinate() {
        if caffeinateProcess != nil {
            stopCaffeinate()
        } else {
            startCaffeinateIndefinitely()
        }
    }

    @objc func startCaffeinateForFixedTime(_ sender: NSMenuItem) {
        let time = sender.tag * 60
        caffeinateTimer?.invalidate()
        startCaffeinate(time: time)
        updateIconForTime(time: sender.tag)
    }

    func startCaffeinateIndefinitely() {
        startCaffeinate(time: nil)
        if let button = statusItem?.button {
            button.image = NSImage(named: "icon_cup")
            button.image?.isTemplate = true
        }
    }

    func startCaffeinate(time: Int?) {
        stopCaffeinate()
        let process = Process()
        process.launchPath = "/usr/bin/caffeinate"
        process.arguments = time != nil ? ["-d", "-t", "\(time!)"] : ["-d"]
        do {
            try process.run()
            caffeinateProcess = process
        } catch {
            print("Failed to start caffeinate: \(error)")
        }
        if let time = time {
            caffeinateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(time), target: self, selector: #selector(stopCaffeinate), userInfo: nil, repeats: false)
        }
    }

    @objc func stopCaffeinate() {
        caffeinateProcess?.terminate()
        caffeinateProcess = nil
        caffeinateTimer?.invalidate()
        caffeinateTimer = nil
        if let button = statusItem?.button {
            button.image = NSImage(named: "icon_cup2")
            button.image?.isTemplate = true
        }
    }

    func updateIconForTime(time: Int) {
        let iconName = "icon_cup\(time)"
        if let button = statusItem?.button, let image = NSImage(named: iconName) {
            button.image = image
            button.image?.isTemplate = true
        } else {
            print("Failed to load image for icon: \(iconName)")
        }
    }
}
