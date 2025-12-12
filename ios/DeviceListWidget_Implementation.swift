//
//  DeviceListWidget.swift
//  DeviceListWidget
//
//  CREATED BY ANTIGRAVITY AGENT
//  INSTRUCTIONS:
//  1. In Xcode, go to File > New > Target...
//  2. Choose "Widget Extension".
//  3. Name it "DeviceListWidget".
//  4. Uncheck "Include Configuration App Intent" (we will create our own).
//  5. Replace the contents of the created DeviceListWidget.swift with this file.
//  6. In "Signing & Capabilities", add "App Groups" to both the Runner and the Extension.
//  7. Use the same group ID (e.g. group.com.metehan.yetanotherwol).
//  8. Update kAppGroupId in lib/src/features/widget/widget_service.dart with your group ID.
//

import WidgetKit
import SwiftUI
import AppIntents
import Network

// MARK: - Data Models
struct Device: Codable, Identifiable {
    let id: String
    let alias: String
    let mac: String
    let port: Int?
}

struct DeviceListEntry: TimelineEntry {
    let date: Date
    let devices: [Device]
}

// MARK: - UDP WoL Sender
class WoLSender {
    static func wake(mac: String, port: Int) {
        let host = NWEndpoint.Host("255.255.255.255")
        let port = NWEndpoint.Port(rawValue: UInt16(port))!
        let connection = NWConnection(host: host, port: port, using: .udp)
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                let payload = createMagicPacket(mac: mac)
                connection.send(content: payload, completion: .contentProcessed { error in
                    connection.cancel()
                })
            case .failed(_):
                connection.cancel()
            default:
                break
            }
        }
        connection.start(queue: .global())
    }
    
    private static func createMagicPacket(mac: String) -> Data {
        var packet = Data(count: 102)
        
        // 6 bytes of FF
        for _ in 0..<6 {
            packet.append(0xFF)
        }
        
        // 16 repetitions of MAC
        let macBytes = mac.split(separator: ":").compactMap { UInt8($0, radix: 16) }
        guard macBytes.count == 6 else { return Data() }
        
        for _ in 0..<16 {
            packet.append(contentsOf: macBytes)
        }
        
        return packet
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    // ADJUST THIS TO YOUR APP GROUP ID
    let appGroupId = "group.com.metehan.yet_another_wol" 

    func placeholder(in context: Context) -> DeviceListEntry {
        DeviceListEntry(date: Date(), devices: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (DeviceListEntry) -> ()) {
        completion(DeviceListEntry(date: Date(), devices: fetchDevices()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DeviceListEntry>) -> ()) {
        completion(Timeline(entries: [DeviceListEntry(date: Date(), devices: fetchDevices())], policy: .never))
    }
    
    func fetchDevices() -> [Device] {
        if let userDefaults = UserDefaults(suiteName: appGroupId),
           let jsonString = userDefaults.string(forKey: "devices_data"),
           let data = jsonString.data(using: .utf8) {
            do {
                return try JSONDecoder().decode([Device].self, from: data)
            } catch {
                print("Error decoding devices: \(error)")
            }
        }
        return []
    }
}

// MARK: - App Intent (iOS 17+)
@available(iOS 16.0, *)
struct WakeDeviceIntent: AppIntent {
    static var title: LocalizedStringResource = "Wake Device"
    
    @Parameter(title: "MAC Address")
    var mac: String
    
    @Parameter(title: "Port")
    var port: Int
    
    init() {}
    init(mac: String, port: Int) {
        self.mac = mac
        self.port = port
    }

    func perform() async throws -> some IntentResult {
        WoLSender.wake(mac: mac, port: port)
        return .result()
    }
}

// MARK: - Widget View
struct DeviceListWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Devices")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.bottom, 2)
            
            if entry.devices.isEmpty {
                Spacer()
                Text("No devices.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                // Adaptive layout based on family
                if family == .systemSmall {
                    // Compact List: Max 3-4 items, No MAC, No Dividers
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(entry.devices.prefix(4)) { device in
                            HStack {
                                Text(device.alias)
                                    .font(.system(size: 13, weight: .medium))
                                    .lineLimit(1)
                                Spacer()
                                WakeButton(device: device)
                            }
                        }
                        if entry.devices.count > 4 {
                             Spacer()
                             Link(destination: URL(string: "wol://open")!) {
                                 Text("+\(entry.devices.count - 4) more")
                                     .font(.system(size: 9))
                                     .foregroundColor(.secondary)
                             }
                        } else {
                            Spacer()
                        }
                    }
                } else {
                    // Medium: 2 Columns grid if possible, or just list with MAC
                    // Simple approach for now: List with MAC
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(entry.devices.prefix(4)) { device in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(device.alias)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(device.mac)
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                WakeButton(device: device)
                            }
                            .padding(.vertical, 2)
                            Divider()
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(12)
    }
}

struct WakeButton: View {
    let device: Device
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Button(intent: WakeDeviceIntent(mac: device.mac, port: device.port ?? 9)) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        } else {
            Image(systemName: "bolt")
        }
    }
}

@main
struct DeviceListWidget: Widget {
    let kind: String = "DeviceListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DeviceListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WoL Devices")
        .description("Wake up your devices directly from the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
