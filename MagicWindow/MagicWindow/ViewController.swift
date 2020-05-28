import UIKit


class ViewController: UIViewController, IntroViewDelegate, CameraViewDelegate, TutorialViewDelegate, SkyViewDelegate, ShareViewDelegate {
     


    var introView: IntroViewController!
    var cameraView: CameraViewController!
    var tutorialView: TutorialViewController!
    var skyView: SkyViewController!
    var shareView: ShareViewController!
     
     var inputImage:UIImage!
    
  override func viewDidLoad() {
     super.viewDidLoad()


     introView = IntroViewController()
     introView.delegate = self;
     introView.modalPresentationStyle = .overCurrentContext
     introView.modalTransitionStyle = .crossDissolve
     
     cameraView = CameraViewController()
     cameraView.delegate = self;
     cameraView.modalPresentationStyle = .overCurrentContext
     cameraView.modalTransitionStyle = .crossDissolve
     
     
     tutorialView = TutorialViewController()
     tutorialView.delegate = self;
     tutorialView.modalPresentationStyle = .overCurrentContext
     tutorialView.modalTransitionStyle = .crossDissolve
     
     
     skyView = SkyViewController()
     skyView.delegate = self;
     skyView.modalPresentationStyle = .overCurrentContext
     skyView.modalTransitionStyle = .crossDissolve
     
     
     shareView = ShareViewController()
     shareView.delegate = self;
     shareView.modalPresentationStyle = .overCurrentContext
     shareView.modalTransitionStyle = .crossDissolve
     

     
  }
    
  override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
     
     present(introView, animated: true, completion: nil)
  }
    
     func goToCamera() {
          dismiss(animated: true, completion:  {
               self.showCamera()
          })
     }
     func showCamera() {
          present(cameraView, animated: true, completion: nil)
     }
     func goToSky() {
          dismiss(animated: true, completion:  {
               self.showSky()
          })
     }
     func showSky() {
          present(skyView, animated: true, completion: nil)
          skyView.initialize(img: inputImage)
     }
     
     func backToCamera(){
          dismiss(animated: true, completion:  {
               self.showCamera()
          })
          
     }
     
     
     func goToShare() {
          dismiss(animated: true, completion:  {
               self.showShare()
          })
     }
     
     
     func showShare() {
          present(shareView, animated: true, completion: nil)
     }
     
     func setInputImage(img:UIImage){
          inputImage = img
     }
     
     
     
     
     
     
     
     
     
     

}

