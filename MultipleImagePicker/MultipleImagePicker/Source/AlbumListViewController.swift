//
//  AlbumListViewController.swift
//  MultipleImagePicker
//
//  Created by ALEXANDER on 3/18/19.
//  Copyright © 2019 ALEXANDER. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AlbumListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	let tableView = UITableView()
	
	var items: Array<Array<PHFetchResult<PHAsset>>> = []
	var names: Array<Array<String>> = []
	
    var albumControllerTitle: String?
	var doneButtonTitle: String?
    var userAlbumsTitle: String?

	let imageSize = CGSize(width: 100.0, height: 100.0)
	
	let headerReuseIdentifier = String(describing: UITableViewHeaderFooterView.self)
	
	var picker: PickerController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Photos"
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didClickCancelButton(sender:)))
		view.addSubview(tableView)
		tableView.delegate = self
		tableView.dataSource = self
        tableView.pinToSuperview()
        tableView.tableFooterView = UIView()
		AlbumTableViewCell.register(tableView: tableView)
		tableView.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
		loadItems()
	}

	
	
	func loadItems() {
		let sortByCreationDateOptions = PHFetchOptions()
		sortByCreationDateOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		
		let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
		var assetsArray: Array<PHFetchResult<PHAsset>> = []
		var namesArray: Array<String> = []
		for counter in 0..<smartAlbums.count {
			let collection = smartAlbums[counter]
			let assets = PHAsset.fetchAssets(in: collection, options: sortByCreationDateOptions)
			if assets.count > 0 {
				if let title = collection.localizedTitle {
					namesArray.append(title)
				} else {
					namesArray.append("Unnamed album")
				}
				assetsArray.append(assets)
			}
		}
		items.append(assetsArray)
		names.append(namesArray)
		assetsArray = []
		namesArray = []

		let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
		let count = userCollections.count
		
		for number in 0..<count {
			let collection = userCollections[number]
			if collection.canContainAssets {
				let assetCollection = collection as! PHAssetCollection
				let assets = PHAsset.fetchAssets(in: assetCollection, options: sortByCreationDateOptions)
				if assets.count > 0 {
					if let title = collection.localizedTitle {
						namesArray.append(title)
					} else {
						namesArray.append("Unnamed album")
					}
					assetsArray.append(assets)
				}
			}
		}
		items.append(assetsArray)
		names.append(namesArray)
	}
    

	// MARK: - UITableViewDataSource methods
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items[section].count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = AlbumTableViewCell.dequeue(tableView: tableView)
		let row = indexPath.row
		let section = indexPath.section
		cell.titleLabel.text = names[section][row]
		let assets = items[section][row]
		cell.countLabel.text = String(assets.count)
		let viewCount = min(assets.count, 3)
		for counter in 0..<viewCount {
			PHImageManager.default().requestImage(for: assets[counter], targetSize: cell.previewView.sizeForViewAt(number: counter), contentMode: .aspectFill, options: nil) { (image, _) -> Void in
				if image != nil {
					cell.previewView.set(image: image!, forViewAt: counter)
				}
			}
		}
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 && items[section].count > 0 {
			return userAlbumsTitle
		}
		return nil
	}
	
    // MARK: UITableViewDelegate methods
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectController = SelectViewController()
		let row = indexPath.row
		let section = indexPath.section
		selectController.items = items[section][row]
        selectController.title = names[section][row]
		if doneButtonTitle != nil {
			selectController.navigationItem.rightBarButtonItem?.title = doneButtonTitle
		}
		selectController.picker = picker
		self.navigationController?.pushViewController(selectController, animated: true)
	}
    
    // MARK: Buttons
	
	@objc func didClickCancelButton(sender: UIBarButtonItem) {
        if picker != nil {
            self.picker?.delegate?.imagePickerControllerDidCancel(picker!)
            picker!.dismiss(animated: true, completion: nil)
        }
	}
}
