import Cocoa

class StylePropertyParser{
    /**
     * Returns a property from @param skin and @param property
     * @Note the reason that depth defaults to 0 is because if the exact depth isnt found there should only be depth 0, if you have more than 1 depth in a property then you must supply at all depths or just the 1 that will work for all depths
     * // :TODO: should probably also support when state is know and depth is defaulted to 0 ?!?!?
     */
    class func value(skin:ISkin, _ propertyName:String, _ depth:Int = 0)->Any!{//TODO: <- try to remove the ! char here
        //Swift.print("StylePropertyParser.value() propertyName: " + propertyName)
        let value:Any? = skin.style!.getValue(propertyName,depth);
        //Swift.print("value: " + "\(value)")
        return value;
    }
    /**
     *
     */
    class func fillStyle(skin:ISkin,_ depth:Int = 0)->IFillStyle {
        return value(skin,CSSConstants.fill,depth) is IGradient ? gradientFillStyle(skin,depth):colorFillStyle(skin,depth);
    }
    /**
     *
     */
    class func lineStyle(skin:ISkin, _ depth:Int = 0) -> ILineStyle? {
        return value(skin,CSSConstants.line,depth) is IGradient ? gradientLineStyle(skin,depth) : colorLineStyle(skin,depth) ;
    }
    /**
     * Returns a FillStyle instance
     */
    class func colorFillStyle(skin:ISkin, _ depth:Int = 0)->IFillStyle {
        //print("StylePropertyParser.colorFillStyle()")
        let colorValue:Any? = StylePropertyParser.value(skin, CSSConstants.fill,depth);
        //Swift.print("colorValue.dynamicType: " + "\(colorValue.dynamicType)")
        //Swift.print("colorValue: " + "\(colorValue)" + " depth: " + "\(depth)");
        var color:Double;
        if(colorValue == nil){
            color = Double.NaN
        }else if(colorValue! is Array<Any>) {
            //Swift.print("value is array");
            color = ((colorValue as! Array<Any>)[1] as! String) == CSSConstants.none ? Double.NaN : Double(StringParser.color((colorValue as! Array<Any>)[1] as! String));
        }else if(colorValue is UInt){/*colorValue is UInt*/
            color = Double(colorValue as! UInt)
        }else{
            fatalError("colorValue not supported: " + "\(colorValue)")
        }
        //Swift.print("color: " + "\(color)")
        let alpha:Any? = StylePropertyParser.value(skin, CSSConstants.fillAlpha,depth)
        //print("alpha: " + "\(alpha)")
        let alphaValue:CGFloat = alpha as? CGFloat ?? 1
        //Swift.print("alphaValue: " + "\(alphaValue)")
        let nsColor:NSColor = !color.isNaN ? NSColorParser.nsColor(UInt(color), alphaValue) : NSColor.clearColor()/*<-- if color is NaN, then the color should be set to clear, or should it?, could we instad use nil, but then we would need to assert all fill.color values etc, we could create a custom NSColor class, like NSEmptyColor that extends NSCOlor, since we may want NSColor.clear in the future, like clear the fill color etc? */
        //TODO:You need to upgrade FillStyle to support alpha and color and add NSColor further down the line because checking for NaN is essential when setting or not setting things?, you can revert to pure NSColor and clearStyle later anyway
        return FillStyle(nsColor)
    }
    /**
     * Returns a LineStyle instance
     * // :TODO: this is wrong the style property named line-color doesnt exist anymore, its just line now
     * @Note we use line-thickness because the property thickness is occupid by textfield.thickness
     */
    class func colorLineStyle(skin:ISkin, _ depth:Int = 0) -> ILineStyle? {
        //Swift.print("StylePropertyParser.colorLineStyle()")
        if(value(skin, CSSConstants.line) == nil){return nil }//temp fix
        let lineThickness:CGFloat = value(skin, CSSConstants.lineThickness,depth) as? CGFloat ?? CGFloat.NaN
        let lineColorValue:Double = color(skin, CSSConstants.line,depth)
        //Swift.print("StylePropertyParser.colorLineStyle() " + String(value(skin, CSSConstants.lineAlpha)))
        let lineAlpha:CGFloat = value(skin, CSSConstants.lineAlpha,depth) as? CGFloat ?? 1
        let lineColor:NSColor = Utils.nsColor(lineColorValue, lineAlpha)
        return LineStyle(lineThickness, lineColor);
    }
    /**
     * @Note makes sure that if the value is set to "none" or doesnt exsist then NaN is returned (NaN is interpreted as do not draw or apply style)
     */
    class func color(skin:ISkin, _ propertyName:String, _ depth:Int = 0) -> Double {
        let color:Any? = value(skin, propertyName,depth);
        //Swift.print("color: " + "\(color)")
        return color == nil || String(color!) == CSSConstants.none ? Double.NaN : Double(color as! UInt);
    }
    /**
     * Returns an Offset instance
     * // :TODO: probably upgrade to TRBL
     * NOTE: the way you let the index in the css list decide if something should be included in the final offsetType is probably a bad convention. Im not sure. Just write a note why, if you figure out why its like this.
     */
    class func lineOffsetType(skin:ISkin, _ depth:Int = 0) -> OffsetType {
        //Swift.print("StylePropertyparser.lineOffsetType()")
        let val:Any? = value(skin, CSSConstants.lineOffsetType,depth);
        var offsetType:OffsetType = OffsetType();
        if((val is String) || (val is Array<String>)) {/*(val is String) || */offsetType = LayoutUtils.instance(val!, OffsetType.self) as! OffsetType}
        //LayoutUtils.describe(offsetType)
        let lineOffsetTypeIndex:Int = StyleParser.index(skin.style!, CSSConstants.lineOffsetType,depth);
        //Swift.print("lineOffsetTypeIndex: " + "\(lineOffsetTypeIndex)")
        if(StyleParser.index(skin.style!, CSSConstants.lineOffsetTypeLeft,depth) > lineOffsetTypeIndex){ offsetType.left = StylePropertyParser.string(skin, CSSConstants.lineOffsetTypeLeft)}
        if(StyleParser.index(skin.style!, CSSConstants.lineOffsetTypeRight,depth) > lineOffsetTypeIndex){ offsetType.right = StylePropertyParser.string(skin, CSSConstants.lineOffsetTypeRight,depth)}
        if(StyleParser.index(skin.style!, CSSConstants.lineOffsetTypeTop,depth) > lineOffsetTypeIndex){ offsetType.top = StylePropertyParser.string(skin, CSSConstants.lineOffsetTypeTop,depth)}
        if(StyleParser.index(skin.style!, CSSConstants.lineOffsetTypeBottom,depth) > lineOffsetTypeIndex){ offsetType.bottom = StylePropertyParser.string(skin, CSSConstants.lineOffsetTypeBottom,depth)}
        //if(offsetType.top == OffsetType.center || offsetType.bottom == OffsetType.center || offsetType.left == OffsetType.center || offsetType.right == OffsetType.center){fatalError("lineOffsetType:center is not supported yet")}//<--temp fix, implement center as a way of alignment or remove it from parsing or?
        //Swift.print("------after-------")
        //LayoutUtils.describe(offsetType)
        return offsetType;
    }
    /**
     * Returns a Fillet instance
     * // :TODO: probably upgrade to TRBL
     * TODO: needs to return nil aswell. Since we need to test if a fillet doesnt exist. if a fillet has just 0 values it should still be a fillet etc. 
     */
    class func fillet(skin:ISkin, _ depth:Int = 0) -> Fillet {
        let val:Any? = value(skin, CSSConstants.cornerRadius,depth);
        var fillet:Fillet = Fillet();
        //Swift.print(val)
        if((val is CGFloat) || (val is Array<Any>)) {/*(val is String) ||*/fillet = LayoutUtils.instance(val!, Fillet.self) as! Fillet}
        //Swift.print("StylePropertyParser.fillet: " + String(ClassParser.classType(val!)))
        //Swift.print(fillet.topRight)
        let cornerRadiusIndex:Int = StyleParser.index(skin.style!, CSSConstants.cornerRadius, depth);//returns -1 if it doesnt exist
        if(StyleParser.index(skin.style!, CSSConstants.cornerRadiusTopLeft, depth) > cornerRadiusIndex) { fillet.topLeft = StylePropertyParser.number(skin, "corner-radius-top-left", depth) }//TODO: replace this with the constant: cornerRadiusIndex
        if(StyleParser.index(skin.style!, CSSConstants.cornerRadiusTopRight, depth) > cornerRadiusIndex) { fillet.topRight = StylePropertyParser.number(skin, "corner-radius-top-right", depth) }
        if(StyleParser.index(skin.style!, CSSConstants.cornerRadiusBottomLeft, depth) > cornerRadiusIndex) { fillet.bottomLeft = StylePropertyParser.number(skin, "corner-radius-bottom-left", depth) }
        if(StyleParser.index(skin.style!, CSSConstants.cornerRadiusBottomRight, depth) > cornerRadiusIndex) { fillet.bottomRight = StylePropertyParser.number(skin, "corner-radius-bottom-right", depth) }
        return fillet;
    }
    /**
     * Returns a GradientFillStyle
     */
    class func gradientFillStyle(skin:ISkin, _ depth:Int = 0) -> GradientFillStyle {
        let newGradient:Gradient/*IGradient*/ = value(skin, CSSConstants.fill, depth) as! Gradient/*IGradient*///GradientParser.clone();
        //let sizeWidth:Double = skin.width!
        //let sizeHeight:Double = skin.height!
        return GradientFillStyle(newGradient,NSColor.clearColor());
    }
    /**
    * Returns a GradientLineStyle
    * // :TODO: does this work? where is the creation of line-thickness etc
    * @Note we use line-thickness because the property thickness is occupid by textfield.thickness
    */
    class func gradientLineStyle(skin:ISkin, _ depth:Int = 0) -> GradientLineStyle? {
        //Swift.print("StylePropertParser.gradientLineStyle()")
        let gradient = value(skin, CSSConstants.line,depth)
        if(!(gradient is IGradient)){return nil}//<--temp fix
        //gradient.rotation *= ㎭
        let lineThickness:CGFloat = value(skin, CSSConstants.lineThickness,depth) as! CGFloat
        return GradientLineStyle(gradient as! IGradient, lineThickness, NSColor.clearColor()/*colorLineStyle(skin)*/);
    }
    /**
     *
     */
    class func textFormat(skin:TextSkin)->TextFormat {
        let textFormat:TextFormat = TextFormat()
        for textFormatKey : String in TextFormatConstants.textFormatPropertyNames {
            var value:Any? = StylePropertyParser.value(skin, textFormatKey)
            //Swift.print("StylePropertypParser.textFormat() value: " + "\(value.dynamicType)")
            //				if(textFormatKey == "size") trace("size: "+value+" "+(value is String));
            if(value != nil) {
                if(StringAsserter.metric(String(value))){
                    let pattern:String = "^(-?\\d*?\\.?\\d*?)((%|ems)|$)"
                    let stringValue:String = String(value)
                    let matches = stringValue.matches(pattern)
                    for match:NSTextCheckingResult in matches {
                        var value:Any = (stringValue as NSString).substringWithRange(match.rangeAtIndex(1))//capturing group 1
                        let suffix:String = (stringValue as NSString).substringWithRange(match.rangeAtIndex(2))//capturing group 1
                        if(suffix == CSSConstants.ems) {value = CGFloat(Double(String(value))!) * CSSConstants.emsFontSize }
                    }
                }
                if(value is Array<String>) { value = StringModifier.combine(value as! Array<String>, " ") }/*Some fonts are seperated by a space and thus are converted to an array*/
                else if(value is UInt) {
                    value = NSColorParser.nsColor(value as! UInt,1)
                    //Swift.print("FOUND A COLOR: " + textFormatKey + " : " + "\(value)")
                }//<--set the alpha in css aswell backgroundAlpha?
                textFormat[textFormatKey] = value!;
            }
        }
        return textFormat;
    }
    /**
     * @Note this is really a modifier method
     * // :TODO: add support for % (this is the percentage of the inherited font-size value, if none is present i think its 12px)
     */
    class func textField(skin:TextSkin) {
        for textFieldKey : String in TextFieldConstants.textFieldPropertyNames {
            let value:Any? = StylePropertyParser.value(skin,textFieldKey);
            if(value != nil) {
                if(StringAsserter.metric(value as! String)){
                    //TODO:you may need to set one of the inner groups to be non-catachple
                    let pattern:String = "^(-?\\d*?\\.?\\d*?)((%|ems)|$)"
                    let stringValue:String = String(value)
                    let matches = stringValue.matches(pattern)
                    for match:NSTextCheckingResult in matches {
                        var value:Any = (stringValue as NSString).substringWithRange(match.rangeAtIndex(1))//capturing group 1
                        let suffix:String = (stringValue as NSString).substringWithRange(match.rangeAtIndex(2))//capturing group 1
                        if(suffix == CSSConstants.ems) {value = CGFloat(Double(String(value))!) * CSSConstants.emsFontSize }
                    }
                }
                //TODO: this needs to be done via subscript probably, see that other code where you used subscripting recently
                fatalError("Not implemented yet")
                //skin.textField[textFieldKey] = value;
            }
        }
    }
    /**
     * Returns Offset
     * // :TODO: merge ver/hor Offset into this one like you did with cornerRadius
     */
    class func offset(skin:ISkin,_ depth:Int = 0)->CGPoint {
        let value:Any? = self.value(skin, CSSConstants.offset, depth);
        //Swift.print("StylePropertyParser.offset.value: " + "\(value)")
        if(value == nil){return CGPoint(0,0)}//<---temp solution
        var array:Array<CGFloat> = value is CGFloat ? [value as! CGFloat] : (value as! Array<Any>).map {String($0).cgFloat}//the map method is cool. But it isnt needed, since this array will always have a count of 2
        //Swift.print("StylePropertyParser.offset.array.count: " + "\(array.count)")
        return array.count == 1 ? CGPoint(array[0],0) : CGPoint(array[0], array[1])
    }
    /**
     * @Note TRBL
     * // :TODO: should this have a failsafe if there is no Padding property in the style?
     * // :TODO: try to figure out a way to do the padding-left right top bottom stuff in the css resolvment not here it looks so cognativly taxing
     */
    //Note to self: if this method is buggy refer to the legacy code as you changed a couple of method calls : value is now metric
    //you may want to copy margin on this
    class func padding(skin:ISkin,_ depth:Int = 0) -> Padding {
        let value:Any? = self.value(skin, CSSConstants.padding, depth)
        //Swift.print("StylePropertyParser.padding.value: " + "\(value)")
        var padding:Padding = Padding()
        if(value != nil){
            let array:Array<CGFloat> = value is Array<CGFloat> ? value as! Array<CGFloat> : [value as! CGFloat]
            padding = Padding(array)
        }
        let paddingIndex:Int = StyleParser.index(skin.style!, CSSConstants.padding, depth)
        padding.left = (StyleParser.index(skin.style!, CSSConstants.paddingLeft,depth) > paddingIndex ? StylePropertyParser.metric(skin, CSSConstants.paddingLeft, depth) : Utils.metric(padding.left, skin))!;/*if margin-left has a later index than margin then it overrides margin.left*/
        padding.right = (StyleParser.index(skin.style!, CSSConstants.paddingRight,depth) > paddingIndex ? StylePropertyParser.metric(skin, CSSConstants.paddingRight, depth) : Utils.metric(padding.right, skin))!
        padding.top = (StyleParser.index(skin.style!, CSSConstants.paddingTop,depth) > paddingIndex ? StylePropertyParser.metric(skin, CSSConstants.paddingTop, depth) : Utils.metric(padding.top, skin))!
        padding.bottom = ((StyleParser.index(skin.style!, CSSConstants.paddingBottom,depth) > paddingIndex) ? StylePropertyParser.metric(skin, CSSConstants.paddingBottom, depth) : Utils.metric(padding.bottom, skin))!
        return padding
    }
    /**
     * // :TODO: should this have a failsafe if there is no Margin property in the style?
     * // :TODO: try to figure out a way to do the margin-left right top bottom stuff in the css resolvment not here it looks so cognativly taxing
     */
    class func margin(skin:ISkin, _ depth:Int = 0)->Margin {
        let value:Any? = self.value(skin, CSSConstants.margin,depth);
        let margin:Margin = value != nil ? Margin(value!) : Margin()
        let marginIndex:Int = StyleParser.index(skin.style!, CSSConstants.margin,depth);
        //Swift.print(StyleParser.index(skin.style!, CSSConstants.marginLeft))
        margin.left = (StyleParser.index(skin.style!, CSSConstants.marginLeft,depth) > marginIndex ? metric(skin, CSSConstants.marginLeft,depth) : Utils.metric(margin.left, skin))!;/*if margin-left has a later index than margin then it overrides margin.left*/
        margin.right = (StyleParser.index(skin.style!, CSSConstants.marginRight,depth) > marginIndex ? metric(skin, CSSConstants.marginRight,depth) : Utils.metric(margin.right, skin))!;
        margin.top = (StyleParser.index(skin.style!, CSSConstants.marginTop,depth) > marginIndex ? metric(skin, CSSConstants.marginTop,depth) : Utils.metric(margin.top, skin))!;
        margin.bottom = StyleParser.index(skin.style!, CSSConstants.marginBottom,depth) > marginIndex ? metric(skin, CSSConstants.marginBottom,depth)! : Utils.metric(margin.bottom, skin)!;
        return margin;
    }
    /**
     *
     */
    class func width(skin:ISkin, _ depth:Int = 0) -> CGFloat? {
        return metric(skin,CSSConstants.width,depth)
    }
    /**
     *
     */
    class func height(skin:ISkin, _ depth:Int = 0) -> CGFloat? {
        return metric(skin,CSSConstants.height,depth)
    }
    /**
     * Returns a Number derived from eigther a percentage value or ems value (20% or 1.125 ems == 18)
     */
    class func metric(skin:ISkin,_ propertyName:String, _ depth:Int = 0)->CGFloat? {
        let value = StylePropertyParser.value(skin,propertyName,depth);
        return Utils.metric(value,skin);
    }
    /**
     * Beta
     */
    class func asset(skin:ISkin, _ depth:Int = 0)-> String {
        return (value(skin, CSSConstants.fill,depth) as! Array<Any>)[0] as! String;
    }
    /**
     * TODO: this method is asserted before its used, so you may ommit the optionality
     */
    class func dropShadow(skin:ISkin, _ depth:Int = 0)->DropShadow? {
        let dropShadow:Any? = value(skin, CSSConstants.drop_shadow,depth);
        return (dropShadow == nil || dropShadow as? String == CSSConstants.none) ? nil : dropShadow as? DropShadow;
    }
}
private class Utils{
    /**
     * // :TODO: explain what this method is doing
     */
    class func metric(value:Any?,_ skin:ISkin)->CGFloat? {
        if(value is Int){ return CGFloat(value as! Int)}//<-int really? shouldnt you use something with decimals?
        else if(value is CGFloat){return value as? CGFloat}
        else if(value is String){/*value is String*/
            let pattern:String = "^(-?\\d*?\\.?\\d*?)((%|ems)|$)"//<--this can go into a static class variable since it is used twice in this class
            let stringValue:String = value as! String
            //Swift.print("stringValue: " + "\(stringValue)")
            let matches = stringValue.matches(pattern)
            //Swift.print("matches.count: " + "\(matches.count)")
            for match:NSTextCheckingResult in matches {
                let valStr:Any = (stringValue as NSString).substringWithRange(match.rangeAtIndex(1))//capturing group 1
                let suffix:String = (stringValue as NSString).substringWithRange(match.rangeAtIndex(2))//capturing group 1
                let valNum =  CGFloat(Double(valStr as! String)!)
                if(suffix == "%") {
                    //Swift.print("Suffix is %")
                    let val:CGFloat = valNum / 100 * (skin.element!.getParent() != nil ? (totalWidth(skin.element!.getParent() as! IElement)/*(skin.element.parent as IElement).getWidth()*/) : 0);/*we use the width of the parent if the value is percentage, in accordance to how css works*/
                    //				trace("skin.element.parent != null: " + skin.element.parent != null);
                    //				trace("(skin.element.parent as IElement).skin: " + (skin.element.parent as IElement).skin);
                    return val
                }else {
                    //print("ems");
                    return valNum * CSSConstants.emsFontSize;/*["suffix"] == "ems"*/
                }
            }
        }
        //fatalError("NOT IMPLEMENTED YET")
        //be warned this method is far from complete
        return nil//<---this should be 0, it will require some reporgraming
    }
    /**
    * Returns the total width
    */
    class func totalWidth(element:IElement)->CGFloat {/*beta*/
        if(element.skin != nil){
            //Swift.print("works")
            let margin:Margin = SkinParser.margin(element.skin!)
            let border:Border = SkinParser.border(element.skin!)
            let padding:Padding = SkinParser.padding(element.skin!)
            let width:CGFloat = element.getWidth();/*StylePropertyParser.height(element.skin);*/
            let tot:CGFloat = margin.left + border.left + width - padding.left - padding.right - border.right - margin.right
            //Swift.print("tot: " + "\(tot)")
            return tot/*Note used to be + padding.right + border.right + margin.right*/
        }else {return element.getWidth()}
    }
    /**
     * new
     */
    class func nsColor(color:Double,_ alpha:CGFloat)->NSColor{
        let nsColor = color.isNaN ? NSColor.clearColor() : NSColorParser.nsColor(UInt(color), alpha)
        return nsColor
    }
}
extension StylePropertyParser{
    /*
     * Convenince method for deriving CGFloat values
     */
    class func number(skin:ISkin, _ propertyName:String, _ depth:Int = 0)->CGFloat{
        return CGFloat(Double(string(skin, propertyName,depth))!)
    }
    /*
    * Convenince method for deriving String values
    */
    class func string(skin:ISkin, _ propertyName:String, _ depth:Int = 0)->String{
        return String(value(skin, propertyName,depth))
    }
}