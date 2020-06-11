import UIKit

import SVProgressHUD

class ViewController: UIViewController, IntroViewDelegate, CameraViewDelegate, TutorialViewDelegate, SkyViewDelegate, ShareViewDelegate {
     


     var sceneView: UIImageView!
    var introView: IntroViewController!
    var cameraView: CameraViewController!
    var tutorialView: TutorialViewController!
    var skyView: SkyViewController!
    var shareView: ShareViewController!
     
     var inputImage:UIImage!
     
     var initialGif:NSMutableDictionary!
     var imageLoadingView: UIImageView!
    
  override func viewDidLoad() {
     super.viewDidLoad()

     let screenWidth:CGFloat = view.frame.size.width
     let screenHeight:CGFloat = view.frame.size.height
     
     let screenSize: CGSize = UIScreen.main.bounds.size

     SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0))
     SVProgressHUD.setRingThickness(2)
     SVProgressHUD.setForegroundColor(.white)
     //self.view.backgroundColor = .red
     
     
     sceneView = UIImageView(frame: view.bounds)
     
     sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
     sceneView.contentMode = .scaleAspectFill
     sceneView.backgroundColor = .clear
     //self.view.addSubview(sceneView)
     
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
     
     let imageLoading:UIImage = UIImage(named:"cloud")!
     imageLoadingView = UIImageView(image:imageLoading)
     let rect:CGRect = CGRect(x:0, y:0, width:414/3, height:278/3)
      imageLoadingView.contentMode = .scaleAspectFill
     imageLoadingView.frame = rect;
     imageLoadingView.center = CGPoint(x:screenWidth/2, y:screenHeight/2-55)
     imageLoadingView.isHidden = true
     self.view.addSubview(imageLoadingView)
     initialGif = NSMutableDictionary()
     getPreset()
     

     self.setNeedsStatusBarAppearanceUpdate()


  }
    
override var prefersStatusBarHidden: Bool {
  return true
}
     
  override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)
     
     
     
     
  }
     
     private func initialize(img:UIImage,author:String){
          
          //sceneView.image = img
          present(introView, animated: true, completion: nil)
          introView.initialize(img: img,author:author)
     }
     
     private func setOffline(){
          //present(introView, animated: true, completion: nil)

          let imageDef:UIImage = UIImage(named:"defimage")!

          self.initialGif["url"] = nil
          self.initialGif["name"] = ""
          self.initialGif["author"] = ""
          self.initialGif["num"] = nil
               
          self.skyView.setInitial(obj: self.initialGif)
          
          present(introView, animated: true, completion: nil)
          introView.initialize(img: imageDef,author:"")
          /*
           let imageDef:UIImage = UIImage(named:"cloud")!
           imageLoadingView = UIImageView(image:imageLoading)
           let rect:CGRect = CGRect(x:0, y:0, width:414/3, height:278/3)
            imageLoadingView.contentMode = .scaleAspectFill
           imageLoadingView.frame = rect;
           imageLoadingView.center = CGPoint(x:screenWidth/2, y:screenHeight/2-55)
           imageLoadingView.isHidden = true
           self.view.addSubview(imageLoadingView)
           */
     }
     private func getPreset(){
          let randomInt = Int.random(in: 1..<1000000)
         let urlString = "http://origin.bassdrum.org/magicsky/def.json?ran="+String(randomInt)

         guard let url = URLComponents(string: urlString) else { return }
         // HTTPメソッドを実行
         let task = URLSession.shared.dataTask(with: url.url!) {(data, response, error) in
             if (error != nil) {
                 print(error!.localizedDescription)

               DispatchQueue.main.async {
                    self.setOffline()
               }
             }
             
             
             if let data = data {
                do {
                   let res = try JSONDecoder().decode(Gif.self, from: data)

/*
                 let randomInt = Int.random(in: 1..<self.gifList.data.count)
                 rgifNum = randomInt
                 self.setGif(id:self.gifList.data[randomInt].id)
 */
                 
                 let imgInt = Int.random(in: 0..<res.imgs.count)
                 let gifInt = Int.random(in: 0..<res.gifs.count)
                    
                    
                    
               self.initialGif["url"] = res.gifs[gifInt].url
               self.initialGif["name"] = res.gifs[gifInt].name
               self.initialGif["author"] = res.gifs[gifInt].author
               self.initialGif["num"] = gifInt
                    
                    var _dic = [NSMutableDictionary]()
                    

                    for count in 0...res.gifs.count-1 {
                         let _obj = NSMutableDictionary()
                         _obj["url"] = res.gifs[count].url
                         _obj["name"] = res.gifs[count].name
                         _obj["author"] = res.gifs[count].author
                         _dic.append(_obj)
                    }
                    
                    self.initialGif["dataset"] = _dic
                    
                    self.skyView.setInitial(obj: self.initialGif)
                 DispatchQueue.main.async {
                    
                    self.setImage(from: res.imgs[imgInt].url,author:res.imgs[imgInt].author)
                    //print(res.imgs.count)
                    //self.initialize(img:)
                    
                    //self.gifList.data[nextInt].id
                 }
                 
                } catch let error {
                   print(error)
                    self.setOffline()
                    
                }
             }
             
             

             
         }
         task.resume()
     }
    struct Gif: Codable {
        let imgs: [Imgs]
        let gifs: [Gifs]
        
        struct Imgs: Codable {
            let url: String
            let author: String
        }
        struct Gifs: Codable {
             let url: String
             let author: String
             let name: String
        }
    }
     func setImage(from url: String,author:String) {
          showHud()
         guard let imageURL = URL(string: url) else { return }

             // just not to cause a deadlock in UI!
         DispatchQueue.global().async {
             guard let imageData = try? Data(contentsOf: imageURL) else { return }

          let image = UIImage(data: imageData)!
             DispatchQueue.main.async {
               self.initialize(img: image,author:author)

               self.hideHud()
             }
         }
     }


       func showHud(){
           SVProgressHUD.show()
           imageLoadingView.isHidden = false
           imageLoadingView.alpha = 0
           
           UIView.animate(withDuration: 0.5, animations: {
                 self.imageLoadingView.alpha = 1
            }, completion: { (finished: Bool) in
            
            })
       
       }
     
       func hideHud(s:Int = 0){
           SVProgressHUD.dismiss()
           
           UIView.animate(withDuration: 0.5, delay:1,animations: {
                 self.imageLoadingView.alpha = 0
            }, completion: { (finished: Bool) in
               self.imageLoadingView.isHidden = true
            
            })
       }
     func goToTutorial() {
          dismiss(animated: true, completion:  {
               self.showTutorial()
          })
     }
     func showTutorial() {
          present(tutorialView, animated: true, completion: nil)
     }

     func goToCamera() {
          
          UserDefaults.standard.set(1, forKey: "num")
          dismiss(animated: true, completion:  {
               self.showCamera()
          })
     }
     func showCamera() {
          present(cameraView, animated: true, completion: nil)
          cameraView.showButton()
     }
     func goToSky() {
          
         
          
          
          dismiss(animated: false, completion:  {
              self.showSky()
          })
     }
     
     func showSkyAgain() {
          dismiss(animated: false, completion:  {
               self.present(self.skyView, animated: false, completion: nil)

          })
     }
     func showSky() {
          present(skyView, animated: false, completion: nil)

          self.skyView.clearView()
          //self.skyView.initializeDef()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
               self.skyView.startLoad()
               self.skyView.initialize(img: self.inputImage)
          }
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

