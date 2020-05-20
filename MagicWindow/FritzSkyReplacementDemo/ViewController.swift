import UIKit
import AVFoundation
import Fritz
import GiphyUISDK
import GiphyCoreSDK
import ImageIO
import MobileCoreServices
import Photos



class ViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!
    
    var _core:UIView!
    
  var sceneView: UIImageView!
  var backgroundView: UIImageView!
  var baseView: UIImageView!
    
    private var images = [CGImage]()
    
    
    var _currentGif:String!
    var _cnt: Int!
    
    var photoCameraButton: UIButton!
    
    
    var saveButton: UIButton!

    private var imagePicker = UIImagePickerController()
    
    var gifList:Gif!
    
  let context = CIContext()

  /// Scores output from model greater than this value will be set as 1.
  /// Lowering this value will make the mask more intense for lower confidence values.
  var clippingScoresAbove: Double { return 0.5 }

  /// Values lower than this value will not appear in the mask.

  var zeroingScoresBelow: Double { return 0.3 }

  /// Controls the opacity the mask is applied to the base image.
  var opacity: CGFloat { return 1.0 }

  private lazy var visionModel = FritzVisionSkySegmentationModelAccurate()

  let foreground = UIImage(named: "mountains.jpg")
  let background = UIImage(named: "clouds.png")

  var animationDuration = 12.0
    
    var gifButton: UIButton = {
        let button = UIButton()
        button.setImage(GPHIcons.giphyLogo(), for: .normal)
        return button
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    Giphy.configure(apiKey: "WTgeyO5XWRLFyRwo13hBRDiMhhP9HfvB", verificationMode: false)
    
    
    
    // Setup image picker.
    imagePicker.delegate = self
    imagePicker.sourceType = .photoLibrary

    
    let screenSize: CGSize = UIScreen.main.bounds.size
    

    _core = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-200))
    self.view.addSubview(_core)
    //backgroundView = initialBackground()
    backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-200))
    
    backgroundView.contentMode = .scaleAspectFill
    
    baseView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-200))
    
    baseView.contentMode = .scaleAspectFill
    //backgroundViewDelayed = initialBackground()

    sceneView = UIImageView(frame: view.bounds)
    
    sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-200)
    sceneView.contentMode = .scaleAspectFill
    sceneView.backgroundColor = .clear
    _core.addSubview(sceneView)
    
    
    _core.addSubview(backgroundView)
    //view.addSubview(backgroundViewDelayed)

    _core.bringSubviewToFront(sceneView)
    //startAnimation(on: backgroundView, delay: 0.0)
    //startAnimation(on: backgroundViewDelayed, delay: animationDuration / 2)
    
    // システムボタンを指定してボタンを作成
    photoCameraButton = UIButton()

    let screenWidth = view.frame.size.width
    let screenHeight = view.frame.size.height
    
    let img = UIImage(named:"camera.png")
    photoCameraButton.frame = CGRect(x:screenWidth/2-50, y:screenHeight-150,
                          width:100, height:100)
    photoCameraButton.setImage(img, for: .normal)
    photoCameraButton.imageView?.contentMode = .scaleAspectFit
    photoCameraButton.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(photoCameraButton)
    // Enable camera option only if current device has camera.
    let isCameraAvailable = UIImagePickerController.isCameraDeviceAvailable(.front)
      || UIImagePickerController.isCameraDeviceAvailable(.rear)
    if isCameraAvailable {
      photoCameraButton.isEnabled = true
    }
    
    saveButton = UIButton()
    
    let saveimg = UIImage(named:"save.png")
    saveButton.frame = CGRect(x:screenWidth/2+100, y:screenHeight-125,
                          width:50, height:50)
    saveButton.setImage(saveimg, for: .normal)
    saveButton.imageView?.contentMode = .scaleAspectFit
    saveButton.addTarget(self, action: #selector(saveGif(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(saveButton)
    //gifButton.translatesAutoresizingMaskIntoConstraints = false
    //gifButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
    //gifButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    
    gifButton.frame = CGRect(x:screenWidth/2-150, y:screenHeight-125,
                          width:50, height:50)

    gifButton.addTarget(self, action: #selector(gifButtonTapped), for: .touchUpInside)
    
    
    self.view.addSubview(gifButton)
    /*
    gifButton.leftAnchor.constraint(equalTo: textFieldContainer.leftAnchor, constant: 6).isActive = true
    gifButton.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor).isActive = true
    gifButton.addTarget(self, action: #selector(gifButtonTapped), for: .touchUpInside)
    textFieldLeftConstraint?.constant = gifButton.intrinsicContentSize.width + 15
    
    */
    
    /*
    _cnt = 0
    let data = try! Data(contentsOf: URL(string: "https://media.giphy.com/media/"+String(getGifId())+"/giphy.gif")!)
    backgroundView.animateGIF(data: data) {
        print("played")
    }
 */
    
    getGifList()
    
  }
    func getGifId() -> String{
        var gifs = ["S5nW5TQUi5SgNaJ7Vi","Qs1EbHPzBtBvRdECyg","qYr8p3Dzbet5S","x9a2PWuuoCtiw","bcm06VWT0iMQo"]
        gifs.shuffle()
        
        print(gifs)
        return gifs[0]
    }
    
    
    func repeatRender(){
        DispatchQueue.main.asyncAfter(deadline: .now() + self.backgroundView.animationDuration / Double(self.backgroundView.animationImages!.count)) {

            let _arr = self.backgroundView.animationImages
            let _uimage = _arr?[self._cnt]
            self.backgroundView.image = _uimage
            
            self._cnt += 1
            if(self._cnt == _arr?.count){
                self._cnt = 0
            }
            
            
            self.repeatRender()
        }
    }
    
    
 @objc func buttonEvent(_ sender : UIButton) {
     guard
       UIImagePickerController.isCameraDeviceAvailable(.front)
         || UIImagePickerController.isCameraDeviceAvailable(.rear)
     else {
       return
     }

     imagePicker.sourceType = .camera
     present(imagePicker, animated: true)
 }
    
    @objc func saveGif(_ sender : UIButton) {
        

        let _arr = self.backgroundView.animationImages
        
        let _uimage = _arr?[self._cnt]
        images.removeAll()
        self._cnt = 0
        for i in 0..._arr!.count-1 {
            
            let _uimage = _arr?[i]
            self.backgroundView.image = _uimage
                       
           self._cnt = i
           if(self._cnt == _arr?.count){
               self._cnt = 0
           }

            let rendImg = getImage(self._core)
            
            let _img = rendImg.cgImage
            images.append(_img!)
        }
        
        
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).gif")
        
        print(url?.absoluteURL)
        guard let destination = CGImageDestinationCreateWithURL(url as! CFURL, kUTTypeGIF, images.count, nil) else {
            print("CGImageDestinationの作成に失敗")
            return
        }
        

        let properties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        CGImageDestinationSetProperties(destination, properties as CFDictionary)
        
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: self.backgroundView.animationDuration / Double(self.backgroundView.animationImages!.count)]]
        for image in images {
            CGImageDestinationAddImage(destination, image, frameProperties as CFDictionary)
        }
        
        if CGImageDestinationFinalize(destination) {
            print("GIF生成が成功")
        } else {
            print("GIF生成に失敗")
        }
        

        let task = URLSession.shared.dataTask(with: url!, completionHandler: {data, response, error in
            let url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("tmp.gif")
            let _nd = data as! NSData
            _nd.write(to: url!, atomically: true)

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url!)
             }, completionHandler: nil)
         })
         task.resume()
    }
    
    
    @objc func gifButtonTapped() {
        let giphy = GiphyViewController()
        giphy.theme = GPHTheme(type: GPHThemeType.light)
        //giphy.theme = ExampleTheme()
        giphy.mediaTypeConfig = GPHContentType.defaultSetting
        GiphyViewController.trayHeightMultiplier = 0.7
        giphy.layout = GPHGridLayout.defaultSetting
        giphy.showConfirmationScreen = false
        giphy.shouldLocalizeSearch = true
        giphy.delegate = self
        giphy.dimBackground = true
        giphy.showCheckeredBackground = true
        giphy.modalPresentationStyle = .overCurrentContext
        present(giphy, animated: true, completion: nil)
    }
    
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    


  func initialBackground() -> UIImageView {
    let shiftedLeft = CGRect(origin: CGPoint(x: -view.bounds.width, y: view.bounds.minY),
                             size: view.bounds.size)
    let view = UIImageView(frame: shiftedLeft)
    view.contentMode = .scaleAspectFill
    view.image = background
    return view
  }

  func createSticker(_ timage: UIImage) {

    guard let image = timage.transformOrientationToUp() else {
      return
    }

    let fritzImage = FritzVisionImage(image: image)
    guard let result = try? visionModel.predict(fritzImage),
      let mask = result.buildSingleClassMask(
        forClass: FritzVisionSkyClass.none,
        clippingScoresAbove: clippingScoresAbove,
        zeroingScoresBelow: zeroingScoresBelow
      )
      else { return }
    
    baseView.backgroundColor = .white
    baseView.image = mask
    
    
    baseView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    
    
    let maskImg = getImage(self.baseView)
    
    

    
    let maskRef = maskImg.cgImage
    let maskInner = CGImage(maskWidth: maskRef!.width,
                            height: maskRef!.height,
                            bitsPerComponent: maskRef!.bitsPerComponent,
    bitsPerPixel: maskRef!.bitsPerPixel,
    bytesPerRow: maskRef!.bytesPerRow,
    provider: maskRef!.dataProvider!,
    decode: nil,
    shouldInterpolate: false)!
    
    let ref = image.cgImage
    let output = ref!.masking(maskInner)
    let outputImage = UIImage(cgImage: output!)
        
        //var _uimage = segmentationResult?.resultImage
    self.sceneView.image = outputImage
    
    
    /*
    _cnt = 0
    let data = try! Data(contentsOf: URL(string: "https://media.giphy.com/media/"+_currentGif+"/giphy.gif")!)
    backgroundView.animateGIF(data: data) {
        print("played")
    }
 */

    //self.imageView.image = mask
    //guard let skyRemoved = createMask(of: image, fromMask: mask) else { return }

    /*
    DispatchQueue.main.async {
      self.imageView.image = skyRemoved
    }
 */
  }
    func setGif(id: String){
        _cnt = 0
        let data = try! Data(contentsOf: URL(string: "https://media.giphy.com/media/"+id+"/giphy.gif")!)
        backgroundView.animateGIF(data: data) {
            print("played")
        }
        _currentGif = id
    }
    
    func getImage(_ view : UIView) -> UIImage {
        
        // キャプチャする範囲を取得する
        let rect = view.bounds
        
        // ビットマップ画像のcontextを作成する
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        
        // view内の描画をcontextに複写する
        view.layer.render(in: context)
        
        // contextのビットマップをUIImageとして取得する
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // contextを閉じる
        UIGraphicsEndImageContext()
        
        return image
    }

    func renderFirstView(){
        
        
        
        let randomInt = Int.random(in: 1..<self.gifList.data.count)
        self.setGif(id:self.gifList.data[randomInt].id)
        

        repeatRender()
        
        self.createSticker(self.foreground!)

        _core.bringSubviewToFront(sceneView)
    }
    private func getGifList(){

        let urlString = "http://api.giphy.com/v1/gifs/trending?api_key=WTgeyO5XWRLFyRwo13hBRDiMhhP9HfvB&limit=20"

        guard let url = URLComponents(string: urlString) else { return }

        // HTTPメソッドを実行
        let task = URLSession.shared.dataTask(with: url.url!) {(data, response, error) in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            
            
            if let data = data {
               do {
                  let res = try JSONDecoder().decode(Gif.self, from: data)

                self.gifList = res
                // 結果をコンソールに表示
                /*
                for item in res.data {
                  print("id:\(item.id) name:\(item.type)")
                }
 */
                
                self.renderFirstView()
                
               } catch let error {
                  print(error)
               }
            }
            
            
            
            //self.createSticker(self.foreground!)
            /*
            let users = try! JSONDecoder().decode([User].self, from: _data)
            for row in users {
                print("id:\(row.id) name:\(row.name) remarks:\(row.remarks)")
            }
 */
            
        }
        task.resume()
    }
    
    struct Gif: Codable {
        let meta: Meta
        let data: [Item]
        
        struct Meta: Codable {
            let msg: String
            let response_id: String
        }
        struct Item: Codable {
            let id: String
            let type: String
        }
    }
}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {

    if let pickedImage = info[.originalImage] as? UIImage {
      //runSegmentation(pickedImage)
        createSticker(pickedImage)
    }

    dismiss(animated: true)
  }
}


extension ViewController: GiphyDelegate {
    func didSearch(for term: String) {
        print("your user made a search! ", term)
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        giphyViewController.dismiss(animated: true, completion: { [weak self] in
            self!.setGif(id:media.id)
            /*
            self?.addMessageToConversation(text: nil, media: media)
            guard self?.conversation.count ?? 0 > 7 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                let response = self.conversationResponses[self.currentConversationResponse % self.conversationResponses.count]
                self.currentConversationResponse += 1
                self.addMessageToConversation(text: response, user: .abraHam)
            }
 */
        })
        GPHCache.shared.clear(.memoryOnly)
    }
    
    func didDismiss(controller: GiphyViewController?) {
        GPHCache.shared.clear(.memoryOnly)
    }
}
