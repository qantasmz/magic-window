import UIKit


protocol SkyViewDelegate:class {
}


class SkyViewController: UIViewController {

    
    weak var  delegate:SkyViewDelegate? = nil
    
    
  override func viewDidLoad() {
    super.viewDidLoad()

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    
    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    

}

