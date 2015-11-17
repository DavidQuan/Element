import Foundation


class GraphicSkinParser{
   static var rect:String = "rect";
   static var gradient:String = "gradient";
   static var icon:String = "icon";// :TODO: rename to asset or svgasset or alike (keep in mind that you will need to support png assets soon enough)
   static var fillet:String = "fillet";// :TODO: rename to ROUNDED?
   static var dropshadow:String = "dropshadow";
    /**
     * Configures a GraphicDecoratable instance based on what stylePropertyValues is found in @param skin at @param depth
     */
    class func configure(skin:ISkin){
        let fillStyle:IFillStyle = StylePropertyParser.fillStyle(skin);
        var graphic:IGraphicDecoratable = Utils.baseGraphic(fillStyle)
        graphic = Utils.rectGraphic(graphic, skin)
        if(StylePropertyAsserter.hasGradient(skin)) { graphic = Utils.gradient(graphic) }
        if(StylePropertyAsserter.hasFillet(skin)) { graphic = Utils.fillet(graphic, StylePropertyParser.fillet(skin)) }
        graphic.initialize()//runs trough all the different calls and makes the graphic in one go.
    }
}
private class Utils{
    /**
     *
     */
    class func baseGraphic(fillStyle:IFillStyle)->IGraphicDecoratable {
        return BaseGraphic(fillStyle)
    }
    /**
     * Returns a "GraphicRect instance"
     * @example: var r:Rect2 = new Rect2(20,20,new FillStyle());//black square
     */
    class func rectGraphic(decoratable:IGraphicDecoratable,_ skin:ISkin)->IGraphicDecoratable {
        let width:Double = (StylePropertyParser.width(skin) ?? skin.width!);
        let height:Double = (StylePropertyParser.height(skin) ?? skin.height!);
        return RectGraphic(decoratable,width,height);
    }
    /**
     * Returns a "RoundRectGraphic instance" wrapped around a Rect instance
     * // :TODO: Future feature: support for fillOffset, and cornerradius and fillet should have the same nameing scheme
     */
    class func fillet(decoratable:IGraphicDecoratable,_ fillet:Fillet)->IGraphicDecoratable {
        return RoundRectGraphic(decoratable, fillet)
    }
    /**
     * Returns a "GradientDecorator instance" wrapped around a @param decoratable
     * @Note: to use a custom matrix, pass a matrix with the @param gradient or @param lineGradient
     * @Note: doesnt drawLine by default, pass a Gradient instance with @param lineGradient to draw a gradientLine
     * // :TODO: support for GradientLineStyle, GradientFillStyle
     */
    class func gradient(decoratable:IGraphicDecoratable)->IGraphicDecoratable{
        return GradientGraphic(decoratable);
    }
}