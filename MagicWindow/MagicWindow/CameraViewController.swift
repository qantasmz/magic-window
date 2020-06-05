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


protocol CameraViewDelegate:class {
    func setInputImage(img:UIImage)
    func goToSky()
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    
    weak var  delegate:CameraViewDelegate? = nil
    
    var captureSession = AVCaptureSession()
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var photoOutput : AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?

    var videoOutput: AVCaptureVideoDataOutput!
    
    
    
    
    var _core:UIView!
    
    
    var imageView:UIImageView!
    
    var photoCameraButton: UIButton!
    var albumButton: UIButton!
    
    var infoButton: UIButton!
    
    var reverseButton: UIButton!
    
    var capturedImage:UIImage!
    

    private var imagePicker = UIImagePickerController()
    
    

  override func viewDidLoad() {
    super.viewDidLoad()
    

    let screenWidth:CGFloat = view.frame.size.width
    let screenHeight:CGFloat = view.frame.size.height
    
    SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0))
    SVProgressHUD.setRingThickness(2)
    SVProgressHUD.setForegroundColor(.white)
            

    imageView = UIImageView()

    imageView.contentMode = .scaleAspectFill
    imageView.frame = CGRect(x:0, y:0, width:screenWidth, height:screenHeight)
    
    self.view.addSubview(imageView)
    
    
    // Setup image picker.
    imagePicker.delegate = self
    imagePicker.sourceType = .photoLibrary

    
    var tmpImage:UIImage
    var tmpImageView:UIImageView
    var tmpRect:CGRect

    
    let screenSize: CGSize = UIScreen.main.bounds.size
    
    
    var svgImageView: UIImageView
    var svgImage: SVGKImage
    
    
    photoCameraButton = UIButton()

    
    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 313/3, height: 313/3)
    svgImage = SVGKImage(named: "shoot_svg")
    svgImage.size = svgImageView.bounds.size
    svgImageView.image = svgImage.uiImage
    
    
    photoCameraButton.frame = CGRect(x:screenWidth/2-313/3/2, y:screenHeight-150,
                          width:313/3, height:313/3)
    

    photoCameraButton.addSubview(svgImageView)
    //photoCameraButton.setImage(svgImage, for: .normal)
    photoCameraButton.imageView?.contentMode = .scaleAspectFit
    photoCameraButton.addTarget(self, action: #selector(captureCamera(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(photoCameraButton)
    // Enable camera option only if current device has camera.
    let isCameraAvailable = UIImagePickerController.isCameraDeviceAvailable(.front)
      || UIImagePickerController.isCameraDeviceAvailable(.rear)
    if isCameraAvailable {
      photoCameraButton.isEnabled = true
    }
    

    albumButton = UIButton()
    albumButton.frame = CGRect(x:screenWidth/2-145, y:screenHeight-124,
                          width:94/3, height:74/3)
    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 94/3, height: 74/3)
    svgImage = SVGKImage(named: "import_svg")
    svgImage.size = svgImageView.bounds.size
    svgImageView.image = svgImage.uiImage
    
    albumButton.addSubview(svgImageView)
    albumButton.imageView?.contentMode = .scaleAspectFit
    albumButton.addTarget(self, action: #selector(openAlbum(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(albumButton)
    
    
    

    infoButton = UIButton()
    infoButton.frame = CGRect(x:screenWidth/2+80, y:screenHeight-124,
                          width:94/3, height:94/3)
    
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 94/3, height: 94/3)
    svgImage = SVGKImage(named: "info_svg")
    svgImage.size = svgImageView.bounds.size
    svgImageView.image = svgImage.uiImage
    
    infoButton.addSubview(svgImageView)
    infoButton.imageView?.contentMode = .scaleAspectFit
    infoButton.addTarget(self, action: #selector(openAlbum(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(infoButton)

    
    
    reverseButton = UIButton()
    reverseButton.frame = CGRect(x:screenWidth-100, y:30,
                          width:89/3, height:81/3)
    svgImageView = UIImageView()
    svgImageView.frame = CGRect(x: 0, y: 0, width: 89/3, height: 81/3)
    svgImage = SVGKImage(named: "cam_svg")
    svgImage.size = svgImageView.bounds.size
    svgImageView.image = svgImage.uiImage
    
    reverseButton.addSubview(svgImageView)
    reverseButton.imageView?.contentMode = .scaleAspectFit
    reverseButton.addTarget(self, action: #selector(reverseCamera(_:)), for: UIControl.Event.touchUpInside)
    self.view.addSubview(reverseButton)

    
    
    setupCaptureSession()
    setupDevice()
    setupInputOutput()
    setupPreviewLayer()
    
    captureSession.startRunning()
    
    
    
  }
    
    

   func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       

       let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
       let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
       
       let orientation :CGImagePropertyOrientation = CGImagePropertyOrientation.right
       let orientedImage = ciimage.oriented(orientation)
       
        capturedImage = self.convert(cmage: orientedImage)
       
    
       //print(image.size.width/10)
       //image?.scaleImage(scaleSize: 0.1)
       
       /*
       let reSize = CGSize(width: image.size.width/30, height: image.size.height/30)
       
       
       UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
       image.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
       let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
       UIGraphicsEndImageContext();
       image = reSizeImage
*/
        //runSegmentation(image)
      // runSegmentation(image)
      // self.imageView.image = image
       

   }
    
    func convert(cmage:CIImage) -> UIImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
   @objc func captureCamera(_ sender : UIButton) {
    
    delegate?.setInputImage(img: capturedImage)
    delegate?.goToSky()
   }
    @objc func openAlbum(_ sender : UIButton) {
        

        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
       
    
    @objc func reverseCamera(_ sender : UIButton) {

        
        self.captureSession.stopRunning()
        self.captureSession.inputs.forEach { input in
            self.captureSession.removeInput(input)
        }
        self.captureSession.outputs.forEach { output in
            self.captureSession.removeOutput(output)
        }

        // prepare new camera preview
        let newCameraPosition: AVCaptureDevice.Position = self.currentDevice!.position == .front ? .back : .front
       self.currentDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: newCameraPosition)
        self.setupInputOutput()
        
        let newVideoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        newVideoLayer.frame = self.view.bounds
        newVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // horizontal flip
        UIView.transition(with: self.view, duration: 1.0, options: [.transitionCrossDissolve], animations: nil, completion: { _ in
            // replace camera preview with new one
            self.imageView.layer.replaceSublayer(self.cameraPreviewLayer!, with: newVideoLayer)
            self.cameraPreviewLayer = newVideoLayer
        })
        

        captureSession.startRunning()
    }
       
    
    func showHud(){
        SVProgressHUD.show()
    }
  
    func hideHud(){
        SVProgressHUD.dismiss()
    }
    
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
    


}



extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      
      dismiss(animated: true)
      if let pickedImage = info[.originalImage] as? UIImage {
        //runSegmentation(pickedImage)

          delegate?.setInputImage(img: pickedImage)
          delegate?.goToSky()
        /*
          if(_calcLock == 0){

              _calcLock = 1
              createSticker(pickedImage)
          }
 */
      }

    }
    


   // カメラの画質の設定
   func setupCaptureSession() {
       captureSession.sessionPreset = AVCaptureSession.Preset.photo
   }

   // デバイスの設定
   func setupDevice() {
       // カメラデバイスのプロパティ設定
       let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
       // プロパティの条件を満たしたカメラデバイスの取得
       let devices = deviceDiscoverySession.devices

       for device in devices {
           if device.position == AVCaptureDevice.Position.back {
               mainCamera = device
           } else if device.position == AVCaptureDevice.Position.front {
               innerCamera = device
           }
       }
       // 起動時のカメラを設定
       currentDevice = mainCamera
   }

   // 入出力データの設定
   func setupInputOutput() {
       do {
           // 指定したデバイスを使用するために入力を初期化
           let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
           // 指定した入力をセッションに追加
           
           
           videoOutput = AVCaptureVideoDataOutput()
           // 出力設定: カラーチャンネル
           videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
           // 出力設定: デリゲート、画像をキャプチャするキュー
           videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
           // 出力設定: キューがブロックされているときに新しいフレームが来たら削除
           videoOutput.alwaysDiscardsLateVideoFrames = true
           
           let connection  = videoOutput.connection(with: AVMediaType.video)
           connection?.videoOrientation = .portrait
           captureSession.addInput(captureDeviceInput)
           
           captureSession.addOutput(videoOutput)
           
           /*
           photoOutput = AVCapturePhotoOutput()
           photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
           captureSession.addOutput(photoOutput!)
*/
       } catch {
           print(error)
       }
   }
    
 
   // カメラのプレビューを表示するレイヤの設定
   func setupPreviewLayer() {
       // 指定したAVCaptureSessionでプレビューレイヤを初期化
       self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
       // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
       self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
       // プレビューレイヤの表示の向きを設定
       self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

       self.cameraPreviewLayer?.frame = view.frame
    //self.imageView.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    

    self.imageView.layer.addSublayer(self.cameraPreviewLayer!)
   }
}
