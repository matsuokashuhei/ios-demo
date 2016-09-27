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
            tableView.allowsMultipleSelection = true
        }
    }

    @IBOutlet weak var toolbar: UIToolbar!

    var movieFiles = [String]()
    var selectedMovies = [String]()
    var removedFiles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movieFiles = listMovieFiles()
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
        selectedMovies.removeAll()
        toolbar.items?.removeAll(keepingCapacity: true)
        if editing {
            let cancel = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(MoviesViewController.cancelEditing))
            let space1  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let play = UIBarButtonItem(
                barButtonSystemItem: .play,
                target: self,
                action: #selector(MoviesViewController.playMovies))
            let space2  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(MoviesViewController.finishEditing))
            toolbar.setItems([cancel, space1, play, space2, done], animated: true)
        } else {
            let edit = UIBarButtonItem(
                barButtonSystemItem: .edit,
                target: self,
                action: #selector(MoviesViewController.startEditing))
            let space1  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let play = UIBarButtonItem(
                barButtonSystemItem: .play,
                target: self,
                action: #selector(MoviesViewController.playMovies))
            let space2  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let action = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(MoviesViewController.actionButtonTapped))
            toolbar.setItems([edit, space1, play, space2, action], animated: true)
        }
    }

    func playMovies() {
        guard selectedMovies.count > 0 else {
            return
        }
        let fileURLs = selectedMovies.map { (filePath) -> URL in
            URL(string: filePath, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))!
        }
        performSegue(withIdentifier: "playMovie", sender: fileURLs)

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
        setEditing(false, animated: true)
        tableView.reloadData()
    }

    func actionButtonTapped() {
        let fileURLs = selectedMovies.map { (filePath) -> URL in
            URL(string: filePath, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))!
        }
        let controller = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
}

extension MoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let fileURLs = filePaths[indexPath.row..<filePaths.count].map { (filePath) -> URL in
            URL(string: filePath, relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))!
        }
        performSegue(withIdentifier: "playMovie", sender: fileURLs)
        */
        if tableView.isEditing {
            return
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        selectedMovies.append(movieFiles[indexPath.row])
        print(selectedMovies.joined(separator: ","))
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        selectedMovies.remove(at: selectedMovies.index(of: movieFiles[indexPath.row])!)
        print(selectedMovies.joined(separator: ","))
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
            removedFiles.append(movieFiles[indexPath.row])
            movieFiles.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
}

extension MoviesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieFiles.count
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
        cell.textLabel?.text = movieFiles[indexPath.row]
        let path = movieFiles[indexPath.row]
        let fileURL = URL(
            fileURLWithPath: path.replacingOccurrences(of: "mov", with: "png"),
            relativeTo: URL(fileURLWithPath: NSTemporaryDirectory()))
        if FileManager.default.fileExists(atPath: fileURL.path) {
            cell.imageView?.image = UIImage(contentsOfFile: fileURL.path)
        }
        return cell
    }

}
