//
//  PencilBrush.swift
//  DrawingBoard
//
//  Created by 张奥 on 15/3/18.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit

class PencilBrush: BaseBrush {
    
    override func drawInContext(context: CGContextRef) {
//        CGContextSetAlpha(context,0.5);
        if let lastPoint = self.lastPoint {
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
//            Swift.debugPrint("pnt1=\(lastPoint),pnt2=\(endPoint),width=\(self.magnitude)");
        } else {
            CGContextMoveToPoint(context, beginPoint.x, beginPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
//            Swift.debugPrint("pnt1=\(beginPoint),pnt2=\(endPoint),width=\(self.magnitude)");

        }
       
        CGContextSetLineWidth(context, magnitude);//support apple pencil

    }
    //让笔触更光滑，如果是铅笔模式，需要调用该函数，drawcontext笔触不光滑
    func drawStroke(context: CGContext?, touch: UITouch,view:UIView) {
        let previousLocation = touch.previousLocationInView(view)
        let location = touch.preciseLocationInView(view)
        
        /*        var lineWidth: CGFloat
        if touch.type == .Stylus {
        // Calculate line width for drawing stroke
        if touch.altitudeAngle < tiltThreshold {
        lineWidth = lineWidthForShading(context, touch: touch)
        } else {
        lineWidth = lineWidthForDrawing(context, touch: touch)
        }
        // Set color
        pencilTexture.setStroke()
        } else {
        // Erase with finger
        lineWidth = touch.majorRadius / 2
        eraserColor.setStroke()
        }*/
        // Configure line
        //        CGContextSetLineWidth(context, lineWidth)
        //      CGContextSetLineCap(context, .Round)
        
        
        // Set up the points
        CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
        CGContextAddLineToPoint(context, location.x, location.y)
        
        self.force=touch.force;
        
        CGContextSetLineWidth(context,magnitude);
        
      //          Swift.debugPrint("before force=\(magnitude),after=\(touch.force*self.strokeWidth*0.8)");
        
    }

    override func supportedContinuousDrawing() -> Bool {
        return true
    }
}
