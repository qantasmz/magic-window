import UIKit


protocol TutorialViewDelegate:class {
}

class TutorialViewController: UIViewController {

    
    weak var  delegate:TutorialViewDelegate? = nil
    
  override func viewDidLoad() {
    super.viewDidLoad()

    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    

}

