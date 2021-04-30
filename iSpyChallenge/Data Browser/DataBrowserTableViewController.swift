//
//  DataBrowserTableViewController.swift
//  iSpyChallenge
//

import UIKit
import CoreData

class DataBrowserTableViewController: UITableViewController, DataControllerInjectable {
    
    var dataController: DataController!

    private lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.newFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.mainQueueManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print(error)
        }
    }

    // MARK: - UITableViewDataSource & UITableViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }
    
    // MARK: - Configure Table View Cell
    
    private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let user = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.email
        if let thumbnailURL = URL(string: user.avatarThumbnailHref), let data = (try? Data(contentsOf: thumbnailURL)) ?? nil {
            cell.imageView?.image = UIImage(data: data)
        } else {
            cell.imageView?.image = nil
        }
    }
}

extension DataBrowserTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [newIndexPath], with: .automatic)
            }
            
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configure(cell, at: indexPath)
            }
            
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
