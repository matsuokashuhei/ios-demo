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
            tableView.tableFooterView = UIView(frame: CGRect.zero)
        }
    }

    var filePaths = [String]()
    var removedFiles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filePaths = listMovieFiles()
        tableView.reloadData()
        setEditing(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func listMovieFiles() -> [String] {
        var files = [String]()
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
            files = contents.filter({ (filePath) -> Bool in
                return filePath.hasSuffix("mov")
            })
        }
        return files
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

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        if editing {
            navigationController?.navigationBar.topItem?.leftBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MoviesViewController.cancelEditing))
            navigationController?.navigationBar.topItem?.rightBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MoviesViewController.finishEditing))
        } else {
            navigationController?.navigationBar.topItem?.leftBarButtonItem = nil
            navigationController?.navigationBar.topItem?.rightBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(MoviesViewController.startEditing))
            
        }
    }

    func startEditing() {
        setEditing(true, animated: true)
        removedFiles = []
    }

    func finishEditing() {
        removedFiles.forEach { (removedFile) in
            try! FileManager.default.removeItem(at: URL(fileURLWithPath: removedFile, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)))
            let thumbnail = removedFile.replacingOccurrences(of: "mov", with: "png")
            try! FileManager.default.removeItem(at: URL(fileURLWithPath: thumbnail, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)))
        }
        setEditing(false, animated: true)
    }

    func cancelEditing() {
        removedFiles = []
        tableView.reloadData()
        setEditing(false, animated: true)
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

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        } else {
            return .none
        }
    }

    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removedFiles.append(filePaths[indexPath.row])
            filePaths.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
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
