//
//  Created by yehor on 26.04.25.
//

import SwiftUI

@main
struct ClothingApp: App {
    init() {
        UIImageTransformer.register()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
