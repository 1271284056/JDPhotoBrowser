//
//  ViewControllerTest.swift
//  JDPhotoBrowser_Example
//
//  Created by JiangDong Zhang on 2017/11/28.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import JDPhotoBrowser

class ViewControllerTest: UIViewController {


    let kbaseTag = 10
    var imageArray = [UIImage]()
    var imageViArray = [UIImageView]()
    
    let imageUrlArray = ["http://img.zhuo.com/58carimages/219632/1.jpg",
                         "http://img.zhuo.com/58carimages/219632/4.jpg",
                         "http://img.zhuo.com/58carimages/219617/2.jpg",
                         "http://img.zhuo.com/58carimages/219601/5.jpg",
                         "http://img.zhuo.com/58carimages/219601/6.jpg",
                         "http://img.zhuo.com/58carimages/219601/7.jpg",
                         "http://img.zhuo.com/58carimages/219601/8.jpg"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.urlImage() //网络图片
        //        self.localImage()
        
    }
    
    
    
    //--------网络图片 使用方法
    func urlImage(){
        for index in 0..<imageUrlArray.count{
            let imageVi = UIImageView()
            imageVi.jiuDengFrame(index: index, column: 2, viW: 100, viH: 100, topMargin: 40)
            imageVi.isUserInteractionEnabled = true
            self.view.addSubview(imageVi)
            imageVi.tag = kbaseTag + index
            imageViArray.append(imageVi)
            let tap = UITapGestureRecognizer(target: self, action: #selector(backImgTap(recognizer:)))
            imageVi.addGestureRecognizer(tap)
            imageVi.contentMode = .scaleAspectFill
            imageVi.clipsToBounds = true
            imageVi.sd_setImage(with: URL(string: imageUrlArray[index]), placeholderImage: UIImage(named: "default_image"))
        }
    }
    
    @objc private func backImgTap(recognizer: UITapGestureRecognizer){
        let backImageVi = recognizer.view as! UIImageView
        let photoB = JDPhotoBrowser(selectIndex: backImageVi.tag - kbaseTag, urls: imageUrlArray)
        photoB.sourceImageView = imageViArray[backImageVi.tag - kbaseTag]
        //传回当前浏览器图片索引
        photoB.endPageIndexClosure = {[weak self] (index: Int) in
            photoB.endImageView = self?.imageViArray[index]
        }
        self.present(photoB, animated: true, completion: nil)
    }
    
    // ---------- 本地图片
    func localImage(){
        for index in 0..<4{
            let imageVi = UIImageView()
            imageVi.jiuDengFrame(index: index, column: 2, viW: 100, viH: 100, topMargin: 40)
            imageVi.isUserInteractionEnabled = true
            self.view.addSubview(imageVi)
            imageVi.tag = kbaseTag + index
            imageViArray.append(imageVi)
            let tap = UITapGestureRecognizer(target: self, action: #selector(localImgTap(recognizer:)))
            imageVi.addGestureRecognizer(tap)
            imageVi.contentMode = .scaleAspectFill
            imageVi.clipsToBounds = true
            imageVi.image = UIImage(named: "0\(index+1)")
            
            imageArray.append(imageVi.image!)
        }
    }
    
    @objc private func localImgTap(recognizer: UITapGestureRecognizer){
        let backImageVi = recognizer.view as! UIImageView
        
        //selectIndex: 当前点击的图片在所有图片中的顺序 从0开始, images: 放有url字符串的数组
        let photoB = JDPhotoBrowser(selectIndex: backImageVi.tag - kbaseTag, images: imageArray)
        //点击的那个imageView告诉浏览四
        photoB.sourceImageView = imageViArray[backImageVi.tag - kbaseTag]
        //传回当前浏览器图片索引
        photoB.endPageIndexClosure = {[weak self] (index: Int) in
            //你根据返回索引告诉浏览器动画返回到哪一个ImageView上
            photoB.endImageView = self?.imageViArray[index]
        }
        self.present(photoB, animated: true, completion: nil)
        
    }


}
