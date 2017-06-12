//
//  JDPhotoBrowser
//
//
//  Created by 张江东 on 17/3/3.
//  Copyright © 2017年 58kuaipai. All rights reserved.
//  邮箱 1271284056@qq.com  简书 http://www.jianshu.com/u/5e7182f9e694

import UIKit
import Photos

 let jdkresuId = "kJDPhotoBrowserId"

  class JDPhotoBrowser: UIViewController {
    
    var imageRectDict: [IndexPath: CGRect] = [IndexPath: CGRect]()

    
    var isViewAppeared: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppeared = true
    }
    
//    override var prefersStatusBarHidden: Bool{
//        return true
//    }
//    
    
    enum imageSourceType {
        case image
        case url
        case asserts
    }
    ///图片的url字符串数组
    var urls:[String]?
    var images: [UIImage]?
    var asserts: [PHAsset]?
    
    //传回当前浏览器图片索引
    public var endPageIndexClosure: (( _ index: Int)->())?
    var imageSourceTp: imageSourceType = .image
    var deleteButtonClosure: (( _ index: Int)->())?  //点击删除按钮时index
    private lazy var indexLabel = UILabel()

    public var sourceImageView: UIImageView?{
        didSet{
            photoBrowserAnimator.sourceImageView = sourceImageView
            photoBrowserAnimator.endImageView = sourceImageView
            photoBrowserAnimator.superVc = self
        }
    } // 来源view
    public var endImageView: UIImageView?{
        didSet{
            photoBrowserAnimator.endImageView = endImageView
        }
    } // 消失时候imageview
    
    
    var lastPage: Int = 0
    ///静止后选中照片的索引
    var currentPage : Int?{
        didSet{
            if self.imageSourceTp == .image {
                guard let kcount  = images?.count else { return  }
                indexLabel.text = "\((currentPage ?? 0) + 1)/\(kcount)"
            }else if self.imageSourceTp == .url{
                guard let kcount  = urls?.count else { return  }
                indexLabel.text = "\((currentPage ?? 0) + 1)/\(kcount)"
            }else if self.imageSourceTp == .asserts{
                guard let kcount  = asserts?.count else { return  }
                indexLabel.text = "\((currentPage ?? 0) + 1)/\(kcount)"
            }

            
        }
    }
    
    //1 url
    public init(selectIndex: Int, urls: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.currentPage = selectIndex
        self.urls = urls
        self.imageSourceTp = .url
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = photoBrowserAnimator
    }
    
    //2 image 第一个0
    public init(selectIndex: Int, images: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        self.currentPage = selectIndex
        self.images = images
        self.imageSourceTp = .image
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = photoBrowserAnimator
    }
    
    //3 相册
    public init(selectIndex: Int, asserts: [PHAsset]) {
        super.init(nibName: nil, bundle: nil)
        self.currentPage = selectIndex

        self.asserts = asserts
        self.imageSourceTp = .asserts
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = photoBrowserAnimator
    }
    
    private lazy var collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kJDScreenWidth , height: kJDScreenHeight )
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: kJDScreenWidth, height: kJDScreenHeight ), collectionViewLayout: layout)
        collectionView.register(JDPhotoBrowserCell.self, forCellWithReuseIdentifier: jdkresuId)
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = UIColor.black
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        return collectionView
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(collectionView)
        let indexPath = IndexPath(item: (currentPage ?? 0), section: 0)

        DispatchQueue.main.async {
            if indexPath.row <= ((self.images?.count ?? 0) - 1) || indexPath.row <= ((self.urls?.count ?? 0) - 1) || indexPath.row <= ((self.asserts?.count ?? 0) - 1){
            
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            }
        }
        
        photoBrowserAnimator.currentPage = (currentPage ?? 0)
        
        deleteBtn.frame = CGRect(x: kJDScreenWidth - 45, y: 30, width: 30, height: 30)
        deleteBtn.setBackgroundImage(UIImage(named: "delete"), for: .normal)
//        self.view.addSubview(deleteBtn)
//        deleteBtn.addTarget(self, action: #selector(delete(btn:)), for: .touchUpInside)
        
        self.view.addSubview(indexLabel)
        indexLabel.backgroundColor = UIColor.black
        indexLabel.textColor = UIColor.white
        indexLabel.textAlignment = .center
        indexLabel.frame = CGRect(x: 0, y: kJDScreenHeight - 40, width: 80, height: 30)
        indexLabel.centerX = kJDScreenWidth * 0.5
        
        
//        saveBtn.frame = CGRect(x: kJDScreenWidth - 80, y: indexLabel.y, width: 50, height: 50)
//        saveBtn.addTarget(self, action: #selector(saveImg), for: .touchUpInside)
//        self.view.addSubview(saveBtn)

        
        if  self.imageSourceTp == .image{
            guard let kcount  = images?.count else { return  }
            indexLabel.text = "\((currentPage ?? 0) + 1)/\(kcount)"
         }else if  self.imageSourceTp == .url{
            guard let kcount  = urls?.count else { return  }
            indexLabel.text = "\((currentPage ?? 0) + 1)/\(kcount)"
        }else if  self.imageSourceTp == .asserts{
            guard let kcount  = asserts?.count else { return  }
            indexLabel.text = "\((currentPage ?? 0) + 1)/\(kcount)"
        }
    }
    
    //删除
    @objc private func delete(btn: UIButton){
        if deleteButtonClosure != nil {
            deleteButtonClosure?((currentPage ?? 0))
        }
    }
    
    //--------懒加载--------
    fileprivate lazy var photoBrowserAnimator : JDPhotoBrowserAnimator = JDPhotoBrowserAnimator()
    private lazy var deleteBtn : UIButton = {
        let btn: UIButton = UIButton()
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    private lazy var saveBtn : UIButton = {
        let btn: UIButton = UIButton()
        btn.size = CGSize(width: 50, height: 50)
        btn.setBackGroundColor(color: UIColor.red, type: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    
//    @objc private func saveImg(){
//        let indexPath = IndexPath(item: (currentPage ?? 0), section: 0)
//        let cell = self.collectionView.cellForItem(at: indexPath) as! JDPhotoBrowserCell
//        
//        self.saveImageToPhotoAlbum1(saveImage: cell.backImg.image!)
//    }
//    
//    //保存照片
//    func saveImageToPhotoAlbum1(saveImage: UIImage){
//        UIImageWriteToSavedPhotosAlbum(saveImage, self, #selector(saveImageToo(image:didFinishSavingWithError:contextInfo:)), nil)
//    }
//    
//    func saveImageToo(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
//        if error != nil {
//            return
//        } else {
//        }
//        
//        
//    }
    

}

extension JDPhotoBrowser :UICollectionViewDelegate,UICollectionViewDataSource{
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if self.imageSourceTp == .image {
            return (self.images?.count)!
        }else if self.imageSourceTp == .url{
            return (self.urls?.count)!
        }else {
            return (self.asserts?.count)!
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jdkresuId, for: indexPath as IndexPath) as! JDPhotoBrowserCell
        cell.scrollView.setZoomScale(1, animated: false)
    
        
        if self.imageSourceTp == .image {
            cell.image = self.images?[indexPath.item]
        }else if self.imageSourceTp == .url{
            cell.imageUrl = self.urls?[indexPath.item]
        }else if self.imageSourceTp == .asserts{
            cell.assert = self.asserts?[indexPath.item]

        }
        
        
        cell.cellPhotoBrowserAnimator = photoBrowserAnimator

        return cell
    }

    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }
    
     func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    }
    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.width)
        lastPage = currentPage!
        photoBrowserAnimator.currentPage = currentPage ?? 0
        
                
    }

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        

        if self.endPageIndexClosure != nil {
            endPageIndexClosure?(currentPage ?? 0)
        }
        
    }
    
}



