//
//  GCDBlackbox.swift
//  onthemap
//
//  Created by Erick Medina on 8/9/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
