import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
    var optimizedImages = [String]()
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

		// load all the JPEGs into our array
		let fm = FileManager.default
        if let bundlePath = Bundle.main.resourcePath {
            if let tempItems = try? fm.contentsOfDirectory(atPath: bundlePath) {
                for item in tempItems {
                    if item.range(of: "Large") != nil {
                        items.append(item)
                    }
                }
            }
        }
        loadImages()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return optimizedImages.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
//        if cell == nil {
//            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
//        }
//        guard let cell = cell else { fatalError("TableViewCell was nil") }
        
        let currentImage = optimizedImages[indexPath.row % optimizedImages.count]
        let path = getDocumentsDirectory().appendingPathComponent(currentImage)
        if let originalImage = UIImage(contentsOfFile: path.path) {
            let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
            let renderer = UIGraphicsImageRenderer(size: renderRect.size)
            let rounded = renderer.image { ctx in
                ctx.cgContext.addEllipse(in: renderRect)
                ctx.cgContext.clip()

                originalImage.draw(in: renderRect)
            }
            cell.imageView?.image = rounded
        }

		// give the images a nice shadow to make them look a bit more dramatic
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 90, height: 90))).cgPath

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = optimizedImages[indexPath.row % optimizedImages.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false
        
		navigationController?.pushViewController(vc, animated: true)
	}
    
    func loadImages() {
        for item in items {
            if let path = Bundle.main.path(forResource: item, ofType: nil) {
                if let originalImage = UIImage(contentsOfFile: path) {
                    let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
                    let renderer = UIGraphicsImageRenderer(size: renderRect.size)
                    let rounded = renderer.image { ctx in
                        originalImage.draw(in: renderRect)
                    }
                    let imageName = UUID().uuidString
                    let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
                    optimizedImages.append(imageName)
                    
                    if let jpegData = rounded.jpegData(compressionQuality: 0.8) {
                        try? jpegData.write(to: imagePath)
                    }
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
