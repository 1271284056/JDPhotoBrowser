//
//  UIView+Extension.swift


import UIKit

let kJDScreenWidth = UIScreen.main.bounds.size.width
let kJDScreenHeight = UIScreen.main.bounds.size.height

//  对UIView的扩展
extension UIView {
    
    //获取当前控制器
     public func getCurrentVc() -> UIViewController? {
        var next = self.next
        repeat {
            if (next?.isKind(of: UIViewController.self))! {
                return next as? UIViewController
            }
            next = next?.next
        }while (next != nil)
        return nil
    }
    
    //  扩展计算属性
    //  x坐标
    public var JDx: CGFloat {
        get {
            return frame.origin.x
        } set {
            frame.origin.x = newValue
        }
    }
    //  y坐标
    public var JDy: CGFloat {
        get {
            return frame.origin.y
        } set {
            frame.origin.y = newValue
        }
    }
    
    //  宽度
    public var JDwidth: CGFloat {
        
        get {
            return frame.size.width
        } set {
            frame.size.width = newValue
        }
        
        
    }
    //  高度
    public var JDheight: CGFloat {
        get {
            return frame.size.height
        } set {
            frame.size.height = newValue
        }
    }
    
    //  中心x
    public var JDcenterX: CGFloat {
        get {
            return center.x
        } set {
            center.x = newValue
        }
    }
    
    //  中心y
    public var JDcenterY: CGFloat {
        get {
            return center.y
        } set {
            center.y = newValue
        }
    }
    
    //  获取或者设置size大小
    public var JDsize: CGSize {
        get {
            return frame.size
        } set {
            frame.size = newValue
        }
    }
    
    /// 右边界的x值
    public var JDmaxX: CGFloat{
        get{
            return self.JDx + self.JDwidth
        }
        set{
            var r = self.frame
            r.origin.x = newValue - frame.size.width
            self.frame = r
        }
    }
    
    // 下边界的y值
    public var JDmaxY: CGFloat{
        get{
            return self.JDy + self.JDheight
        }
        set{
            var r = self.frame
            r.origin.y = newValue - frame.size.height
            self.frame = r
        }
    }
    
     var JDorigin: CGPoint{
        get{
            return self.frame.origin
        }
        set{
            self.JDx = newValue.x
            self.JDy = newValue.y
        }
    }
    
    //等分九宫格
    public func jiuDengFrame(index: Int,column: CGFloat,viW: CGFloat,viH: CGFloat,topMargin: CGFloat){
        let margin = (kJDScreenWidth - column * viW)/(column + 1)
        let col  = CGFloat(index % Int(column)) //列
        let row  = CGFloat(index / Int(column)) //行
        let viewX = margin +  col * (viW + margin)
        let viewY = topMargin + row * (viH + topMargin)
        self.frame = CGRect(x: viewX, y: viewY, width: viW, height: viH)
    }
    
}


extension UIButton {
    
    public enum btnType {
        case normal
        case selected
        case disable
        case highlighted
    }
    
    public convenience init(textColor: UIColor, fontSize: CGFloat) {
        //  使用当前self调用其他构造函数
        self.init()
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.setTitleColor(textColor, for: .normal)
    }
    
    public func setBackGroundColor(color: UIColor,type: btnType){
        let rect = CGRect(x: 0, y: 0, width: self.JDwidth, height: self.JDheight)
        UIGraphicsBeginImageContext(rect.size)
        //        print(rect)
        if rect.width<=0 || rect.height<=0 {
            return
        }
        let  context: CGContext = (UIGraphicsGetCurrentContext())!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if type == .normal{
            self.setBackgroundImage(img, for: .normal)
        }else if type == .selected{
            self.setBackgroundImage(img, for: .selected)
        }else if type == .highlighted{
            self.setBackgroundImage(img, for: .highlighted)
        }
    }
    
}

