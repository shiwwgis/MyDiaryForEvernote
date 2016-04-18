//
//  HighlightBrush.swift
//  DrawingBoard
//
//  Created by shiweiwei on 16/2/4.
//  Copyright © 2016年 zhangao. All rights reserved.
//

import UIKit

class HightlightBrush:BaseBrush {
    var eraserStrokeWith:CGFloat{
        let temp=magnitude*10;
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
        
        CGContextSetBlendMode(context, CGBlendMode.Color)
//        CGContextSetAlpha(context,0.5);

        
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