//
//  PieChart.swift
//  JRswift-piechart
//
//  Created by User on 11/20/15.
//  Copyright © 2015 jrjithin. All rights reserved.
//
import UIKit

public protocol PiechartDelegate {
    func setSubtitle() -> String
    func setChartTitle(total:Float) -> String
    func setImageForItemat(index: Int) -> UIImage
    func setTextForSlice(at:Int) -> String
}


/**
 * Piechart
 */
public class Piechart: UIView {
    
    
    let PI:CGFloat = CGFloat(M_PI)
    let PI_2:CGFloat = CGFloat(M_PI_2)
    
    /**
     * Dimens
     **/
    public struct Dimens{
        public var text_label_width: CGFloat = 40
        public var text_label_height: CGFloat = 20
        public var text_pos_from_center: CGFloat = 32
        public var text_Font_size :CGFloat = 11
        public var title_height :CGFloat = 20
        public var sub_title_height :CGFloat = 15
        public var title_width_by_2 :CGFloat = 55
    }
    
    /**
     * Slice
     */
    public struct Slice {
        public var color: UIColor!
        public var value: CGFloat!
        public var text: String!
    }
    /**
     * Slice_icon
     */
    public struct SliceIcon {
        public var color: UIColor!
        public var image: String!
        public var label:String!
    }
    /**
     * Radius
     */
    public struct Radius {
        public let inner: CGFloat = 65
        public let outer: CGFloat = 70
        public let line: CGFloat = 90
        public let icon_radius : CGFloat = 15
        public let icon_center: CGFloat = 105
        public let lineWidth: CGFloat = 3
        public let circleWidth: CGFloat = 3
    }
    
    /**
     * private
     */
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var infoLabel: UILabel!
    
    
    /**
     * public
     */
    public var radius: Radius = Radius()
    public var dims: Dimens = Dimens()
    public var activeSlice: Int = 0
    public var delegate: PiechartDelegate?
    
    public var title: String = "title"
    public var subtitle: String = "subtitle"
    public var info: String = "info"
    
    public var slices: [Slice] = []
    public var divisions:[Float] = []
    public var colors:[UIColor] = []
    
    public var total:Float = 0.0
    let transition = CATransition()
    
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        transition.startProgress = 0
        transition.endProgress = 1.0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionMoveIn
        transition.duration = 1.0;
        
    }
    
    convenience init() {
        self.init(frame: CGRectMake(0, 0, 200, 200))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       self.backgroundColor = UIColor.clearColor()
        
        // self.addTarget(self, action: "click", forControlEvents: .TouchUpInside)
        transition.startProgress = 0
        transition.endProgress = 1.0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionMoveIn
        transition.duration = 1.0;
       
    }
    //*create slices from divisions
    func createSlicesFromDivisions(){
        getTotal()
        slices = []
        for(index,division) in divisions.enumerate(){
            
            var slice = Slice()
            slice.color=colors[index]
            slice.text="random"
            slice.value=CGFloat(division/total)
            slices.append(slice)
        }
        
    }
    //get tottal from divisions
    
    func getTotal(){
        total=0
        for(_,division) in divisions.enumerate(){
            
            total=total + division
        }
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        var startValue: CGFloat = 0
        var startAngle: CGFloat = 0
        var endValue: CGFloat = 0
        var endAngle: CGFloat = 0
        var midValue: CGFloat = 0
        var middleAngle: CGFloat = 0
        
        var layers: [CAShapeLayer] = []
        
        for (_, slice) in slices.enumerate() {
            
            startAngle = (startValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            endValue = startValue + slice.value
            endAngle = (endValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            midValue = startValue + slice.value/2
            middleAngle = (midValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            
            
            let path = UIBezierPath()
            
            let shapeLayer = CAShapeLayer()
            
            path.moveToPoint(center)
            path.addArcWithCenter(center, radius: radius.outer, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            shapeLayer.path = path.CGPath
            shapeLayer.fillColor = slice.color.CGColor
            shapeLayer.strokeColor = slice.color.CGColor
            shapeLayer.lineWidth = radius.lineWidth
            shapeLayer.fillRule = kCAFillModeBackwards
            shapeLayer.addAnimation(transition, forKey: "transition")
            layers.append(shapeLayer)
            
            
            
            // increase start value for next slice
            startValue += slice.value
            
        }
        // create center donut hole
        let innerPath = UIBezierPath()
        innerPath.moveToPoint(center)
        innerPath.addArcWithCenter(center, radius: radius.inner, startAngle: 0, endAngle: 2 * PI, clockwise: true)
        
        
        let innerLayer = CAShapeLayer()
        innerLayer.path = innerPath.CGPath
        innerLayer.fillColor = UIColor.whiteColor().CGColor
        innerLayer.strokeColor = UIColor.whiteColor().CGColor
        innerLayer.fillRule = kCAFilterNearest
        
        let timePieEnd = drawPieLayers(layers,innerLayer: innerLayer)
        var iconLayers: [CAShapeLayer] = []
        var iconDonuts: [CAShapeLayer] = []
        var isPreviousValueSmall: Bool
        var isPreviousExtended : Bool = false
        var count = slices.count
        startValue = 0
        for (index, slice) in slices.enumerate() {
            
            isPreviousValueSmall = slices[count - 1 ].value < 0.05 ? true : false
            
            startAngle = (startValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            endValue = startValue + slice.value
            endAngle = (endValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            midValue = startValue + slice.value/2
            middleAngle = (midValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            var iconCenterRadius = radius.line
            
            
            //create join line to icon image
            let line = UIBezierPath()
            line.moveToPoint(getCirclePoint(radius.outer + 1, centre: center, angle: middleAngle))
            if isPreviousValueSmall && slice.value < 0.05 && isPreviousExtended{
                iconCenterRadius = radius.line
                isPreviousExtended = false
            }else if isPreviousValueSmall && slice.value < 0.05 && !isPreviousExtended{
                iconCenterRadius = radius.line + 2 * radius.icon_radius
                isPreviousExtended = true
            }else{
                isPreviousExtended = false
            }
            line.addLineToPoint(getCirclePoint(iconCenterRadius, centre: center, angle: middleAngle))
            line.lineWidth = radius.lineWidth
            let linelayer = CAShapeLayer()
            linelayer.path = line.CGPath
            linelayer.fillColor = slice.color.CGColor
            linelayer.strokeColor = slice.color.CGColor
            
            
            //Draw icon circle
            let iconCenter = getCirclePoint(iconCenterRadius + radius.icon_radius, centre: center, angle: middleAngle)
            
            let circle_out = drawCircle(iconCenter, radius: radius.icon_radius, color: slice.color)
            let layerIcon = drawCircle(iconCenter, radius: radius.icon_radius - radius.circleWidth, color: UIColor.whiteColor())
            
            
            circle_out.addSublayer(linelayer)
            iconLayers.append(circle_out)
            
            //add icon and text
            
            if middleAngle > 1.2 && middleAngle < 2.25{
                //add text at bottom of icon if it is at the bottom
                layerIcon.addSublayer(addText(CGRectMake(iconCenter.x - dims.text_label_width/2 , iconCenter.y + dims.text_pos_from_center  - dims.text_label_height , 40, dims.text_label_height) , index: index))
            }else{
                layerIcon.addSublayer(addText(CGRectMake(iconCenter.x - dims.text_label_width/2, iconCenter.y - dims.text_pos_from_center, 40, dims.text_label_height) , index: index))
            }
            layerIcon.addSublayer(addIcon(iconCenter, size: 20, color: slice.color,index: index).layer)
            addCAAnimation(layerIcon, point: iconCenter)
            iconDonuts.append(layerIcon)
            //  addCAAnimation(layers[index], point: iconCenter)
        
            // increase start value for next slice
            startValue += slice.value
            count = count % slices.count + 1
        }
        //Draw icons
        let time_icon_end = drawIcons(iconLayers,iconDonuts:iconDonuts,after: timePieEnd)
        addTitle(center,after: time_icon_end)
    }
    
    func getCirclePoint(radius: CGFloat,centre: CGPoint,angle:CGFloat)->CGPoint{
        var X: CGFloat?
        var Y: CGFloat?
        var point: CGPoint
        let adjustedradius = radius - 5
        
        
        X = centre.x + adjustedradius * cos(angle )
        Y = centre.y + adjustedradius * sin(angle )
        
        point = CGPointMake( X!, Y!)
        
        
        return point
    }
    
    func drawCircle(center:CGPoint , radius:CGFloat , color: UIColor) -> CAShapeLayer{
        
        
        let circle = UIBezierPath()
        
        let shapeLayer = CAShapeLayer()
        
        circle.moveToPoint(center)
        circle.addArcWithCenter(center, radius: radius, startAngle: 0, endAngle: 2 * PI, clockwise:true)
        
        shapeLayer.path = circle.CGPath
        shapeLayer.fillColor = color.CGColor
        shapeLayer.strokeColor = color.CGColor;
        shapeLayer.lineWidth = 1.0;
        shapeLayer.fillRule = kCAFillRuleNonZero;
        
        
        return shapeLayer
    }
    //adds icon image at the given point
    func addIcon(at:CGPoint,size: CGFloat, color: UIColor, index: Int) -> UIImageView{
        
        let iconView = UIImageView(frame: CGRectMake(0, 0, size, size))
        iconView.center = at
        iconView.image = delegate?.setImageForItemat(index)
        iconView.image = iconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        iconView.tintColor = color
        return iconView
    }
    func drawPieLayers(layers: [CAShapeLayer] , innerLayer: CAShapeLayer) -> Double{
        var cftime: CFTimeInterval = layer.convertTime(CACurrentMediaTime() , fromLayer: nil)
        for (index,layer) in layers.enumerate(){
            
            cftime += Double(slices[index].value)
            if index < layers.count - 1 {
                layers[index + 1].beginTime = cftime
                layers[index + 1].timeOffset = Double(slices[index+1].value)
                //innerLayer.beginTime = cftime
            }
            self.layer.addSublayer(layer)
            self.layer.addSublayer(innerLayer)
            
        }
        
        return cftime
    }
    
    func drawIcons(layers: [CAShapeLayer],iconDonuts: [CAShapeLayer] , after: CFTimeInterval )-> CFTimeInterval{
        var cftime: CFTimeInterval = after
        
        for (index,layer) in layers.enumerate(){
            
            cftime += 0.1
            
            layers[index].beginTime = cftime
            iconDonuts[index].beginTime = cftime
            //innerLayer.beginTime = cftime
            
            self.layer.addSublayer(layer)
            self.layer.addSublayer(iconDonuts[index])
            
        }
        return cftime
    }
    
    func addCAAnimation(forLayer : CAShapeLayer , point : CGPoint){
        
        let anim: CABasicAnimation = CABasicAnimation()
        anim.duration = 0.2
        anim.fromValue = 0.0
        anim.toValue = 100.0
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        forLayer.addAnimation(anim, forKey: "opacity")
        anim.fillMode = kCAFillModeBoth // keep to value after finishing
        anim.removedOnCompletion = false // don't remove after finishing
        // 4
        forLayer.addAnimation(anim, forKey: anim.keyPath)    }
    
    func addText(frame: CGRect, index: Int )-> CALayer{
        
        let textlabel = CATextLayer()
        textlabel.frame = frame
        textlabel.font = UIFont.systemFontOfSize(11)
        textlabel.fontSize = 11
        textlabel.string  =  delegate?.setTextForSlice(index)
        textlabel.alignmentMode = kCAAlignmentCenter
        textlabel.foregroundColor = UIColor.blackColor().CGColor
        textlabel.contentsScale = UIScreen.mainScreen().scale
        return textlabel
        
    }
    func addTitle(at: CGPoint ,after:CFTimeInterval){
        //Title and subtitle
        let titleLabel = CATextLayer()
        titleLabel.frame = CGRectMake(at.x - dims.title_width_by_2, at.y - (dims.title_height/2), 2 * dims.title_width_by_2, dims.title_height)
        titleLabel.font = UIFont.systemFontOfSize(15)
        titleLabel.fontSize = 15
        getTotal()
        titleLabel.string  = delegate?.setChartTitle(total)
        titleLabel.alignmentMode = kCAAlignmentCenter
        titleLabel.foregroundColor = UIColor.blackColor().CGColor
        titleLabel.contentsScale = UIScreen.mainScreen().scale
        
        let subtitleLabel = CATextLayer()
        subtitleLabel.frame = CGRectMake(at.x - dims.title_width_by_2, at.y + dims.title_height/2, 2 * dims.title_width_by_2, dims.sub_title_height)
        subtitleLabel.font = UIFont.systemFontOfSize(11)
        subtitleLabel.fontSize = 11
        subtitleLabel.string  = delegate?.setSubtitle()
        subtitleLabel.alignmentMode = kCAAlignmentCenter
        subtitleLabel.foregroundColor = UIColor.blackColor().CGColor
        subtitleLabel.contentsScale = UIScreen.mainScreen().scale
        
        
        
        titleLabel.beginTime = after
        subtitleLabel.beginTime = after
        self.layer.addSublayer(titleLabel)
        self.layer.addSublayer(subtitleLabel)
    }

}