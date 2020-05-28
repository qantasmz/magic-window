import UIKit


protocol SkyViewDelegate:class {
}


class SkyViewController: UIViewController {

    
    weak var  delegate:SkyViewDelegate? = nil
    
    
  override func viewDidLoad() {
    super.viewDidLoad()

    
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    

}

