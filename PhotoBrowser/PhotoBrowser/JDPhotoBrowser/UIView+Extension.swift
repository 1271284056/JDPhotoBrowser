//  
//  UIView+Extension.swift


import UIKit

//  对UIView的扩展
extension UIView {

    //  扩展计算属性
    //  x坐标
    var x: CGFloat {
        get {
            return frame.origin.x
        } set {
            frame.origin.x = newValue
        }
    }
    //  y坐标
    var y: CGFloat {
        get {
            return frame.origin.y
        } set {
            frame.origin.y = newValue
        }
    }
    
    //  宽度
    var width: CGFloat {
    
        get {
            return frame.size.width
        } set {
            frame.size.width = newValue
        }
        
        
    }
    //  高度
    var height: CGFloat {
        
        get {
            return frame.size.height
        } set {
            frame.size.height = newValue
        }
        
        
    }
    
    //  中心x
    var centerX: CGFloat {
        get {
            return center.x
        } set {
            center.x = newValue
        }
    }
    
    //  中心y
    var centerY: CGFloat {
        get {
            return center.y
        } set {
            center.y = newValue
        }
    }
    
    //  获取或者设置size大小
    var size: CGSize {
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
    
    //获取当前控制器
    func getCurrentVc() -> UIViewController? {
        var next = self.next
        repeat {
            if (next?.isKind(of: UIViewController.self))! {
                return next as? UIViewController
            }
            next = next?.next
        }while (next != nil)
        return nil
    }
        
    //等分九宫格
    func jiuDengFrame(index: Int,column: CGFloat,viW: CGFloat,viH: CGFloat,topMargin: CGFloat){
        let margin = (kJDScreenWidth - column * viW)/(column + 1)
        let col  = CGFloat(index % Int(column)) //列
        let row  = CGFloat(index / Int(column)) //行
        let viewX = margin +  col * (viW + margin)
        let viewY = topMargin + row * (viH + topMargin)
        self.frame = CGRect(x: viewX, y: viewY, width: viW, height: viH)
    }

}
