//
//  EraserBrush.swift
//  DrawingBoard
//
//  Created by 张奥 on 15/3/19.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit

class EraserBrush: BaseBrush {
    var eraserStrokeWith:CGFloat{
        let temp=strokeWidth*10*force;
        if temp<50
        {
        return temp;
        }
        else
        {
            return 50;
        }
    }
    override func drawInContext(context: CGContextRef) {
        
        CGContextSetBlendMode(context, CGBlendMode.Clear)
        
        
        if let lastPoint = self.lastPoint {
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
        } else {
            CGContextMoveToPoint(context, beginPoint.x, beginPoint.y)
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
        }
        
        CGContextSetLineWidth(context,eraserStrokeWith);

        
    }
    
    override func supportedContinuousDrawing() -> Bool {
        return true;
    }


}
