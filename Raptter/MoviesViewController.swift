//
//  MoviesViewController.swift
//  Raptter
//
//  Created by matsuosh on 2016/09/25.
//  Copyright © 2016年 matsuosh. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    var filePaths = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
            filePaths = contents.filter({ (filePath) -> Bool in
                return filePath.hasSuffix("mov")
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playMovie" {
            let controller = segue.destination as! MovieViewController
            controller.fileURLs = sender as! [URL]
        }
    }

}

extension MoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let fileURL = URL(string: filePaths[indexPath.row], relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
        //let fileURL = URL(fileURLWithPath: filePaths[indexPath.row])
        let fileURLs = filePaths[indexPath.row..<filePaths.count].map { (filePath) -> URL in
            URL(string: filePath, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))!
        }
        performSegue(withIdentifier: "playMovie", sender: fileURLs)
    }

    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

}

extension MoviesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filePaths.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieViewCell", for: indexPath) as! MovieViewCell
        let path = filePaths[indexPath.row]
        let fileURL = URL(fileURLWithPath: path.replacingOccurrences(of: "mov", with: "png"), relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
        cell.thumbnailView = UIImageView(image: UIImage(contentsOfFile: fileURL.path))
        return cell
        */
        let cell = UITableViewCell()
        cell.textLabel?.text = filePaths[indexPath.row]
        let path = filePaths[indexPath.row]
        let fileURL = URL(fileURLWithPath: path.replacingOccurrences(of: "mov", with: "png"), relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
        if FileManager.default.fileExists(atPath: fileURL.path) {
            cell.imageView?.image = UIImage(contentsOfFile: fileURL.path)
        }
        return cell
    }

}

class MovieViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailView: UIImageView!
}
