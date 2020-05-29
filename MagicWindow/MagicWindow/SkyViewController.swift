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


protocol SkyViewDelegate:class {

    func goToShare()
    func backToCamera()
}

class SkyViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    
    
    weak var  delegate:SkyViewDelegate? = nil
    
    var captureSession = AVCaptureSession()
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var photoOutput : AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?

    var videoOutput: AVCaptureVideoDataOutput!
    
  var imageView: UIImageView!
    
    
    var inputImage:UIImage!
    
    
    var _core:UIView!
    
  var sceneView: UIImageView!
  var backgroundView: UIImageView!

    var movieView: UIImageView!
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


    
    var gifButton: UIButton = {
        let button = UIButton()
        button.setImage(GPHIcons.giphyLogo(), for: .normal)
        return button
    }()
    
    
    var skyUI:UIView!
    var shareUI:UIView!
    var toggleUI:UIView!
    
    var _uiStat:Int!
    var _saveStat:Int!

    
    private var imagePicker = UIImagePickerController()
    var videoURL:  NSURL?
    var rgifNum:Int!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    

    Giphy.configure(apiKey: "WTgeyO5XWRLFyRwo13hBRDiMhhP9HfvB", verificationMode: false)
    
    
    
    
    let screenSize: CGSize = UIScreen.main.bounds.size
    

    _core = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    self.view.addSubview(_core)
    backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    
    backgroundView.contentMode = .scaleAspectFill
    
    movieView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    
    movieView.contentMode = .scaleAspectFill
    
    baseView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    
    baseView.contentMode = .scaleAspectFill

    sceneView = UIImageView(frame: view.bounds)
    
    sceneView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
    sceneView.contentMode = .scaleAspectFill
    sceneView.backgroundColor = .clear
    _core.addSubview(sceneView)
    
    
    _core.addSubview(backgroundView)
    _core.addSubview(movieView)

    _core.bringSubviewToFront(sceneView)
    
    // システムボタンを指定してボタンを作成
    
    photoCameraButton = UIButton()

    
    var svgImageView: UIImageView = UIImageView()
    svgImageView.frame = CGRect(x: 9, y: 9, width: 32, height: 32)
    let svgImage = SVGKImage(named: "arrow-back-circle-sharp")
    svgImage?.size = svgImageView.bounds.size
    svgImageView.image = svgImage?.uiImage
    
    photoCameraButton.frame = CGRect(x:screenWidth-75, y:50,width:50, height:50)
    
    let phBase = UIView()
    phBase.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    phBase.layer.cornerRadius = 25
    phBase.backgroundColor = .white
    phBase.isUserInteractionEnabled = false
    photoCameraButton.addSubview(phBase)
    
    photoCameraButton.addSubview(svgImageView)
    photoCameraButton.imageView?.contentMode = .scaleAspectFit
    photoCameraButton.addTarget(self, action: #selector(tapCamera(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(photoCameraButton)

  
   
    toggleUI = UIView(frame: CGRect(x: 0, y: screenHeight/2-25, width: screenSize.width, height: 50))
    
    let leftButton = UIButton()

    
    var leftImageView: UIImageView = UIImageView()
    leftImageView.frame = CGRect(x: 9, y: 9, width: 32, height: 32)
    let leftImage = SVGKImage(named: "arrow-back")
    leftImage?.size = leftImageView.bounds.size
    leftImageView.image = leftImage?.uiImage
    
    leftButton.frame = CGRect(x:20, y:0,width:50, height:50)
    
    let leftBase = UIView()
    leftBase.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    leftBase.layer.cornerRadius = 25
    leftBase.backgroundColor = .white
    leftBase.isUserInteractionEnabled = false
    leftButton.addSubview(leftBase)
    
    leftButton.addSubview(leftImageView)
    leftButton.imageView?.contentMode = .scaleAspectFit
    leftButton.addTarget(self, action: #selector(tapLeft(_:)), for: UIControl.Event.touchUpInside)
    toggleUI.addSubview(leftButton)
    
    
    
    let rightButton = UIButton()

    
    var rightImageView: UIImageView = UIImageView()
    rightImageView.frame = CGRect(x: 9, y: 9, width: 32, height: 32)
    let rightImage = SVGKImage(named: "arrow-forward")
    rightImage?.size = rightImageView.bounds.size
    rightImageView.image = rightImage?.uiImage
    
    rightButton.frame = CGRect(x:screenWidth-70, y:0,width:50, height:50)
    
    let rightBase = UIView()
    rightBase.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    rightBase.layer.cornerRadius = 25
    rightBase.backgroundColor = .white
    rightBase.isUserInteractionEnabled = false
    rightButton.addSubview(rightBase)
    
    rightButton.addSubview(rightImageView)
    rightButton.imageView?.contentMode = .scaleAspectFit
    rightButton.addTarget(self, action: #selector(tapRight(_:)), for: UIControl.Event.touchUpInside)
    toggleUI.addSubview(rightButton)

    self.view.addSubview(toggleUI)
    
    
    
    skyUI = UIView(frame: CGRect(x: 0, y: screenHeight - 170, width: screenSize.width, height: 170))
    
    let _gifBt = UIButton()
    
    _gifBt.setTitle("giphy", for: [])
    _gifBt.setTitleColor(UIColor.white, for: [])
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _gifBt.backgroundColor = .black
    _gifBt.layer.cornerRadius = 24
    _gifBt.frame = CGRect(x:screenWidth/2-180-10, y:0, width:180, height:48)
    _gifBt.addTarget(self, action: #selector(self.gifButtonTapped), for: .touchUpInside)
    skyUI.addSubview(_gifBt)
    
    
    let _impBt = UIButton()
    
    _impBt.setTitle("import", for: [])
    _impBt.setTitleColor(UIColor.white, for: [])
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _impBt.backgroundColor = .black
    _impBt.layer.cornerRadius = 24
    _impBt.frame = CGRect(x:screenWidth/2+10, y:0, width:180, height:48)
    _impBt.addTarget(self, action: #selector(self.importButtonTapped), for: .touchUpInside)
    skyUI.addSubview(_impBt)
    
    
    let _decBt = UIButton()
    
    _decBt.setTitle("Let's go", for: [])
    _decBt.setTitleColor(UIColor.white, for: [])
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _decBt.backgroundColor = .black
    _decBt.layer.cornerRadius = 24
    _decBt.frame = CGRect(x:(screenWidth-280)/2, y:70, width:280, height:48)
    _decBt.addTarget(self, action: #selector(self.gotoShare), for: .touchUpInside)
    skyUI.addSubview(_decBt)
    
    
    self.view.addSubview(skyUI)
    
    
    
    
    shareUI = UIView(frame: CGRect(x: 0, y: screenHeight - 170, width: screenSize.width, height: 170))
    
    let _saveGifBt = UIButton()
    
    _saveGifBt.setTitle("save gif", for: [])
    _saveGifBt.setTitleColor(UIColor.white, for: [])
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _saveGifBt.backgroundColor = .black
    _saveGifBt.layer.cornerRadius = 24
    _saveGifBt.frame = CGRect(x:screenWidth/2-180-10, y:70, width:180, height:48)
    _saveGifBt.addTarget(self, action: #selector(self.saveGif), for: .touchUpInside)
    shareUI.addSubview(_saveGifBt)
    
    
    let _saveVideoBt = UIButton()
    
    _saveVideoBt.setTitle("save video", for: [])
    _saveVideoBt.setTitleColor(UIColor.white, for: [])
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _saveVideoBt.backgroundColor = .black
    _saveVideoBt.layer.cornerRadius = 24
    _saveVideoBt.frame = CGRect(x:screenWidth/2+10, y:70, width:180, height:48)
    _saveVideoBt.addTarget(self, action: #selector(self.saveVideo), for: .touchUpInside)
    shareUI.addSubview(_saveVideoBt)
    
    
    let _shareVideoBt = UIButton()
    
    _shareVideoBt.setTitle("share video", for: [])
    _shareVideoBt.setTitleColor(UIColor.white, for: [])
    //_decBt.titleLabel?.font = UIFont (name: "HiraginoSans-W6", size: 15)
    _shareVideoBt.backgroundColor = .black
    _shareVideoBt.layer.cornerRadius = 24
    _shareVideoBt.frame = CGRect(x:(screenWidth-280)/2, y:0, width:280, height:48)
    _shareVideoBt.addTarget(self, action: #selector(self.shareVideo), for: .touchUpInside)
    shareUI.addSubview(_shareVideoBt)
    
    
    self.view.addSubview(shareUI)
    
/*
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
*/

    
    /*
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
 */
    /*
    gifButton.frame = CGRect(x:screenWidth/2-140, y:screenHeight-118,
                          width:36, height:36)

    gifButton.addTarget(self, action: #selector(gifButtonTapped), for: .touchUpInside)
    
    
    self.view.addSubview(gifButton)
    
    */
    
    
    


    
    
  }
    
    public func initialize(img:UIImage){
        _uiStat = 0
        inputImage = img
        sceneView.alpha = 0
        backgroundView.alpha = 0
        toggleUI.isHidden = false
        shareUI.isHidden = true
        skyUI.isHidden = false
        SVProgressHUD.show()
        getGifList()
        
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
                if(self._saveStat == 0){
                    self.saveGifData()
                }else if(self._saveStat == 1 || self._saveStat == 2) {
                    
                    self.saveVideoData()
                }
                
            }
        }
        
        
      
        

        //self.hideHud()
    }
    
    func saveVideoData(){
        //保存先のURL
        //self.backgroundView.animationDuration / Double(self.backgroundView.animationImages!.count)
        //let time = self.backgroundView.animationDuration
        
        let time = 1
        
  
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        let rate:CGFloat = screenHeight/screenWidth
        
        let _wid:CGFloat = 1280
        let _hgt:CGFloat = _wid * rate
        
        var size:CGSize = CGSize(width:_wid,height:_hgt)
        
        let url = NSURL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).mp4")
        // AVAssetWriter
        guard let videoWriter = try? AVAssetWriter(outputURL: url!, fileType: AVFileType.mov) else {
            fatalError("AVAssetWriter error")
        }
        
        let width = size.width
        let height = size.height
        
        // AVAssetWriterInput
        let outputSettings = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
            ] as [String : Any]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings as [String : AnyObject])
        videoWriter.add(writerInput)
        
        // AVAssetWriterInputPixelBufferAdaptor
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                ]
        )
        
        writerInput.expectsMediaDataInRealTime = true
        
        
        if (!videoWriter.startWriting()) {
            // error
            print("error videoWriter startWriting")
        }
        
        // 動画生成開始
        videoWriter.startSession(atSourceTime: CMTime.zero)
        
        // pixel bufferを宣言
        var buffer: CVPixelBuffer? = nil
        
        // 現在のフレームカウント
        var frameCount = 0
        
        // 各画像の表示する時間
        let durationForEachImage = time
        
        // FPS
        
        let fps:__int32_t = __int32_t(1/(self.backgroundView.animationDuration / Double(self.backgroundView.animationImages!.count)))
       
        var _psec:Float64 = 0
        
        while _psec < 13 {

            for image in self.images {
                
                if (!adaptor.assetWriterInput.isReadyForMoreMediaData) {
                    break
                }
                
                // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
                let frameTime: CMTime = CMTimeMake(value: Int64(__int32_t(frameCount) * __int32_t(durationForEachImage)), timescale: fps)
                //時間経過を確認(確認用)
                let second = CMTimeGetSeconds(frameTime)
                _psec = second
                print(_psec)
                
                let resize = resizeImage(image: UIImage(cgImage: image), contentSize: size)
                // CGImageからBufferを生成
                buffer = self.pixelBufferFromCGImage(cgImage: resize.cgImage!)
                
                // 生成したBufferを追加
                if (!adaptor.append(buffer!, withPresentationTime: frameTime)) {
                    // Error!
                    print("adaptError")
                    print(videoWriter.error!)
                }
                
                frameCount += 1
            }
        }
        
        // 動画生成終了
        writerInput.markAsFinished()
        videoWriter.endSession(atSourceTime: CMTimeMake(value: Int64((__int32_t(frameCount)) *  __int32_t(durationForEachImage)), timescale: fps))
        videoWriter.finishWriting(completionHandler: {
            // Finish!
            print("movie created.")
            
/*
            let task = URLSession.shared.dataTask(with: url!, completionHandler: {data, response, error in
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("tmp.mp4")
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
 */
            
            if(self._saveStat == 1 ) {
             DispatchQueue.main.async {
                self.hideHud()
                let text = "Magic Window"
                let items = [text,url] as [Any]//動画のパスを渡す


                // UIActivityViewControllerインスタンス化
                let activityVc = UIActivityViewController(activityItems: items, applicationActivities: nil)

                // UIAcitivityViewController表示
                self.present(activityVc, animated: true, completion: nil)
                //url
             }
            }else if(self._saveStat == 2 ){
                
                let task = URLSession.shared.dataTask(with: url!, completionHandler: {data, response, error in
                   let url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("tmp.mp4")
                   let _nd = data as! NSData
                   _nd.write(to: url!, atomically: true)
             
                   PHPhotoLibrary.shared().performChanges({
                                         PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url!)
                                      }, completionHandler:  { success, error in
                                         if !success { NSLog("error creating asset: \(error)") }else{

                                             self.hideHud()
                                             
                                            
                                         }
                                     })

                })
                task.resume()
                /*
                let task = URLSession.shared.dataTask(with: url!, completionHandler: {data, response, error in
                   let url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("tmp.mp4")
                   let _nd = data as! NSData
                   _nd.write(to: url!, atomically: true)

                   PHPhotoLibrary.shared().performChanges({
                       PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url!)
                    }, completionHandler:  { success, error in
                       if !success { NSLog("error creating asset: \(error)") }else{

                           self.hideHud()
                           
                          
                       }
                   })
                   

                })
                task.resume()
 */
            }

        })
        
    }
    
    func pixelBufferFromCGImage(cgImage: CGImage) -> CVPixelBuffer {
        
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pxBuffer: CVPixelBuffer? = nil
        
        let width = cgImage.width
        let height = cgImage.height
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32ARGB,
                            options as CFDictionary?,
                            &pxBuffer)
        
        CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pxdata = CVPixelBufferGetBaseAddress(pxBuffer!)
        
        let bitsPerComponent: size_t = 8
        let bytesPerRow: size_t = 4 * width
        
        let rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(cgImage, in: CGRect(x:0, y:0, width:CGFloat(width),height:CGFloat(height)))
        
        CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pxBuffer!
    }
    
    private func resizeImage(image:UIImage,contentSize:CGSize) -> UIImage{
        // リサイズ処理
        let origWidth  = Int(image.size.width)
        let origHeight = Int(image.size.height)
        var resizeWidth:Int = 0, resizeHeight:Int = 0
        if (origWidth < origHeight) {
            resizeWidth = Int(contentSize.width)
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = Int(contentSize.height)
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSize(width:CGFloat(resizeWidth), height:CGFloat(resizeHeight))
        UIGraphicsBeginImageContext(resizeSize)
        
        image.draw(in: CGRect(x:0,y: 0,width: CGFloat(resizeWidth), height:CGFloat(resizeHeight)))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return resizeImage!
    }
    
    
    func saveGifData(){

        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).gif")
        
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

    @objc func tapLeft(_ sender : UIButton){
        
        var nextInt = rgifNum - 1
        if(nextInt == -1){
            nextInt = self.gifList.data.count-1
        }
        rgifNum = nextInt
        self.setGif(id:self.gifList.data[nextInt].id)
    }
    
    
    @objc func tapRight(_ sender : UIButton){
        
        var nextInt = rgifNum + 1
        if(nextInt == self.gifList.data.count){
            nextInt = 0
        }
        rgifNum = nextInt
        self.setGif(id:self.gifList.data[nextInt].id)
    }

    @objc func gotoShare(_ sender : UIButton){
        
        _uiStat = 1
        skyUI.isHidden = true
        toggleUI.isHidden = true
        UIView.transition(with: self.view, duration: 0.5, options: [.transitionCurlUp], animations: nil, completion: { _ in
            // replace camera preview with new one
            self.shareUI.isHidden = false
        })
        
    }
    @objc func tapCamera(_ sender : UIButton){
        if(_uiStat == 0){
            delegate!.backToCamera()
        }else{
            _uiStat = 0
            shareUI.isHidden = true
            UIView.transition(with: self.view, duration: 0.5, options: [.transitionCurlDown], animations: nil, completion: { _ in
                // replace camera preview with new one
                self.skyUI.isHidden = false
                self.toggleUI.isHidden = false
            })
        }
    }
    
    
    @objc func saveGif(_ sender : UIButton) {
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.showHud()
                    
                    self._saveCnt = 0

                    self._saveStat = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.saveArr = self.backgroundView.animationImages!
                        
                        self.images.removeAll()
                        self.renderSaving()
                    }
                } else if status == .denied {
                    let title: String = "Failed to save image"
                    let message: String = "Allow this app to access Photos."
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                            return
                        }
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    })
                    let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                    alert.addAction(settingsAction)
                    alert.addAction(closeAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.showHud()
            
            _saveCnt = 0

            _saveStat = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.saveArr = self.backgroundView.animationImages!
                
                self.images.removeAll()
                self.renderSaving()
            }
        }
    }
    
    
    @objc func saveVideo(_ sender : UIButton) {
        
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.showHud()
                    
                    self._saveCnt = 0

                    
                    self._saveStat = 2
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.saveArr = self.backgroundView.animationImages!
                        
                        self.images.removeAll()
                        self.renderSaving()
                    }
                } else if status == .denied {
                    let title: String = "Failed to save image"
                    let message: String = "Allow this app to access Photos."
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                            return
                        }
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    })
                    let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                    alert.addAction(settingsAction)
                    alert.addAction(closeAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.showHud()
            
            _saveCnt = 0

            
            _saveStat = 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.saveArr = self.backgroundView.animationImages!
                
                self.images.removeAll()
                self.renderSaving()
            }
        }
    }
    
    @objc func shareVideo(_ sender : UIButton) {
        
        
        self.showHud()
        
        _saveCnt = 0

        
        _saveStat = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.saveArr = self.backgroundView.animationImages!
            
            self.images.removeAll()
            self.renderSaving()
        }
    }
    
    @objc func importButtonTapped() {
        
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.movie"] // 動画のみ表示
        present(imagePicker, animated: true, completion: nil)
    }
    
    
   func imagePickerController(
     _ picker: UIImagePickerController,
     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
   ) {

    if let url = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
        


        //print(url.absoluteString)
        
        
        let asset = AVAsset(url: url as URL)
        var seconds = float_t(asset.duration.value) / float_t(asset.duration.timescale)
        if(seconds > 5){
            seconds = 5
        }
        var totalNum = Int(seconds*10)
        
        print(totalNum)
        var images: [UIImage] = []
        for count in 0...totalNum {
            let capturingTimeWithSeconds: Float64 = Float64(Double(count)*0.1)
            print(capturingTimeWithSeconds)
            let capturingTime: CMTime = CMTimeMakeWithSeconds(capturingTimeWithSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
            
            let _nimg:UIImage = thumbnail(sourceURL: url,time:capturingTime)
            //self.movieView.image = _nimg
            images.append(_nimg)
        }

        backgroundView.replaceImg(images: images,duration:seconds) {
            print("played")
        }
        print(self.backgroundView.animationDuration / Double(self.backgroundView.animationImages!.count))
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    

    
    /*
     if let pickedImage = info[.originalImage] as? UIImage {


         delegate?.setInputImage(img: pickedImage)
         delegate?.goToSky()

     }
 */

   }
    
    func thumbnail(sourceURL sourceURL:NSURL,time:CMTime) -> UIImage {
        let asset = AVAsset(url: sourceURL as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero;
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero;
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            var _uiImage:UIImage
            _uiImage = UIImage()
            var track = asset.tracks(withMediaType: AVMediaType.video)
            if let media = track[0] as? AVAssetTrack {
              var naturalSize: CGSize = media.naturalSize
              var transform: CGAffineTransform = media.preferredTransform

              if transform.tx == naturalSize.width && transform.ty == naturalSize.height {
                _uiImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.down)
              } else if transform.tx == 0 && transform.ty == 0 {
                _uiImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.up)
              } else if transform.tx == 0 && transform.ty == naturalSize.width {
                _uiImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.left)
              } else {
                _uiImage = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImage.Orientation.right)
              }
            }
            return _uiImage
        } catch {
            print(error)
            return UIImage(named: "some generic thumbnail")!
        }
    }
    
    func previewImage(fromVideo videoAsset: PHAsset, completion: @escaping (UIImage?)->Void) {
        print("動画からサムネイルを生成(PHAsset)")
        let manager = PHImageManager.default()
        manager.requestAVAsset(forVideo: videoAsset, options: nil) {asset, audioMix, info in
            guard let asset = asset else {
                print("asset is nil")
                return
            }
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            var time = asset.duration

            print(time)
            time.value = min(time.value, 2)
            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                completion(UIImage(cgImage: imageRef))
            } catch {
                print(error) //エラーを黙って捨ててしまってはいけない
                completion(nil)
            }
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
        rgifNum = randomInt
        self.setGif(id:self.gifList.data[randomInt].id)
        
        
        repeatRender()
        
        self.createSticker(self.inputImage)

        _core.bringSubviewToFront(sceneView)
        

        SVProgressHUD.dismiss()
        
        UIView.animate(withDuration: 0.5, animations: {
                                                  
                                                  
           self.sceneView.alpha = 1
      }, completion: { (finished: Bool) in
        UIView.animate(withDuration: 0.5, animations: {
                                                      
                                            
               self.backgroundView.alpha = 1
          }, completion: { (finished: Bool) in
              
          })
      })
 
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

                
                DispatchQueue.main.async {
                   self.renderFirstView()
                }
                
               } catch let error {
                  print(error)
               }
            }
            
            

            
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




extension SkyViewController: GiphyDelegate {
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


