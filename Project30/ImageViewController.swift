import UIKit

class ImageViewController: UIViewController {
	weak var owner: SelectionViewController?
	var image: String?
	var animTimer: Timer?
	var imageView: UIImageView?

	override func loadView() {
		super.loadView()
		view.backgroundColor = UIColor.black

		// create an image view that fills the screen
		imageView = UIImageView()
		imageView?.contentMode = .scaleAspectFit
		imageView?.translatesAutoresizingMaskIntoConstraints = false
		imageView?.alpha = 0
        
        if let imageView = imageView {
            view.addSubview(imageView)
        }

		// make the image view fill the screen
		imageView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		imageView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		imageView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		imageView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

		// schedule an animation that does something vaguely interesting
		animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
			// do something exciting with our image
            self.imageView?.transform = CGAffineTransform.identity

			UIView.animate(withDuration: 3) {
                self.imageView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = image else { return }
        guard let imageView = imageView else { return }
        let path = getDocumentsDirectory().appendingPathComponent(image)
        guard let original = UIImage(contentsOfFile: path.path) else { return }
        
        
		imageView.image = original
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
        guard let imageView = imageView else { return }
        
        
		imageView.alpha = 0
		UIView.animate(withDuration: 3) { [unowned self] in
			self.imageView?.alpha = 1
		}
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let animTimer = animTimer else { return }
        
        
        animTimer.invalidate()
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let image = image else { return }
        
        
		let defaults = UserDefaults.standard
		var currentVal = defaults.integer(forKey: image)
		currentVal += 1

		defaults.set(currentVal, forKey:image)

		// tell the parent view controller that it should refresh its table counters when we go back
        owner?.dirty = true
	}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
