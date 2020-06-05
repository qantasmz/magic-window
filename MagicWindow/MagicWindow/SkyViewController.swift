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
    var imageLoadingView: UIImageView!
    
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
  var clippingScoresAbove: Double { return 0.7 }

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
    
    var scrollView:UIScrollView!
    
    var scrollSnapWidth:CGFloat = 200
    var lastOffset:CGFloat = 0
    
    var obj_arr:[NSDictionary]!
    
    var prevScrollNum:Int = 0
    
    var subView:UIView!
  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    
    
    SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0))
    SVProgressHUD.setRingThickness(2)
    SVProgressHUD.setForegroundColor(.white)
    
    
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
    
    
    var tmpImage:UIImage
    var tmpImageView:UIImageView
    var tmpRect:CGRect
    
    var svgImageView: UIImageView
    var svgImage: SVGKImage

    photoCameraButton = UIButton()

    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 93/3, height: 97/3)
    svgImage = SVGKImage(named: "peke_svg")
    svgImage.size = svgImageView.bounds.size
    svgImageView.image = svgImage.uiImage
    
    photoCameraButton.frame = CGRect(x:15, y:30,width:93/3, height:97/3)

    photoCameraButton.addSubview(svgImageView)
    photoCameraButton.imageView?.contentMode = .scaleAspectFit
    photoCameraButton.addTarget(self, action: #selector(tapCamera(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(photoCameraButton)

  
       /*
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
    
    */
    skyUI = UIView(frame: CGRect(x: 0, y: screenHeight - 562/3, width: screenSize.width, height: 562/3))
    
    

    
    let skyUICov = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 562/3-200/3))
    skyUICov.alpha = 0.7
    skyUICov.backgroundColor = .black
    skyUI.addSubview(skyUICov)
    
    scrollSnapWidth = screenSize.width/3
    
    
     scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 200/3))
    scrollView.delegate = self
    scrollView.showsHorizontalScrollIndicator = false
     
     skyUI.addSubview(scrollView)
    
    
    let _gifBt = UIButton()
    
    
    tmpImage = UIImage(named:"gif")!
    tmpImageView = UIImageView(image:tmpImage)
    tmpRect = CGRect(x:0, y:0, width:90/3, height:87/3)
    tmpImageView.frame = tmpRect
    tmpImageView.contentMode = .scaleAspectFill
    
    _gifBt.addSubview(tmpImageView)
    _gifBt.frame = CGRect(x:screenWidth/2-90, y:200/3, width:90/3, height:87/3)
    _gifBt.addTarget(self, action: #selector(self.gifButtonTapped), for: .touchUpInside)
    skyUI.addSubview(_gifBt)
    
    
    let _impBt = UIButton()
    
    
    tmpImage = UIImage(named:"roll")!
    tmpImageView = UIImageView(image:tmpImage)
    tmpRect = CGRect(x:0, y:0, width:82/3, height:80/3)
    tmpImageView.frame = tmpRect
    tmpImageView.contentMode = .scaleAspectFill
    _impBt.addSubview(tmpImageView)
    _impBt.frame = CGRect(x:screenWidth/2+90-82/3, y:200/3, width:82/3, height:80/3)
    _impBt.addTarget(self, action: #selector(self.importButtonTapped), for: .touchUpInside)
    skyUI.addSubview(_impBt)
    
    
    let _decBt = UIButton()
    
    _decBt.setTitle("LET'S GO", for: [])
    _decBt.setTitleColor(UIColor.black, for: [])
    let font = UIFont(name: "Helvetica-Bold", size: 85/3)
    _decBt.titleLabel?.font = font
    _decBt.backgroundColor = .white
    _decBt.frame = CGRect(x:0, y:562/3-200/3, width:screenWidth, height:200/3)
    _decBt.addTarget(self, action: #selector(self.gotoShare), for: .touchUpInside)
    skyUI.addSubview(_decBt)
    
    
    self.view.addSubview(skyUI)
    
    
    
    
    shareUI = UIView(frame: CGRect(x: 0, y: screenHeight -  227/3, width: screenSize.width, height: 227/3))
    
    
    let shareUICov = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 227/3))
    shareUICov.alpha = 0.7
    shareUICov.backgroundColor = .black
    shareUI.addSubview(shareUICov)
    
    
    
    let _saveGifBt = UIButton()
    
    
    tmpImage = UIImage(named:"save")!
    tmpImageView = UIImageView(image:tmpImage)
    let dx0 = 90/2-77/3/2
    tmpRect = CGRect(x:dx0, y:0, width:77/3, height:74/3)
    tmpImageView.frame = tmpRect
    tmpImageView.contentMode = .scaleAspectFill
    
    _saveGifBt.addSubview(tmpImageView)

    _saveGifBt.frame = CGRect(x:screenWidth/2-90/2, y:15, width:90, height:150)
    _saveGifBt.addTarget(self, action: #selector(self.saveGif), for: .touchUpInside)
    

    
    
    let lbl0 = UILabel()
    lbl0.frame = CGRect(x: 0, y: 20, width: 90, height: 30)
    lbl0.textAlignment = .center
    lbl0.font = UIFont(name: "Helvetica-Oblique", size: 45/3)
    lbl0.text = "video"
    lbl0.textColor = .white
    
    _saveGifBt.addSubview(lbl0)
    
    
    
    let _cov0 = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 150))
     _cov0.backgroundColor = .clear
     _saveGifBt.addSubview(_cov0)
    
    shareUI.addSubview(_saveGifBt)
    
    
    let _saveVideoBt = UIButton()
    tmpImage = UIImage(named:"save")!
    tmpImageView = UIImageView(image:tmpImage)
    let dx1 = 90/2-77/3/2
    tmpRect = CGRect(x:dx1, y:0, width:77/3, height:74/3)
    tmpImageView.frame = tmpRect
    tmpImageView.contentMode = .scaleAspectFill
    
    _saveVideoBt.addSubview(tmpImageView)
    _saveVideoBt.frame = CGRect(x:screenWidth/2-140, y:15, width:90, height:150)
    _saveVideoBt.addTarget(self, action: #selector(self.saveVideo), for: .touchUpInside)
    
    let lbl1 = UILabel()
    lbl1.frame = CGRect(x: 0, y: 20, width: 90, height: 30)
    lbl1.textAlignment = .center
    lbl1.font = UIFont(name: "Helvetica-Oblique", size: 45/3)
    lbl1.text = "gif"
    lbl1.textColor = .white
    
    _saveVideoBt.addSubview(lbl1)
    let _cov1 = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 150))
     _cov1.backgroundColor = .clear
     _saveVideoBt.addSubview(_cov1)
    
    shareUI.addSubview(_saveVideoBt)
    
    
    let _shareVideoBt = UIButton()
    
    tmpImage = UIImage(named:"sharing")!
    tmpImageView = UIImageView(image:tmpImage)
    let dx2 = 90/2 - 76/3/2
    tmpRect = CGRect(x:dx2, y:0, width:76/3, height:76/3)
    tmpImageView.frame = tmpRect
    tmpImageView.contentMode = .scaleAspectFill
    
    _shareVideoBt.addSubview(tmpImageView)
    _shareVideoBt.frame = CGRect(x:screenWidth/2+50, y:15, width:90, height:150)
    _shareVideoBt.addTarget(self, action: #selector(self.shareVideo), for: .touchUpInside)
    
    
    let lbl2 = UILabel()
    lbl2.frame = CGRect(x: 0, y: 20, width: 90, height: 30)
    lbl2.textAlignment = .center
    lbl2.font = UIFont(name: "Helvetica-Oblique", size: 45/3)
    lbl2.text = "share"
    lbl2.textColor = .white
    
    _shareVideoBt.addSubview(lbl2)
    let _cov2 = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 150))
     _cov2.backgroundColor = .clear
     _shareVideoBt.addSubview(_cov2)
    shareUI.addSubview(_shareVideoBt)
    
    
    self.view.addSubview(shareUI)
    
    

    let imageLoading:UIImage = UIImage(named:"cloud")!
    imageLoadingView = UIImageView(image:imageLoading)
    let rect:CGRect = CGRect(x:0, y:0, width:414/3, height:278/3)
     imageLoadingView.contentMode = .scaleAspectFill
    imageLoadingView.frame = rect;
    imageLoadingView.center = CGPoint(x:screenWidth/2, y:screenHeight/2-55)
    imageLoadingView.isHidden = true
    self.view.addSubview(imageLoadingView)
    


    
    
  }
    
    func createContentsView() -> UIView {

        
        //self.gifList.data.count
        // contentsViewを作る
        let contentsView = UIView()
        contentsView.frame = CGRect(x: 0, y: 0, width: (self.gifList.data.count+2)*Int(scrollSnapWidth), height: 200/3)

        obj_arr = []
        for count in 0...self.gifList.data.count {
            if(count != 0){
                let obj = createLabel(contentsView: contentsView,num:count, name:"name"+String(count), author:"author"+String(count))
                contentsView.addSubview(obj["button"] as! UIButton)
                obj_arr.append(obj)
            }
        }
        

        return contentsView
    }
    
    func createLabel(contentsView: UIView,num:Int,name:String,author:String) -> NSDictionary {

        let obj = NSMutableDictionary()
        
        let button = UIButton()

        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: scrollSnapWidth, height: 138/3)
        label.textAlignment = .center
        let font = UIFont(name: "Helvetica-BoldOblique", size: 65/3)
        label.font = font
        label.text = name
        label.textColor = .white
        
        button.addSubview(label)
        
        
        let sub = UILabel()
        sub.frame = CGRect(x: 0, y: 25, width: scrollSnapWidth, height: 138/3)
        sub.textAlignment = .center
        let fontSub = UIFont(name: "Helvetica", size: 50/3)
        sub.font = fontSub
        sub.text = author
        sub.textColor = .white
        
        button.addSubview(sub)
        button.frame = CGRect(x:CGFloat(num)*scrollSnapWidth, y:0,width:scrollSnapWidth, height:138/3)

        
              let _cov = UIView(frame: CGRect(x: 0, y: 0, width: scrollSnapWidth, height: 200/3))
               _cov.backgroundColor = .clear
               button.addSubview(_cov)
              
        obj["button"] = button
        obj["label"] = label
        obj["sub"] = sub
        
        return obj
    }
    public func initialize(img:UIImage){
        _uiStat = 0
        inputImage = img
        sceneView.alpha = 0
        backgroundView.alpha = 0
        //toggleUI.isHidden = false
        shareUI.isHidden = true
        skyUI.isHidden = false
        showHud()
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
        imageLoadingView.isHidden = false
        imageLoadingView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
              self.imageLoadingView.alpha = 1
         }, completion: { (finished: Bool) in
         
         })
    
    }
  
    func hideHud(){
        SVProgressHUD.dismiss()
        
        
        UIView.animate(withDuration: 0.5, animations: {
              self.imageLoadingView.alpha = 0
         }, completion: { (finished: Bool) in
            self.imageLoadingView.isHidden = true
         
         })
    }
    
    func renderSaving(){
        
        SVProgressHUD.showProgress(Float(Float(self._saveCnt)/Float(self.saveArr.count))/2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
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
        
        // 現在のフレームカウント
        var frameCount = 0
        
        // 各画像の表示する時間
        let durationForEachImage = time
        
        // FPS
        
        let fps:__int32_t = __int32_t(1/(self.backgroundView.animationDuration / Double(self.backgroundView.animationImages!.count)))
       
        var _psec:Float64 = 0
        var opCount:Int = 0
        startRenderMovie(writerInput:writerInput, videoWriter:videoWriter, durationForEachImage:durationForEachImage,fps:fps,frame:frameCount,url:url!,_sec:_psec,adaptor:adaptor,size:size,pCount:opCount)
        
        
    }
    
    func startRenderMovie(writerInput: AVAssetWriterInput,videoWriter: AVAssetWriter, durationForEachImage:Int,fps:__int32_t,frame:Int,url:URL,_sec:Float64,adaptor:AVAssetWriterInputPixelBufferAdaptor,size:CGSize,pCount:Int){
        var opCount = pCount
        var buffer: CVPixelBuffer? = nil
        var _psec = _sec
        var frameCount = frame
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            
            if _psec < 13 {
                SVProgressHUD.showProgress(Float(Float(_psec)/13*0.5+0.5))
                
                //for image in self.images {
                if(opCount < self.images.count){
                    //ProgressHUD.showProgress(Float(Float(frameCount)/Float(self.images.count)))
               
                    
                    // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
                    let frameTime: CMTime = CMTimeMake(value: Int64(__int32_t(frameCount) * __int32_t(durationForEachImage)), timescale: fps)
                    //時間経過を確認(確認用)
                    let second = CMTimeGetSeconds(frameTime)
                    _psec = second
                    print(_psec)
                    
                    let resize = self.resizeImage(image: UIImage(cgImage: self.images[opCount]), contentSize: size)
                    // CGImageからBufferを生成
                    buffer = self.pixelBufferFromCGImage(cgImage: resize.cgImage!)
                    
                    // 生成したBufferを追加
                    if (!adaptor.append(buffer!, withPresentationTime: frameTime)) {
                        // Error!
                        print("adaptError")
                        print(videoWriter.error!)
                    }
                    
                    frameCount += 1
                    opCount += 1
                    if(opCount == self.images.count){
                        opCount = 0
                    }
                }
                self.startRenderMovie(writerInput:writerInput, videoWriter:videoWriter, durationForEachImage:durationForEachImage,fps:fps,frame:frameCount,url:url,_sec:_psec,adaptor:adaptor,size:size,pCount:opCount)
            }else{
                self.finishVideoGeneration(writerInput:writerInput, videoWriter:videoWriter, durationForEachImage:durationForEachImage,fps:fps,frameCount:frameCount,url:url)
            }
        }
    }
    func finishVideoGeneration(writerInput: AVAssetWriterInput,videoWriter: AVAssetWriter, durationForEachImage:Int,fps:__int32_t,frameCount:Int,url:URL){
        
        // 動画生成終了
        writerInput.markAsFinished()
        videoWriter.endSession(atSourceTime: CMTimeMake(value: Int64((__int32_t(frameCount)) *  __int32_t(durationForEachImage)), timescale: fps))
        videoWriter.finishWriting(completionHandler: {
            // Finish!
            print("movie created.")

            
            
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
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
                   let url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("tmp.mp4")
                   let _nd = data as! NSData
                   _nd.write(to: url!, atomically: true)
             
                   PHPhotoLibrary.shared().performChanges({
                                         PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url!)
                                      }, completionHandler:  { success, error in
                                         if !success { NSLog("error creating asset: \(error)") }else{

                                            DispatchQueue.main.async {
                                             self.hideHud()
                                            }
                                            
                                         }
                                     })

                })
                task.resume()

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
       
        
        var opCount:Int = 0
        saveGifImageEnd(url:url!,destination:destination,frameProperties:frameProperties as CFDictionary,pCount:opCount)
    }
    
    func saveGifImageEnd(url:URL,destination:CGImageDestination,frameProperties:CFDictionary,pCount:Int){
        var opCount = pCount

        SVProgressHUD.showProgress(Float(Float(opCount)/Float(self.images.count)*0.5+0.5))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            if(opCount < self.images.count){
                CGImageDestinationAddImage(destination, self.images[opCount], frameProperties as CFDictionary)
                opCount += 1
                self.saveGifImageEnd(url:url,destination:destination,frameProperties:frameProperties as CFDictionary,pCount:opCount)
            }else{

                if CGImageDestinationFinalize(destination) {
                    print("GIF生成が成功")
                } else {
                    print("GIF生成に失敗")
                }
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
                    let url = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("tmp.gif")
                    let _nd = data as! NSData
                    _nd.write(to: url!, atomically: true)

                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url!)
                     }, completionHandler:  { success, error in
                        if !success { NSLog("error creating asset: \(error)") }else{

                            DispatchQueue.main.async {
                            self.hideHud()
                            }
                           
                        }
                    })
                    

                 })
                 task.resume()
            }
        }
        
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
        //toggleUI.isHidden = true
        UIView.transition(with: self.view, duration: 0.5, options: [.transitionCrossDissolve], animations: nil, completion: { _ in
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
            UIView.transition(with: self.view, duration: 0.5, options: [.transitionCrossDissolve], animations: nil, completion: { _ in
                // replace camera preview with new one
                self.skyUI.isHidden = false
                //self.toggleUI.isHidden = false
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
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
        
        
        

        if(subView != nil){
            subView.removeFromSuperview()
        }
        subView = createContentsView()
        scrollView.contentSize = subView.frame.size
        
        //scrollView.isPagingEnabled = true
        scrollView.addSubview(subView)
        
        setMenuNum(s:0)
        
        let randomInt = Int.random(in: 1..<self.gifList.data.count)
        rgifNum = randomInt
        self.setGif(id:self.gifList.data[randomInt].id)
        
        
        repeatRender()
        
        self.createSticker(self.inputImage)

        _core.bringSubviewToFront(sceneView)
        
        hideHud()
        
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

    /*
extension SkyViewController: UIScrollViewDelegate {


    private func scrollViewDidScroll(scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
        if scrollView.contentOffset.x > lastOffset + scrollSnapWidth {
            scrollView.isScrollEnabled = false
        } else if scrollView.contentOffset.x < lastOffset - scrollSnapWidth {
            scrollView.isScrollEnabled = false
        }
    }

    private func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        guard !decelerate else {
            return
        }

        setContentOffset(scrollView: scrollView)
    }

    private func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {

        setContentOffset(scrollView: scrollView)
    }
    
    func setContentOffset(scrollView: UIScrollView) {

        let stopOver = scrollSnapWidth
        var x = round(scrollView.contentOffset.x / stopOver) * stopOver
        x = max(0, min(x, scrollView.contentSize.width - scrollView.frame.width))
        lastOffset = x

        scrollView.setContentOffset(CGPoint(x:x, y:scrollView.contentOffset.y), animated: true)

        scrollView.isScrollEnabled = true
    }

    
}
 */
extension SkyViewController: UIScrollViewDelegate {
    func setContentOffset(scrollView: UIScrollView) {

        let stopOver = scrollSnapWidth
        var x = round(scrollView.contentOffset.x / stopOver) * stopOver
        x = max(0, min(x, scrollView.contentSize.width - scrollView.frame.width))
        lastOffset = x

        scrollView.setContentOffset(CGPoint(x:x, y:scrollView.contentOffset.y), animated: true)

        scrollView.isScrollEnabled = true
    }
    // スクロール中に呼び出され続けるデリゲートメソッド.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.x)
        if scrollView.contentOffset.x > lastOffset + scrollSnapWidth {
            scrollView.isScrollEnabled = false
        } else if scrollView.contentOffset.x < lastOffset - scrollSnapWidth {
            scrollView.isScrollEnabled = false
        }
        
        
        /*
         
         */
    }

    // ズーム中に呼び出され続けるデリゲートメソッド.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print(#function)
    }

    // ユーザが指でドラッグを開始した場合に呼び出されるデリゲートメソッド.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(#function)
    }

    // ユーザがドラッグ後、指を離した際に呼び出されるデリゲートメソッド.
    // velocity = points / second.
    // targetContentOffsetは、停止が予想されるポイント？
    // pagingEnabledがYESの場合には、呼び出されません.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(#function)
    }

    // ユーザがドラッグ後、指を離した際に呼び出されるデリゲートメソッド.
    // decelerateがYESであれば、慣性移動を行っている.
    //
    // 指をぴたっと止めると、decelerateはNOになり、
    // その場合は「scrollViewWillBeginDecelerating:」「scrollViewDidEndDecelerating:」が呼ばれない？
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print(#function)
        
        guard !decelerate else {
            return
        }

        setContentOffset(scrollView: scrollView)
    }

    // ユーザがドラッグ後、スクロールが減速する瞬間に呼び出されるデリゲートメソッド.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //print(#function)
        
        setContentOffset(scrollView: scrollView)
    }

    // ユーザがドラッグ後、慣性移動も含め、スクロールが停止した際に呼び出されるデリゲートメソッド.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(round(scrollView.contentOffset.x/scrollSnapWidth))
        
        
        /*
         for count in 0...self.gifList.data.count {
             if(count != 0){
                 let obj = createLabel(contentsView: contentsView,num:count, name:"name"+String(count), author:"author"+String(count))
                 contentsView.addSubview(obj["button"] as! UIButton)
                 obj_arr.append(obj)
             }
         }
         
         */
    }

    // スクロールのアニメーションが終了した際に呼び出されるデリゲートメソッド.
    // アニメーションプロパティがNOの場合には呼び出されない.
    // 【setContentOffset】/【scrollRectVisible:animated:】
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let snum = Int(round(scrollView.contentOffset.x/scrollSnapWidth))
        if(prevScrollNum != snum){
            setMenuNum(s:snum)
        }
        
        prevScrollNum = snum
      // print(#function)
    }
    func setMenuNum(s:Int){
        
        var nextInt = s
        rgifNum = nextInt
        self.setGif(id:self.gifList.data[nextInt].id)
        
        for count in 0...obj_arr.count-1 {
            let obj = obj_arr[count]
            let _label = obj["label"] as! UILabel
            let _sub = obj["sub"] as! UILabel
            if(count != s){

                UIView.animate(withDuration: 0.5, animations: {
                    /*
                    let font = UIFont(name: "Helvetica-BoldOblique", size: 45/3)
                    _label.font = font
                    
                    let fontSub = UIFont(name: "Helvetica", size: 35/3)
                    _sub.font = fontSub
                */

                    _label.transform = CGAffineTransform(scaleX: 45/65, y:45/65)
                    _label.frame.origin.y = 15
                    _sub.transform = CGAffineTransform(scaleX: 35/50, y:35/50)
                    _sub.frame.origin.y = 30
                })
            }else{

                UIView.animate(withDuration: 0.5, animations: {
                    /*
                    let font = UIFont(name: "Helvetica-BoldOblique", size: 65/3)
                    _label.font = font
                    

                    let fontSub = UIFont(name: "Helvetica", size: 50/3)
                    _sub.font = fontSub
                    */
                    
                    
                    _label.transform = CGAffineTransform(scaleX: 1, y:1)
                    _label.frame.origin.y = 0
                    _sub.transform = CGAffineTransform(scaleX: 1, y:1)
                    _sub.frame.origin.y = 25
                })
                
            }
        }
        
    }
    // ズーム中に呼び出されるデリゲートメソッド.
    // ズームの値に対応したUIViewを返却する.
    // nilを返却すると、何も起きない.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //print(#function)
        return nil
    }

    // ズーム開始時に呼び出されるデリゲートメソッド.
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        //print(#function)
    }

    // ズーム完了時(バウンドアニメーション完了時)に呼び出されるデリゲートメソッド.
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //print(#function)
    }

    // 先頭にスクロールする際に呼び出されるデリゲートメソッド.
    // NOなら反応しない.
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        //print(#function)
        return true
    }

    // 先頭へのスクロールが完了した際に呼び出されるデリゲートメソッド.
    // すでに先頭にいる場合には呼び出されない.
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        //print(#function)
    }

    // スクロールビューのinsetsの値が変わった際に呼び出されるデリゲートメソッド.
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        //print(#function)
    }
}
