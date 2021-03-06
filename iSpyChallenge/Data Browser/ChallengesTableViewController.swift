//
//  ChallengesTableViewController.swift
//  iSpyChallenge
//
//

import UIKit
import CoreData

class ChallengesTableViewController: FetchedTableViewController, DataControllerInjectable, PhotoControllerInjectable, UserInjectable {
    
    var dataController: DataController!
    var photoController: PhotoController!
    var user: User?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Challenge> = {
        let fetchRequest: NSFetchRequest<Challenge> = Challenge.newFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "creator = %@", self.user!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hint", ascending: true)]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell", for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowChallenge", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Configure Table View Cell
    
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let challenge = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = challenge.hint
        cell.detailTextLabel?.text = String(format: "(%.5f, %.5f)", challenge.latitude, challenge.longitude)
        if let thumbnail = photoController.photo(withName: challenge.photoHref) {
            cell.imageView?.image = thumbnail
        } else {
            cell.imageView?.image = nil
        }
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        injectProperties(viewController: segue.destination)
    }
    
    // MARK: - Injection
    
    func injectProperties(viewController: UIViewController) {
        if let vc = viewController as? DataControllerInjectable {
            vc.dataController = self.dataController
        }
        
        if let vc = viewController as? PhotoControllerInjectable {
            vc.photoController = self.photoController
        }
        
        if let vc = viewController as? ChallengeInjectable {
            let challenge = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            vc.challenge = challenge
        }
    }

}
