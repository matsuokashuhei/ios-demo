//
//  MovieViewController.swift
//  Raptter
//
//  Created by matsuosh on 2016/09/25.
//  Copyright © 2016年 matsuosh. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MovieViewController: UIViewController {

    //let playerViewController = AVPlayerViewController()
    //var player: AVPlayer!
    //var fileURL: URL!
    var fileURLs: [URL]!

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        playerViewController.player = AVQueuePlayer()
        //playerViewController.player = AVPlayer(url: fileURL)
        playerViewController.view.frame = view.frame
        addChildViewController(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.player?.play()
        */

        
        let controller: AVPlayerViewController = {
            let controller = AVPlayerViewController()
            let items = fileURLs.map({ (fileURL) -> AVPlayerItem in
                AVPlayerItem(url: fileURL)
            })
            controller.player = AVQueuePlayer(items: items)
            return controller
        }()
        controller.view.frame = view.frame
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.player?.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
