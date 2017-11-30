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

public class JDPhotoBrowser: UIViewController {
    fileprivate let imageViewSpace: CGFloat = 25
    var collectionView1: UICollectionView!
    var imageRectDict: [IndexPath: CGRect] = [IndexPath: CGRect]()
    var isViewAppeared: Bool = false
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppeared = true
    }
    
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
    
    //1111 url
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
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: kJDScreenWidth , height: kJDScreenHeight )
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = imageViewSpace
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, imageViewSpace)
        var bounds = self.view.bounds
        bounds.size.width += imageViewSpace
        collectionView1 = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView1.backgroundColor = UIColor.black
        collectionView1.showsVerticalScrollIndicator = false
        collectionView1.showsVerticalScrollIndicator = false
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.register(JDPhotoBrowserCell.self, forCellWithReuseIdentifier: jdkresuId)
        collectionView1.isPagingEnabled = true
        collectionView1.showsHorizontalScrollIndicator = false
        collectionView1.alwaysBounceHorizontal = true
        collectionView1.contentOffset = CGPoint(x: collectionView1.bounds.size.width * CGFloat(currentPage!), y: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.setupCollectionView()
        self.view.addSubview(collectionView1)
        let indexPath = IndexPath(item: (currentPage ?? 0), section: 0)
        DispatchQueue.main.async {
            if indexPath.row <= ((self.images?.count ?? 1) - 1) || indexPath.row <= ((self.urls?.count ?? 1) - 1) || indexPath.row <= ((self.asserts?.count ?? 1) - 1){
            self.collectionView1.scrollToItem(at: indexPath, at: .left, animated: false)
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
        indexLabel.JDcenterX = kJDScreenWidth * 0.5
        
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
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //隐藏状态栏
        let statusBar = UIApplication.shared.value(forKey: "statusBar")
        (statusBar as! UIView).JDy = -UIApplication.shared.statusBarFrame.size.height
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //恢复状态栏
        let statusBar = UIApplication.shared.value(forKey: "statusBar")
        (statusBar as! UIView).JDy = 0
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
        btn.JDsize = CGSize(width: 50, height: 50)
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
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.imageSourceTp == .image {
            return (self.images?.count)!
        }else if self.imageSourceTp == .url{
            return (self.urls?.count)!
        }else {
            return (self.asserts?.count)!
        }
    }
    
     public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

      public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }
    
     public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    }
    
     public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.JDwidth)
        lastPage = currentPage!
        photoBrowserAnimator.currentPage = currentPage ?? 0
    }

     public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if self.endPageIndexClosure != nil {
            endPageIndexClosure?(currentPage ?? 0)
        }
    }
    
}



