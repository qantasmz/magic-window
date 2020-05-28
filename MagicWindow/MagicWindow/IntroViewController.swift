import UIKit


protocol IntroViewDelegate:class {
}

class IntroViewController: UIViewController {
    
    weak var  delegate:IntroViewDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

}

