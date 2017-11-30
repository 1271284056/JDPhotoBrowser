//
//  JDPhotoBrowserAnimator

//  Created by 张江东 on 2017/4/12.
//  Copyright © 2017年 58kuaipai. All rights reserved.

import UIKit

class JDPhotoBrowserAnimator: NSObject {
    
    var imageRect = CGRect(x: 0 , y:0, width: kJDScreenWidth  , height:  kJDScreenHeight )
    var isPresented : Bool = false
    var sourceImageView: UIImageView? // 来源view
    var endImageView: UIImageView? // 消失时候view
    var currentPage: Int = 0
    var preSnapView : UIView?
    var isAniDone : Bool = false
    var superVc: JDPhotoBrowser?
    
    //加载进度提示框
    private lazy var progressView : UIActivityIndicatorView = {
        let loadVi = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadVi.startAnimating()
        return loadVi
    }()
    
    var isImageDone: Bool?{
        didSet{
            if isImageDone == true && self.isAniDone == true{
                progressView.removeFromSuperview()
                self.preSnapView?.removeFromSuperview()
            }else{
                if self.isAniDone == true {
                    progressView.center = CGPoint(x: imageRect.size.width/2, y: imageRect.size.height/2)
                    self.preSnapView?.addSubview(progressView)
                    //  print("加载中")
                }
            }
        }
    }
}

extension JDPhotoBrowserAnimator : UIViewControllerTransitioningDelegate{
    // isPresented 调用的动画
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    //消失时候调用的动画
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
    
}

extension JDPhotoBrowserAnimator : UIViewControllerAnimatedTransitioning{
    //动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    //动画方式
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresented ? animationForPresentedView(transitionContext) : animationForDismissView(transitionContext)
    }
    
    //弹出动画
    func animationForPresentedView(_ transitionContext: UIViewControllerContextTransitioning){
        //取出下一个 view 浏览器
        let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        transitionContext.containerView.addSubview(presentedView)
        
        if sourceImageView == nil {
            transitionContext.completeTransition(true)
            return
        }
        let imgView = UIImageView()
        imgView.image = sourceImageView?.image
        
        let window = UIApplication.shared.keyWindow
        imgView.frame = (sourceImageView?.convert((sourceImageView?.bounds)!, to: window))!
        self.getImageSize()
        
        let imgSize = imgView.image?.size
        let imgW = imgSize?.width
        let imgH = imgSize?.height
        imgView.JDwidth = (sourceImageView?.JDwidth)!
        imgView.JDheight = (sourceImageView?.JDwidth)!/imgW! * imgH!
        let snapView = imgView.snapshotView(afterScreenUpdates: true)
        //截图
        snapView?.frame = imgView.frame
        transitionContext.containerView.addSubview(snapView!)
        presentedView.alpha = 0.0
        transitionContext.containerView.backgroundColor = UIColor.black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(snapViewTap(recognizer:)))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        snapView?.addGestureRecognizer(tap)
        
        self.preSnapView = snapView
        self.isAniDone = false
        UIView.animate(withDuration:0.3 , animations: {
            snapView?.frame = self.imageRect
            
        }, completion: { (_) in
            self.isAniDone = true
            
            let presentedVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! JDPhotoBrowser
            let indexPath = IndexPath(item: self.currentPage, section: 0)
            guard  presentedVc.collectionView1.cellForItem(at: indexPath) != nil else { return }
            let cell = presentedVc.collectionView1.cellForItem(at: indexPath) as! JDPhotoBrowserCell
            self.isImageDone = cell.isImageDone
            
            presentedView.alpha = 1.0
            transitionContext.containerView.backgroundColor = UIColor.clear
            transitionContext.completeTransition(true)
        })
    }
    
    //单击
    @objc private func snapViewTap(recognizer: UITapGestureRecognizer){
        self.superVc?.dismiss(animated: true, completion: nil)
    }
    
    //大图尺寸
    func getImageSize(){
        let imageSize = sourceImageView?.image?.size
        let imageW = imageSize?.width
        let imageH = imageSize?.height
        let actualImageW = kJDScreenWidth
        let actualImageH = actualImageW/imageW! * imageH!
        imageRect = CGRect(x: 0, y: (kJDScreenHeight - actualImageH)/2, width: actualImageW, height: actualImageH)
    }
    
    //消失动画
    func animationForDismissView(_ transitionContext: UIViewControllerContextTransitioning){
        //上一级view
        let dismissView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let dismissVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! JDPhotoBrowser
        
        let indexPath = IndexPath(item: currentPage, section: 0)
        if dismissVc.collectionView1.cellForItem(at: indexPath) == nil {
            //currentPage快速滑动一直不变 最后销毁了
            transitionContext.completeTransition(true)
            return
        }
        
        let cell = dismissVc.collectionView1.cellForItem(at: indexPath) as! JDPhotoBrowserCell
        let snapView = cell.backImg.snapshotView(afterScreenUpdates: true)
        snapView?.frame = imageRect
        transitionContext.containerView.addSubview(snapView!)
        dismissView.removeFromSuperview()
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.endImageView == nil{
                snapView?.frame = self.imageRect
            }else{
                snapView?.frame = self.convertRect(for: self.endImageView!)
            }
        }, completion: { (_) in
            snapView?.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
        
    }
    
    fileprivate func convertRect(for view: UIView) -> CGRect! {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        let rect = view.superview?.convert(view.frame, to: rootView)
        return rect!
    }
    
}



