import UIKit


class ViewController: UIViewController, IntroViewDelegate {


    var introView: IntroViewController!
    var cameraView: CameraViewController!
    var tutorialView: TutorialViewController!
    var skyView: SkyViewController!
    var shareView: ShareViewController!
    
  override func viewDidLoad() {
     super.viewDidLoad()


     introView = IntroViewController()
     introView.delegate = self;
     introView.modalPresentationStyle = .overCurrentContext
     introView.modalTransitionStyle = .crossDissolve
     

     
  }
    
  override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
     
     present(introView, animated: true, completion: nil)
  }
    

}

