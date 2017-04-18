//
//  JDPhotoBrowser
//
//
//  Created by 张江东 on 17/3/3.
//  Copyright © 2017年 58kuaipai. All rights reserved.
//  邮箱 1271284056@qq.com  简书 http://www.jianshu.com/u/5e7182f9e694

import UIKit

fileprivate let resuId = "ZJPhotoBrowserId"

let kJDScreenWidth = UIScreen.main.bounds.size.width
let kJDScreenHeight = UIScreen.main.bounds.size.height

class JDPhotoBrowser: UIViewController {
    
    enum imageSourceType {
        case image
        case url
    }
    ///图片的url字符串数组
    var urls:[String]?
    var images: [UIImage]?
    //传回当前浏览器图片索引
    var endPageIndexClosure: (( _ index: Int)->())?
    var imageSourceTp: imageSourceType = .image
    var deleteButtonClosure: (( _ index: Int)->())?  //点击删除按钮时index
    private lazy var indexLabel = UILabel()

    var sourceImageView: UIImageView?{
        didSet{
            photoBrowserAnimator.sourceImageView = sourceImageView
            photoBrowserAnimator.endImageView = sourceImageView
            photoBrowserAnimator.superVc = self
        }
    } // 来源view
    var endImageView: UIImageView?{
        didSet{
            photoBrowserAnimator.endImageView = endImageView
        }
    } // 消失时候imageview
    ///静止后选中照片的索引
    var currentPage : Int?{
        didSet{
            if self.imageSourceTp == .image {
                guard let kcount  = images?.count else { return  }
                indexLabel.text = "\(currentPage! + 1)/\(kcount)"
            }else{
                guard let kcount  = urls?.count else { return  }
                indexLabel.text = "\(currentPage! + 1)/\(kcount)"
            }
        }
    }
    
    //使用方法
    init(selectIndex: Int, urls: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.currentPage = selectIndex
        self.urls = urls
        self.imageSourceTp = .url
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = photoBrowserAnimator
    }
    
    //第一个0
    init(selectIndex: Int, images: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        self.currentPage = selectIndex
        self.images = images
        self.imageSourceTp = .image
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = photoBrowserAnimator
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kJDScreenWidth , height: kJDScreenHeight )
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: kJDScreenWidth, height: kJDScreenHeight ), collectionViewLayout: layout)
        collectionView.register(JDPhotoBrowserCell.self, forCellWithReuseIdentifier: resuId)
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = UIColor.black
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(collectionView)
        let indexPath = IndexPath(item: currentPage!, section: 0)

        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
        
        photoBrowserAnimator.currentPage = currentPage!
        deleteBtn.frame = CGRect(x: kJDScreenWidth - 100, y: kJDScreenHeight - 60, width: 60, height: 40)
        deleteBtn.backgroundColor = UIColor.red
//        self.view.addSubview(deleteBtn)
        deleteBtn.addTarget(self, action: #selector(delete(btn:)), for: .touchUpInside)
        
        self.view.addSubview(indexLabel)
        indexLabel.backgroundColor = UIColor.black
        indexLabel.textColor = UIColor.white
        indexLabel.textAlignment = .center
        indexLabel.frame = CGRect(x: 0, y: deleteBtn.y, width: 50, height: 30)
        indexLabel.centerX = kJDScreenWidth * 0.5
        
        if  self.imageSourceTp == .image{
            guard let kcount  = images?.count else { return  }
            indexLabel.text = "\(currentPage! + 1)/\(kcount)"
         }else{
            guard let kcount  = urls?.count else { return  }
            indexLabel.text = "\(currentPage! + 1)/\(kcount)"
        }
    }
    
    //删除
    @objc private func delete(btn: UIButton){
        if deleteButtonClosure != nil {
            deleteButtonClosure?(currentPage!)
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

}

extension JDPhotoBrowser :UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if self.imageSourceTp == .image {
            return (self.images?.count)!
        }else{
            return (self.urls?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: resuId, for: indexPath as IndexPath) as! JDPhotoBrowserCell
        
        cell.cellPhotoBrowserAnimator = photoBrowserAnimator
        
        if self.imageSourceTp == .image {
            cell.image = self.images?[indexPath.item]
        }else{
            cell.imageUrl = self.urls?[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        currentPage  = Int(scrollView.contentOffset.x / scrollView.width)
        photoBrowserAnimator.currentPage = currentPage!
        if self.endPageIndexClosure != nil {
            endPageIndexClosure?(currentPage!)
        }
        
    }
    
}



