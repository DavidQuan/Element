import Cocoa
/*
* TODO: the mask doesnt have an exact fitting fillet (figure out how to solve this)
* TODO: impliment elliptical round corners corner-radius:50/25; creates an elliptical roundcornered rect
* NOTE we might need to create a method named drawAdvanceRoundRect, which would draw a round rect with individual corners that also could have 2 radiuses ech so you would have elliptical corners,
* google for Drawing Circles with Rational Quadratic Bezier Curves.pdf or use a value named kappa which is basically kappa = 4 * (sqrt(2) - 1) / 3
* NOTE: CGRect has a roundRect method with eliptical corners. You have this code in your research folder
*/
class RoundRectGraphic:SizeableDecorator{//adds round-rectangular path
    var fillet:Fillet;
    init(_ x:CGFloat,_ y:CGFloat,_ fillet:Fillet,_ decoratable: IGraphicDecoratable) {//this shoul d be provided through an extension not here->  = BaseGraphic(FillStyle(NSColor.greenColor())
        self.fillet = fillet
        super.init(decoratable)
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    override func drawFill() {
        //Swift.print("RoundRectGraphic.drawFill() ")
        let fillFrame = graphic.lineStyle != nil ?  RectGraphicUtils.fillFrame(CGRect(x,y,width,height), graphic.lineStyle!, graphic.lineOffsetType) : CGRect(x,y,width,height)
        getGraphic().fillShape.frame = fillFrame/*,position and set the size of the frame*/
        getGraphic().fillShape.path = CGPathParser.roundRect(0,0,width,height,fillet.topLeft, fillet.topRight, fillet.bottomLeft, fillet.bottomRight)//Shapes/*Draws in the local coordinate space of the shape*/
    
    }
    /**
     *
     */
    override func drawLine(){
        //Swift.print("RoundRectGraphic.drawLine() " + String(graphic.lineStyle != nil))
        if(graphic.lineStyle != nil){/*updates only if lineStyle and lineStyle.color are valid*/// :TODO: this check could possibly be redundant
            let lineOffsetType:OffsetType = graphic.lineOffsetType;
            let lineOffsetRect = RectGraphicUtils.lineOffsetRect(CGRect(x,y,width,height), graphic.lineStyle!, lineOffsetType)
            let fillet:Fillet = FilletParser.config(self.fillet, lineOffsetType, graphic.lineStyle!);
            graphic.lineShape.frame = lineOffsetRect.lineFrameRect
            graphic.lineShape.path = CGPathParser.roundRect(lineOffsetRect.lineRect.x,lineOffsetRect.lineRect.y,lineOffsetRect.lineRect.width,lineOffsetRect.lineRect.height,fillet.topLeft, fillet.topRight, fillet.bottomLeft, fillet.bottomRight)//lineOffsetRect.lineRect.path

            /*mask*/
            //let maskRect:CGRect = RectGraphicUtils.maskRect(CGRect(0,0,graphic.width,graphic.height), graphic.lineStyle!, lineOffsetType);
            //fatalError("the above lines needs to be updated, RectGraphicUtils.offsetRect etc")
        }
    }
}
extension RoundRectGraphic{
    /**
     *
     */
    convenience init(_ x:CGFloat,_ y:CGFloat,_ fillet:Fillet,_ fillStyle:IFillStyle, _ lineStyle:ILineStyle, _ lineOffset:OffsetType = OffsetType(OffsetType.center)){
        self.init(x,y,fillet,BaseGraphic(fillStyle,lineStyle,lineOffset))
    }
}