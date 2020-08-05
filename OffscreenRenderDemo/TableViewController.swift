//
//  TableViewController.swift
//  OffscreenRenderDemo
//
//  Created by seedante on 16/4/20.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit


/*
 什么情况会造成离屏渲染：
 shouldRasterize，masks，shadows，edge antialiasing（抗锯齿），group opacity（不透明），渐变
 在使用圆角、阴影和遮罩等视图功能的时候，图层属性的混合体被指定为在未预合成之前不能直接在屏幕中绘制，所有就需要在屏幕外的上下文中渲染，即离屏渲染
 
 
 离屏渲染卡顿原因：
 离屏渲染之所以会特别消耗性能，是因为要创建一个屏幕外的缓冲区，然后从当屏缓冲区切换到屏幕外的缓冲区，然后再完成渲染；其中，创建缓冲区和切换上下文最消耗性能，而绘制其实不是性能损耗的主要原因。
 
 
 
 光栅化：
 栅（shān）格化，是PS中的一个专业术语，栅格即像素，栅格化即将矢量图形转化为位图（栅格图像）。最基础的栅格化算法将多边形表示的三维场景渲染到二维表面。
 
 CALayer 有一个 shouldRasterize 属性，将这个属性设置成 true 后就开启了光栅化。开启shouldRasterize后,CALayer会被栅格化为bitmap,layer的阴影等效果也会被保存到bitmap中，光栅化后会将图层绘制到一个屏幕外的图像，然后这个图像将会被缓存起来并绘制到实际图层的 contents 和子图层，对于有很多的子图层或者有复杂的效果应用，这样做就会比重绘所有事务的所有帧来更加高效。但是光栅化原始图像需要时间，而且会消耗额外的内存。
 
 View Debug:
 
 Color Blended Layers
 
 这个选项基于渲染程度对屏幕中的混合区域进行绿到红的高亮（也就是多个半透明图层的叠加）。由于重绘的原因，混合对GPU性能会有影响，同时也是滑动或者动画帧率下降的罪魁祸首之一
 
 
 Color Hits Green and Misses Red
 
 当设置shouldRasterizep属性为YES的时候，耗时的图层绘制会被缓存，然后当做一个简单的扁平图片呈现。当缓存再生的时候这个选项就用红色对栅格化图层进行了高亮。如果缓存频繁再生的话，就意味着栅格化可能会有负面的性能影响了
 
 Color Offscreen-Rendered Yellow
 
 开启后会把那些需要离屏渲染的图层高亮成黄色，这就意味着黄色图层可能存在性能问题
 
 */

class TableViewController: UITableViewController {

    let cellIdentifier = "Cell"
    let avatorImageL = UIImage(named: "L80.png")
    let avatorImageR = UIImage(named: "R80.png")
    let blendImage = UIImage(named: "RecRoundMask.png")
    let maskImage = UIImage(named: "RoundMask.png")
    //    let maskImageNoEffect = UIImage(named: "L80.png")

    override func viewDidLoad() {
        super.viewDidLoad()

        /*GroupOpacity Test: No obvious impact to performance almost in this demo.*/
        //        enableGroupOpacityOn(view)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let labelL = cell.viewWithTag(30) as! UILabel
        let labelR = cell.viewWithTag(40) as! UILabel
        labelL.text = "OffscreenRender" + String(indexPath.row)
        labelR.text = String(indexPath.row) + "离屏渲染"

        //I test on iPad mini 1st generation, iOS 9.3.1, latter iOS devices maybe have better performance.

        //No effect Test
        displayCell(cell)

        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        /*RounderCorner Test*/

        //System Rounded Corner: if layer's contents is not nil, masksToBounds must be true. Is cornerRadius bigger, performance worse? No, when cornerRadius > 0, performance is same almost.
//            applySystemRoundedCornerOn(cell)

        /*RounedCorner solution:
         1. Redraw contents and clip as rouned corner contens;
         2. Blend with a view which has transparent part contents, like a mask. The best performance! Here I use a UIImageView with part transparent contents.
         */

        //Redraw in main thread, put it in background thread is better.
//                redrawRounedCornerInMainThreadOn(cell)  //在主线程中重新绘制UIImage

        //Redraw in background thread, performance is nice.
        //        redrawRoundedCornerInBackgroundThreadOn(cell)//在后台线程中重新绘制UIImage

        //This solution needs a image which is partly transparent. You can paint it by Sketch, PaintCode, or draw it with Core Graphics API.
//                blendRoundedCornerOn(cell)

        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        /*Shadow Test: shadow is not compatible with system rouned corner, because layer.masksToBounds can't be true in shadow affect.*/
                dropShadownOn(cell)

        //Optimization for shadow: a shadow path can cancel offscreen render effect
//                let avatorViewL = cell.viewWithTag(10) as! UIImageView
//                specifyShadowPathOn(avatorViewL)
//                let avatorViewR = cell.viewWithTag(20) as! UIImageView
//                specifyShadowPathOn(avatorViewR)

        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        /*Mask Test: Is maskLayer more transparent part, performance better? No obvious impact.*/
//                applyMaskOn(cell)

        /*-------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        //Ultimate solution: Rasterization, works for roundedCorner, shadow, mask and has very good performance.
//                enableRasterizationOn(cell)

        //Simulate danamic content
//        dynamicallyUpdateCell(cell)
        return cell
    }

    /*
     出现离屏渲染，帧率平均在 55fps，GPU使用率在80% (iPhone 6plus iOS 10.2.4)
     没有出现离屏渲染，帧率平均在56fps，GPU使用率在8%(iPhone Xs iOS 12.4)
     */
    @objc func dynamicallyUpdateCell(_ cell: UITableViewCell){

        let number = Int(UInt32(arc4random()) % UInt32(10))

        let labelL = cell.viewWithTag(30) as! UILabel
        labelL.text = "OffscreenRender" + String(number)

        let labelR = cell.viewWithTag(40) as! UILabel
        labelR.text = String(number) + "离屏渲染"


        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        avatorViewL.layer.cornerRadius = CGFloat(number)
        avatorViewL.clipsToBounds = true

        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewR.layer.cornerRadius = CGFloat(number)
        avatorViewR.clipsToBounds = true

        let delay = TimeInterval(number) * 0.1
        perform(#selector(TableViewController.dynamicallyUpdateCell(_:)), with: cell, afterDelay: delay)
    }

    func displayCell(_ cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        avatorViewL.image = avatorImageL

        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewR.image = avatorImageR
    }

    /*
     运行在iOS 12.4,不存在离屏渲染,fps 达到58接近60 （iPhone Xs iOS 12.4）
     
     运行在iOS 10.2.1,圆角触发离屏渲染, fps平均达到50以上，GPU使用率达到80%以上(iPhone 6plus iOS 10.2.4)
     
     说明在iOS 12上苹果对 UIImageView 离屏渲染进行优化，不会出现这种情况
     */
    func applySystemRoundedCornerOn(_ cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewL.layer.cornerRadius = 10
        avatorViewL.layer.masksToBounds = true

        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewR.image = avatorImageR
        avatorViewR.layer.cornerRadius = 10
        avatorViewR.layer.masksToBounds = true
    }

    
    /// 直接在主线程中重新绘制圆角
    /// - Parameter cell: UITableViewCell
    
    /*
     不存在离屏渲染，帧率平均达到53fps，GPU使用率达到20% iPhone 6plus
     不存在离屏渲染，帧率平均达到56fps，GPU使用率达到10% iPhone Xs
     */
    func redrawRounedCornerInMainThreadOn(_ cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let roundedCornerImageL = drawImage(image: avatorImageL!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
        avatorViewL.image = roundedCornerImageL


        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        let roundedCornerImageR = drawImage(image: avatorImageR!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
        avatorViewR.image = roundedCornerImageR

    }

    
    /// 在后台线程重新绘制圆角
    /// - Parameter cell: UITableViewCell
    func redrawRoundedCornerInBackgroundThreadOn(_ cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView

        DispatchQueue.global(qos: .default).async {
            let roundedCornerImageL = drawImage(image: self.avatorImageL!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
            let roundedCornerImageR = drawImage(image: self.avatorImageR!, rectSize: CGSize(width: 80, height: 80), roundedRadius: 10.0)
            DispatchQueue.main.async {
                avatorViewL.image = roundedCornerImageL
                avatorViewR.image = roundedCornerImageR
            }
        }
    }

    //使用混合图层解决圆角问题
    func blendRoundedCornerOn(_ cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewR.image = avatorImageR

        let blendViewL =  cell.viewWithTag(50) as! UIImageView
        blendViewL.image = blendImage
        blendViewL.isHidden = false

        let blendViewR =  cell.viewWithTag(60) as! UIImageView
        blendViewR.image = blendImage
        blendViewR.isHidden = false
    }

    
    /*
     会出现离屏渲染，帧率在30fps以下，GPU使用率平均在80% （iPhone 6plus iOS 10.2.4） 耗电严重
     会出现离屏渲染，平均帧率在55fps，GPU使用率平均在50% （iPhone Xs iOS 12.4）耗电严重
     */
    /// - Parameter cell: UITableViewCell
    func dropShadownOn(_ cell: UITableViewCell){
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewR.image = avatorImageR

        avatorViewL.layer.shadowColor = UIColor.red.cgColor
        avatorViewL.layer.shadowOffset = CGSize(width: 5, height: 5)
        avatorViewL.layer.shadowOpacity = 1

        avatorViewR.layer.shadowColor = UIColor.red.cgColor
        avatorViewR.layer.shadowOffset = CGSize(width: 5, height: 5)
        avatorViewR.layer.shadowOpacity = 1
    }

    //Optimization for shadow
    
    /*
     使用阴影路径方式添加阴影
     不会出现离屏渲染，帧率平均在55fps，GPU使用率平均在20%左右 （iPhone 6plus iOS 10.2.4）
     不会出现离屏渲染，帧率平均在55fps，GPU使用率平均在8%左右 （iPhone Xs iOS 12.4）
     */
    /// - Parameter view: UIView
    func specifyShadowPathOn(_ view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor;
        view.layer.shadowOffset = CGSize(width: 5, height: 5);
        view.layer.shadowOpacity = 1.0;
        view.layer.shadowRadius = 5;
        let path = UIBezierPath(rect: view.bounds)
        view.layer.shadowPath = path.cgPath //当将这句话注释完，会出现离屏渲染，卡顿严重 （iPhone 6Plus ,iPhone Xs）
    }

    
    /*
     通过Mask UIImageView实现圆角
     出现离屏渲染，帧率平均在55fps，GPU占用率在40% （iPhone Xs iOS 12.4）耗电
     
     出现离屏渲染，帧率平均在45fps，GPU占用率在85% （iPhone 6 Plus iOS 10.2.4） 耗电
     */
    /// - Parameter cell: UITableViewCell
    func applyMaskOn(_ cell: UITableViewCell) {
        let avatorViewL = cell.viewWithTag(10) as! UIImageView
        let avatorViewR = cell.viewWithTag(20) as! UIImageView
        avatorViewL.image = avatorImageL
        avatorViewR.image = avatorImageR

        if #available(iOS 8.0, *) {
            avatorViewL.mask = UIImageView(image: maskImage)
            avatorViewR.mask = UIImageView(image: maskImage)
        } else {
            let maskLayer1 = CALayer()
            maskLayer1.frame = avatorViewL.bounds
            maskLayer1.contents = maskImage?.cgImage
            avatorViewL.layer.mask = maskLayer1

            let maskLayer2 = CALayer()
            maskLayer2.frame = avatorViewR.bounds
            maskLayer2.contents = maskImage?.cgImage
            avatorViewR.layer.mask = maskLayer2
        }

        //Or use CAShapeLayer
        //        let roundedRectPath = UIBezierPath(roundedRect: avatorViewL.bounds, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: 10, height: 10))
        //        let shapeLayerL = CAShapeLayer()
        //        shapeLayerL.path = roundedRectPath.CGPath
        //        avatorViewL.layer.mask = shapeLayerL
        //
        //        let shapeLayerR = CAShapeLayer()
        //        shapeLayerR.path = roundedRectPath.CGPath
        //        avatorViewR.layer.mask = shapeLayerR
    }

    func enableGroupOpacityOn(_ view: UIView) {
        /*
         Group Opacity Test:

         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         var allowsGroupOpacity: Bool

         Discussion:

         When the value is YES and the layer’s opacity property value is less than 1.0, the layer is allowed to composite itself as a group separate from its parent.
         This gives correct results when the layer contains multiple opaque components, but may reduce performance.

         The default value is read from the boolean UIViewGroupOpacity property in the main bundle’s Info.plist file.
         If no value is found, the default value is YES for apps linked against the iOS 7 SDK or later and NO for apps linked against an earlier SDK.
         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         In WWDC 2014 419: Advanced Graphics and Animation Performance, performance consideration:

         Will introduce offscreen passes:
         If layer is not opaque (opacity != 1.0)
         And if layer has nontrivial content (child layers or background image)
         -->Sub view hierarchy needs to be composited before being blended
         Always turn it off if not needed.

         layer's opacity = view's alpha
         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         So, `allowsGroupOpacity` is `true` in this project with default configuration.
         But in UITableView, 'cell.alpha != 1.0' can't trigger offscreen render and can't change alpha actualy, cell.contentView.alpha do.
         How trigger offscreen render on cell? Set 'tableView.alpha != 1.0', you can check it with `Color Offscreen-Rendered Yellow` in Core Animation Instruments.
         But(again), no impact to scroll performance.
         You can easily get offscreen render on general view which has subview by change its alpha < 1.
         -------------------------------------------------------------------------------------------------------------------------------------------------------------
         */
        view.alpha = 0.9
    }

    /*
     //Ultimate Solution: Rasterization

     Typical use cases:
     Avoid redrawing expensive effects for static content
     Avoid redrawing of complex view hierarchies
     
     使用光栅化
     
     出现离屏渲染，帧率平均在55fps，一开始帧率偏低在30fps，后面帧率稳定在55fps，GPU占用率在40% （iPhone 6plus iOS 10.2.4）
     出现离屏渲染，帧率平均在56fps，GPU占用率在18% （iPhone Xs iOS 12.4）
     
     tip：
     出现离屏渲染，内容经常变化时，使用光栅化 会消耗更多的GPU资源，从而导致卡顿严重 （在内容不变化，复杂界面使用光栅化比较 友好）
     
     */
    func enableRasterizationOn(_ view: UIView) {
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale;
    }
}
