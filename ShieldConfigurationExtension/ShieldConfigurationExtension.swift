//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Genki on 1/30/24.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import SwiftUI

private let imageName = "shieldIcon"
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            icon: UIImage(named: imageName),
            title: ShieldConfiguration.Label(text: String(localized: "Stay Focused"), color: .label),
            primaryButtonLabel: ShieldConfiguration.Label(text: String(localized: "OK"), color: .white),
            primaryButtonBackgroundColor: UIColor(Color("gptPurple"))
        )
    }
    override func configuration(
        shielding application: Application,
        in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration()
    }
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }
}
