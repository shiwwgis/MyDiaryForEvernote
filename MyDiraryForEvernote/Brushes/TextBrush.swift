//
//  TextBrush.swift
//  DrawingBoard
//
//  Created by shiweiwei on 16/2/26.
//  Copyright © 2016年 zhangao. All rights reserved.
//

import UIKit

class TextBrush: BaseBrush {
    
    var text:String="2016年5月20日 晴 PM2.5:44";
    var textColor:UIColor=UIColor.redColor();//字体颜色
    
    
    override func drawInContext(context: CGContextRef) {
        if text.characters.count==0
        {
            return;
        }
        
        let textRect=CGRect(origin: CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y)),
            size: CGSize(width: abs(endPoint.x - beginPoint.x), height: abs(endPoint.y - beginPoint.y)));

        //设置字体风格
        
        // set the font to Helvetica Neue 18
        //计算字体大小,以使之自适应矩形框
        
        
        let strLength=CGFloat(text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))//中英文混的字符串长度
        
        var fontSize=textRect.width*2.0 / strLength;
        
        if fontSize>textRect.height
        {
            fontSize=textRect.height;
        }
        
//        print("fontsize=\(fontSize)");
        
        let textFont = UIFont(name: "Helvetica Neue", size: fontSize);

        
        // set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 1.0
        paraStyle.alignment=NSTextAlignment.Center;
        
        // set the Obliqueness to 0.1
        let skew = 0.0
        
        let attributes = [
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paraStyle,
            NSObliquenessAttributeName: skew,
            NSFontAttributeName: textFont!
        ];
        //开始绘制
        

        text.drawInRect(textRect, withAttributes: attributes);
       //绘矩形
        
//        CGContextAddRect(context,textRect)
    }
}
