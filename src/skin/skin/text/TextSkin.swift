import Cocoa
/**
 * TODO: For the sake of optiomization, TextSkin should not extend Skin, but rather extend NSText. Less views means better speed
 */
class TextSkin:Skin,ITextSkin{
    var textField:CustomText;
    //the bellow variable is a little more complex in the original code
    override var width:CGFloat? {get{return textField.frame.width} set{textField.frame.width = newValue!}}// :TODO: make a similar funciton for getHeight, based on needed space for the height of the textfield
    private var hasTextChanged:Bool = true;/*<-Why is is this true by default?*/
    //func setText(text:String)
    init(_ style:IStyle, _ text:String, _ state:String = SkinStates.none, _ element:IElement? = nil){
        //Swift.print("TextSkin.init()")
        textField = CustomText(frame: NSRect(x: 0, y: 0, width: 200, height: 200))//<--TODO: these default values must be wrong, set w and h to 0
        //textField.sizeToFit()
        textField.string = text
        super.init(style, state, element)
        addSubview(textField)
        applyProperties(textField)
        SkinModifier.float(self)
        SkinModifier.align(self, textField)
        textField.hidden = SkinParser.display(self) == CSSConstants.none
    }
    override func draw() {
        if (hasStyleChanged || hasSizeChanged || hasStateChanged || hasTextChanged) {
            SkinModifier.float(self)
            if(hasSizeChanged) {
                let padding:Padding = StylePropertyParser.padding(self);
                TextFieldModifier.size(textField, width! + padding.left + padding.right, height! + padding.top + padding.bottom);
            }
            if(hasStateChanged || hasStyleChanged || hasTextChanged) {applyProperties(textField)}
            if(hasTextChanged) {hasTextChanged = false}
            SkinModifier.align(self, textField)
            let text = NSText()
            text.x
        }
        super.draw()
    }
    func applyProperties(textField:NSText){
        
        //Continue here, bug here cant get width
        
        let padding:Padding = StylePropertyParser.padding(self);
        let width:CGFloat = (StylePropertyParser.width(self) ?? super.width!) + padding.left + padding.right;// :TODO: only querry this if the size has changed?
        //Swift.print("width: " + "\(width)")
        let height:CGFloat = (StylePropertyParser.height(self) ?? super.height!) + padding.top + padding.bottom;// :TODO: only querry this if the size has changed?
        //Swift.print("height: " + "\(height)")
        textField.frame.width = width/*SkinParser.width(this);*/
        textField.frame.height = height/*SkinParser.height(this);*/
        super.frame.width = width//quick fix
        super.frame.height = height//quick fix
        let textFormat:TextFormat = StylePropertyParser.textFormat(self)
        //Swift.print("TextSkin.applyProperties() textFormat.color: " + String(textFormat.color))
        TextFieldModifier.applyTextFormat(textField,textFormat)
    }
    /**
     * Set the text and updates the skin
     * // :TODO: add more advance setText features like start and end etc
     */
    func setText(text:String){
        textField.stringValue = text;
        hasTextChanged = true;
        draw();
    }
    
    /**
     * // :TODO: make a similar funciton for getHeight, based on needed space for the height of the textfield
     */
    /*override func getWidth() -> CGFloat {
        if(!StylePropertyParser.value(self, "wordWrap")){/*if the wordWrap is false the the width of the skin is equal to the width of the textfield (based on needed space for the text)*/
            var padding:Padding = StylePropertyParser.padding(self);
            return textField.width + padding.left + padding.right;
        }else {return super.getWidth()}
    }
     */
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}
class CustomText:NSTextField{
    //override var flipped:Bool {return true}/*Organizes your view from top to bottom*/
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    //continue here: try to implement a subclass of NSText in TextSkin with the new hitTest
    
    /**
    * NOTE: You must use InteractiveView as a parent for this class to work
    * NOTE: the hitTesting bellow is the only combination i found that will give a correct hit. the x can also be derived from the
    */
    override func hitTest(aPoint: NSPoint) -> NSView? {
        Swift.print("CustomText: hitTest()" + "\(aPoint)" + " localPos(): " + "\(localPos())")
        let tempPos = self.convertPoint(aPoint,fromView:nil)
        Swift.print("tempPos: " + "\(tempPos)")
        return super.hitTest(CGPoint(aPoint.x,localPos().y))
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}