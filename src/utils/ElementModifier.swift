import Cocoa

class ElementModifier {
    /**
     * Changes the visibility of @param element by @param isVisible
     * // :TODO: what if the state changes? then the StyleManager is queried again and the current display state wont work
     */
    func hide(element:IElement,_ isVisible:Bool) {
        var display:String = isVisible ? "" : CSSConstants.none;
        element.skin!.setStyle(StyleModifier.clone(element.skin!.style!));/*This is a temp fix, an original style must be applied to every skin*/
        var styleProperty:IStyleProperty? = element.skin!.style!.getStyleProperty("display")
        styleProperty != nil ? styleProperty.value = display : element.skin.style.addStyleProperty(StyleProperty("display", display));
        element.skin.setStyle(element.skin.style);
    }
    /**
     * Refreshes many elements in @param displayObjectContainer
     * // :TODO: skin should have a dedicated redraw method or a simple workaround
     * @Note keep in mind that this can be Window
     */
    class func refresh(element:IElement) {
        if(element.skin!.style!.getStyleProperty("display") != nil && (element.skin!.style!.getStyleProperty("display")!.value as! String) == CSSConstants.none) {return} /*Skip refreshing*/
        let container:NSView = element as! NSView//element is Window ? Window(element).view : element as NSView;
        let numChildren:Int = container.subviews.count
        for (var i : Int = 0; i < numChildren; i++) {
            let child:NSView = container.subviews[i]
            if(child is IElement) {
                (child as! IElement).skin!.setStyle((child as! IElement).skin!.style!)/*Uses the setStyle since its faster than setSkin*/
                if(child.subviews.count > 0) {refresh(child as! IElement)}
            }
        }
    }
    /**
     * @Note refloats @param view children that are of type IElement
     * @Note i.e: after hideing of an element, or changing the depth order etc
     */
    class func floatChildren(view:NSView) {
        //Swift.print("ElementModifier.floatChildren()")
        let numChildren:Int = view.subviews.count;
        for (var i : Int = 0; i < numChildren; i++) {
            let child:NSView = view.subviews[i]
            if(child is IElement) {
                //Swift.print("text: " + "\((child as! SelectTextButton).getText())")
                SkinModifier.float((child as! IElement).skin!)
            }
        }
    }
}
