//
//  JDPhotoBrowserCell
//
//
//  Created by 张江东 on 2017/4/12.
//  Copyright © 2017年 58kuaipai. All rights reserved.
//

import UIKit
import Photos
import SDWebImage

class JDPhotoBrowserCell: UICollectionViewCell,UIGestureRecognizerDelegate ,UIScrollViewDelegate{
    
    var imageRect = CGRect(x: 0 , y:0, width: kJDScreenWidth  , height:  kJDScreenHeight )
    var isDissmiss: Bool = false
    var totalScale : CGFloat = 1.0
    var maxScale : CGFloat = 5.0
    var minScale : CGFloat = 1
    var isImageDone: Bool = false
    var cellPhotoBrowserAnimator : JDPhotoBrowserAnimator?
    var centerPoint: CGPoint?

    var image: UIImage?{
        didSet{
            backImg.image = image
            self.getImageSize(image: image!)
        }
    }
    
    var lastImageId: Int32 = 0
    
    var assert: PHAsset?{
        didSet{
            if assert != nil {
                self.getOrangeImage(asset: assert!) {[weak self] (data) in
                    let img = UIImage(data: data!)
                    if data != nil {
                        self?.backImg.image = img
                        self?.getImageSize(image: (self?.backImg.image)!)
                    }
                }
            }
        }
    }
    
    var imageUrl: String?{
        didSet{
            self.cellPhotoBrowserAnimator?.isImageDone = false
            self.isImageDone = false
            
            self.backImg.sd_setImage(with: URL(string: imageUrl!), placeholderImage: placeImage, options: .progressiveDownload, progress: { (receive, all, _) in
                
            }) { (image, _, _, _) in
                self.getImageSize(image: image!)
            }
        }
    }
    
    typealias ImgCallBackType = (Data?)->()
    
    //获取原图
    private func getOrangeImage(asset: PHAsset,callback: @escaping ImgCallBackType){
        //获取原图
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.resizeMode = .exact
        lastImageId = PHImageManager.default().requestImageData(for: asset, options: option, resultHandler: { (data, string, up, nil) in
            if data != nil{
                callback(data)
            }
        })
    }
    
    //大图尺寸
    func getImageSize(image: UIImage){
        self.isImageDone = true
        self.cellPhotoBrowserAnimator?.isImageDone = true
        let imageSize = image.size
        let imageW = imageSize.width
        let imageH = imageSize.height
        let actualImageW = kJDScreenWidth
        let actualImageH = actualImageW/imageW * imageH
        imageRect = CGRect(x: 0, y: (kJDScreenHeight - actualImageH)/2, width: actualImageW, height: actualImageH)
        
        if actualImageH > kJDScreenHeight {
            imageRect = CGRect(x: 0, y: 0, width: kJDScreenWidth, height: kJDScreenHeight)
        }
        scrollView.frame = CGRect(x: 0, y: 0, width: kJDScreenWidth, height: kJDScreenHeight)
        self.scrollView.contentSize = CGSize(width: imageRect.size.width, height: imageRect.size.height)
        self.scrollView.contentInset = UIEdgeInsets(top: imageRect.origin.y, left: 0, bottom: 0, right: 0)
        backImg.frame = CGRect(x: 0, y: 0, width: imageRect.size.width, height: imageRect.size.height)
        backImg.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.contentView.addSubview(scrollView)
        
        scrollView.addSubview(backImg)
        scrollView.delegate = self
        addGesture()
    }
    
    private func addGesture(){
        //单击
        let tap = UITapGestureRecognizer(target: self, action: #selector(backImgTap1(recognizer:)))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        backImg.addGestureRecognizer(tap)
        self.scrollView.addGestureRecognizer(tap)
        
        //双击
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(backImgTap2(recognizer:)))
        tap2.numberOfTapsRequired = 2
        tap2.numberOfTouchesRequired = 1
        tap2.delegate = self
        backImg.addGestureRecognizer(tap2)
        tap.require(toFail: tap2)
        self.scrollView.addGestureRecognizer(tap2)
        
        //啮合手势
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchDid(recognizer:)))
        pinch.delegate = self
        backImg.addGestureRecognizer(pinch)
        
        //拖拽
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panDid(recognizer:)))
        pan.maximumNumberOfTouches = 1  //一个手指拖动
        pan.delegate = self
        backImg.addGestureRecognizer(pan)
    }

    //拖拽
    @objc private func panDid(recognizer:UIPanGestureRecognizer) {
        let backImageVi = recognizer.view as! UIImageView
        let point = recognizer.translation(in: self.contentView)
        backImageVi.transform.translatedBy(x: point.x, y: point.y)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: backImageVi)
    }
    
    //单击
    @objc private func backImgTap1(recognizer: UITapGestureRecognizer){
        let fatherVc = self.backImg.getCurrentVc() as! JDPhotoBrowser
        fatherVc.dismiss(animated: true, completion: nil)
    }
    
    //双击
    @objc private func backImgTap2(recognizer: UITapGestureRecognizer){
        var touchPoint = recognizer.location(in: self.scrollView)
        if touchPoint.y < 0 {
            touchPoint.y = 0
        }
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view

        touchPoint = self.scrollView.convert(touchPoint, to: rootView)

        if self.backImg.JDwidth > self.imageRect.width{//缩小
            self.scrollView.contentInset = UIEdgeInsets(top: self.imageRect.origin.y, left: 0, bottom: 0, right: 0)
            UIView.animate(withDuration: 0.25) {
            let zoomRect = self.zoomRectFor(scale: 1, center: touchPoint)
            self.scrollView.zoom(to:zoomRect, animated: true)
            }
        }else{//放大
            let bili = kJDScreenHeight/self.imageRect.height
            UIView.animate(withDuration: 0.25) {
                if bili > 2{//填满
                    let zoomRect = self.zoomRectFor(scale: bili, center: touchPoint)
                    self.scrollView.zoom(to:zoomRect, animated: true)
                }else{
                    let  zoomRect1 = self.zoomRectFor(scale: 2, center: touchPoint)
                    self.scrollView.zoom(to:zoomRect1, animated: true)
                }
                self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    //捏合
    @objc private func pinchDid(recognizer: UIPinchGestureRecognizer){
        self.scrollView.contentInset = UIEdgeInsets(top: self.imageRect.origin.y, left: 0, bottom: 0, right: 0)
        let scale = recognizer.scale
        self.totalScale *= scale
        recognizer.scale = 1.0;

        if totalScale > maxScale {
            return
        }
        if totalScale < minScale{
            return
        }
        self.scrollView.setZoomScale(totalScale, animated: true)
    }
    

    func zoomRectFor(scale: CGFloat,center: CGPoint) -> CGRect{
        let imgW = imageRect.size.width
        let imgH = imageRect.size.height
        var zoomRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        zoomRect.size.height = imgH / scale
        zoomRect.size.width  = imgW / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //允许多个手势存在
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    // 告诉scrollview要缩放的是哪个子控件
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.backImg
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if totalScale >= maxScale {
            totalScale = maxScale
        }else if totalScale < minScale{
            totalScale = minScale
        }
        
        if self.scrollView.contentSize.height >= kJDScreenHeight {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }else {
            self.scrollView.contentInset = UIEdgeInsets(top: self.imageRect.origin.y, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    // ------懒加载------
    lazy var backImg : UIImageView = {
        var img = UIImageView()
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        img.frame = CGRect(x: 0, y: 0, width: kJDScreenWidth , height: kJDScreenHeight )
        img.backgroundColor = UIColor.black
        return img
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.black
        scrollView.minimumZoomScale = 1;
        scrollView.maximumZoomScale = 5;
        scrollView.frame = CGRect(x: 0, y: 0, width: kJDScreenWidth, height: kJDScreenHeight)
        scrollView.contentSize = CGSize(width: kJDScreenWidth, height: kJDScreenHeight)
        scrollView.isUserInteractionEnabled = true
        scrollView.setZoomScale(1, animated: false)
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    lazy var  placeImage: UIImage = {
        // currentBundle.loadNibNamed("", owner: nil, options: nil)
        let currentBundle = Bundle(for: type(of: self))  //JDPhotoBrowser.framework
        var bundleName = (currentBundle.infoDictionary?["CFBundleName"] as! NSString).appending(".bundle")
        let path = currentBundle.path(forResource: "blackall@2x.png", ofType: nil, inDirectory: bundleName)
        let image = UIImage(contentsOfFile: path!)
        return image!
    }()
    
    lazy var  theimage: UIImage = {
        let currentBundle = Bundle(for: type(of: self))
        var bundleName = (currentBundle.infoDictionary?["CFBundleName"] as! NSString).appending(".bundle")
        let path = currentBundle.path(forResource: "123.png", ofType: nil, inDirectory: bundleName)
        let image = UIImage(contentsOfFile: path!)
        return image!
    }()
    
}



