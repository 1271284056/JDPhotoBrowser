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
        //        var num = 0
        repeat {
            if (next?.isKind(of: UIViewController.self))! {
                return next as? UIViewController
            }
            next = next?.next
        }while (next != nil)
        return nil
    }
    
    public func jiuFrame(index: Int,column: CGFloat,viW: CGFloat,viH: CGFloat,leftMargin: CGFloat,topMargin: CGFloat){
        let middleM = (kJDScreenWidth - 2 * leftMargin - column * viW)/(column - 1)
        let col  = CGFloat(index % Int(column)) //列
        let row  = CGFloat(index / Int(column)) //行
        let viewX = leftMargin +  col * (viW + middleM)
        let viewY = topMargin + row * (viH + topMargin)
        self.frame = CGRect(x: viewX, y: viewY, width: viW, height: viH)
    }
    
    //等分九宫格
    public func jiuFrame(index: Int,column: CGFloat,viW: CGFloat,viH: CGFloat,topMargin: CGFloat){
        let margin = (kJDScreenWidth - column * viW)/(column + 1)
        let col  = CGFloat(index % Int(column)) //列
        let row  = CGFloat(index / Int(column)) //行
        let viewX = margin +  col * (viW + margin)
        let viewY = topMargin + row * (viH + topMargin)
        self.frame = CGRect(x: viewX, y: viewY, width: viW, height: viH)
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
    
    //  扩展计算属性
    //  x坐标
    public var x: CGFloat {
        get {
            return frame.origin.x
        } set {
            frame.origin.x = newValue
        }
    }
    //  y坐标
    public var y: CGFloat {
        get {
            return frame.origin.y
        } set {
            frame.origin.y = newValue
        }
    }
    
    //  宽度
    public var width: CGFloat {
        
        get {
            return frame.size.width
        } set {
            frame.size.width = newValue
        }
        
        
    }
    //  高度
    public var height: CGFloat {
        
        get {
            return frame.size.height
        } set {
            frame.size.height = newValue
        }
        
        
    }
    
    //  中心x
    public var centerX: CGFloat {
        get {
            return center.x
        } set {
            center.x = newValue
        }
    }
    
    //  中心y
    public var centerY: CGFloat {
        get {
            return center.y
        } set {
            center.y = newValue
        }
    }
    
    //  获取或者设置size大小
    public var size: CGSize {
        get {
            return frame.size
        } set {
            frame.size = newValue
        }
    }
    
    /// 右边界的x值
    public var maxX: CGFloat{
        get{
            return self.x + self.width
        }
        set{
            var r = self.frame
            r.origin.x = newValue - frame.size.width
            self.frame = r
        }
    }
    
    // 下边界的y值
    public var maxY: CGFloat{
        get{
            return self.y + self.height
        }
        set{
            var r = self.frame
            r.origin.y = newValue - frame.size.height
            self.frame = r
        }
    }
    
    public var origin: CGPoint{
        get{
            return self.frame.origin
        }
        set{
            self.x = newValue.x
            self.y = newValue.y
        }
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
        
        let rect = CGRect(x: 0, y: 0, width: self.width, height: self.height)
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




extension UIColor {
    //类方法 static func
    public static func colorWithHex(hexColor:Int64)->UIColor{
        
        let red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0;
        let green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0;
        let blue = ((CGFloat)(hexColor & 0xFF))/255.0;
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
        
    }
}
