import UIKit
import AVFoundation
import Fritz
import GiphyUISDK
import GiphyCoreSDK
import ImageIO
import MobileCoreServices
import Photos

import SVGKit
import SVProgressHUD


class ViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!
    
    var _core:UIView!
    
  var sceneView: UIImageView!
  var backgroundView: UIImageView!
  var baseView: UIImageView!
    
    private var images = [CGImage]()
    
    var saveArr = [UIImage]()
    var _currentGif:String!
    var _cnt: Int!
    var _saveCnt: Int = 0
    var _calcLock:Int = 0
    
    var photoCameraButton: UIButton!
    
    
    var albumButton: UIButton!
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
    
    
    

    
    var svgImageView: UIImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
    let svgImage = SVGKImage(named: "camera-sharp")
    svgImage?.size = svgImageView.bounds.size
    svgImageView.image = svgImage?.uiImage
    
    photoCameraButton.frame = CGRect(x:screenWidth/2-37.5, y:screenHeight-137.5,
                          width:75, height:75)
    
    
    photoCameraButton.addSubview(svgImageView)
    //photoCameraButton.setImage(svgImage, for: .normal)
    photoCameraButton.imageView?.contentMode = .scaleAspectFit
    photoCameraButton.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(photoCameraButton)
    // Enable camera option only if current device has camera.
    let isCameraAvailable = UIImagePickerController.isCameraDeviceAvailable(.front)
      || UIImagePickerController.isCameraDeviceAvailable(.rear)
    if isCameraAvailable {
      photoCameraButton.isEnabled = true
    }
    

    albumButton = UIButton()
    albumButton.frame = CGRect(x:screenWidth/2+67, y:screenHeight-114,
                          width:32, height:32)
    var albumImageView: UIImageView = UIImageView()
    albumImageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
    let albumImage = SVGKImage(named: "image-sharp")
    albumImage?.size = albumImageView.bounds.size
    albumImageView.image = albumImage?.uiImage
    albumButton.addSubview(albumImageView)
    albumButton.imageView?.contentMode = .scaleAspectFit
    albumButton.addTarget(self, action: #selector(openAlbum(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(albumButton)


    saveButton = UIButton()
    saveButton.frame = CGRect(x:screenWidth/2+127, y:screenHeight-118,
                          width:36, height:36)
    var saveImageView: UIImageView = UIImageView()
    saveImageView.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
    let saveImage = SVGKImage(named: "download-sharp")
    saveImage?.size = saveImageView.bounds.size
    saveImageView.image = saveImage?.uiImage
    saveButton.addSubview(saveImageView)
    saveButton.imageView?.contentMode = .scaleAspectFit
    saveButton.addTarget(self, action: #selector(saveGif(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(saveButton)
    //gifButton.translatesAutoresizingMaskIntoConstraints = false
    //gifButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
    //gifButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    
    gifButton.frame = CGRect(x:screenWidth/2-140, y:screenHeight-118,
                          width:36, height:36)

    gifButton.addTarget(self, action: #selector(gifButtonTapped), for: .touchUpInside)
    
    
    self.view.addSubview(gifButton)
    /*
    gifButton.leftAnchor.constraint(equalTo: textFieldContainer.leftAnchor, constant: 6).isActive = true
    gifButton.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor).isActive = true
    gifButton.addTarget(self, action: #selector(gifButtonTapped), for: .touchUpInside)
    textFieldLeftConstraint?.constant = gifButton.intrinsicContentSize.width + 15
    
    */
    
    
    getGifList()
    

    SVProgressHUD.show()
    
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
    
       
    @objc func openAlbum(_ sender : UIButton) {


        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
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
    func showHud(){
        SVProgressHUD.show()
    }
  
    func hideHud(){
        SVProgressHUD.dismiss()
    }
    
    func renderSaving(){
        SVProgressHUD.showProgress(Float(Float(self._saveCnt)/Float(self.saveArr.count)))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if( self._saveCnt < self.saveArr.count){
                

                let _uimage = self.saveArr[ self._saveCnt]
                 self.backgroundView.image = _uimage
                            

                 let rendImg = self.getImage(self._core)
                 
                 let _img = rendImg.cgImage
                 self.images.append(_img!)
                self._saveCnt += 1
                 self.renderSaving()
            }else{
                
                
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).gif")
                
                print(url?.absoluteURL)
                guard let destination = CGImageDestinationCreateWithURL(url as! CFURL, kUTTypeGIF, self.images.count, nil) else {
                    print("CGImageDestinationの作成に失敗")
                    return
                }
                

                let properties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
                CGImageDestinationSetProperties(destination, properties as CFDictionary)
                
                let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: self.backgroundView.animationDuration / Double(self.backgroundView.animationImages!.count)]]
                for image in self.images {
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
                     }, completionHandler:  { success, error in
                        if !success { NSLog("error creating asset: \(error)") }else{

                            self.hideHud()
                        }
                    })
                    

                 })
                 task.resume()
            }
        }
    }
    
    
    @objc func saveGif(_ sender : UIButton) {
        
        
        self.showHud()
        
        _saveCnt = 0

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.saveArr = self.backgroundView.animationImages!
            
            self.images.removeAll()
            self.renderSaving()
        }
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
    
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self._calcLock = 0
    }
    

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
        

        SVProgressHUD.dismiss()
 
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
                
                DispatchQueue.main.async {
                   self.renderFirstView()
                }
                
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
    
    dismiss(animated: true)
    if let pickedImage = info[.originalImage] as? UIImage {
      //runSegmentation(pickedImage)
        
        if(_calcLock == 0){

            _calcLock = 1
            createSticker(pickedImage)
        }
    }

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
