//
//  DashLineBrush.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-16.
//  Copyright (c) 2015年 zhangao. All rights reserved.
//

import UIKit

class DashLineBrush: BaseBrush {
    
    override func drawInContext(context: CGContextRef) {
        let lengths: [CGFloat] = [self.strokeWidth * 3, self.strokeWidth * 3]
        CGContextSetLineDash(context, 0, lengths, 2)
        
        CGContextMoveToPoint(context, beginPoint.x, beginPoint.y)
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y)
        CGContextSetLineWidth(context, self.strokeWidth);//用固定宽度

    }
}
