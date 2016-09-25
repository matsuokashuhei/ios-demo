//
//  AudioPlayer.swift
//  Raptter
//
//  Created by matsuosh on 2016/09/25.
//  Copyright © 2016年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayer: NSObject {

    let player: AVPlayer

    override init() {
        player = AVPlayer()
    }

}
