import UIKit


protocol TutorialViewDelegate:class {
}

class TutorialViewController: UIViewController {

    
    weak var  delegate:TutorialViewDelegate? = nil
    
  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    

    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    

}

