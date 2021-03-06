import Cocoa
/**
 * VSlider is a simple vertical slider
 * @Note the reason we have two sliders instead of 1 is because otherwise the math and variable naming scheme becomes too complex (same goes for the idea of extending a Slider class)
 * // :TODO: consider having thumbWidth and thumbHeight, its just easier to understand
 * // :TODO: rename thumbHeight to thumbWidth or?
 * // :TODO: remove refs to frame. you can use width and height directly
 * // :TODO: onSkinDown, onSkinUp ?
 */
class VSlider:Element{
    var thumb:Thumb?
    var globalMouseMovedHandeler:AnyObject?//rename to leftMouseDraggedEventListener or draggedEventListner
    var progress:CGFloat/*0-1*/
    var tempThumbMouseY:CGFloat = 0
    var thumbHeight:CGFloat
    init(_ width: CGFloat, _ height: CGFloat,_ thumbHeight:CGFloat = NaN, _ progress:CGFloat = 0,_ parent : IElement? = nil, id : String? = nil){
        self.progress = progress
        self.thumbHeight = thumbHeight.isNaN ? width:thumbHeight// :TODO: explain in a comment what this does
        super.init(width,height,parent,id)
    }
    override func resolveSkin() {
        Swift.print("\(self.dynamicType)" + "resolveSkin(): ")
        super.resolveSkin()
        //skin.isInteractive = false// :TODO: explain why in a comment
        //skin.useHandCursor = false;// :TODO: explain why in a comment
        Swift.print("width: " + "\(width)")
        Swift.print("thumbHeight: " + "\(thumbHeight)")
        thumb = addSubView(Thumb(width, thumbHeight,self))
        setProgressValue(progress)// :TODO: explain why in a comment, because initially the thumb may be positioned wrongly  due to clear and float being none
    }
    func onThumbDown(){
        //Swift.print("\(self.dynamicType)"+".onThumbDown() ")
        tempThumbMouseY = thumb!.localPos().y
        Swift.print("tempThumbMouseY: " + "\(tempThumbMouseY)")
        globalMouseMovedHandeler = NSEvent.addLocalMonitorForEventsMatchingMask([.LeftMouseDraggedMask], handler:onThumbMove )//we add a global mouse move event listener
    }
    func onThumbMove(event:NSEvent)-> NSEvent?{
        //Swift.print("\(self.dynamicType)"+".onThumbMove() " + "localPos: " + "\(event.localPos(self))")
        progress = Utils.progress(event.localPos(self).y, tempThumbMouseY, height/*<--this is the problem, dont use frame*/, thumbHeight)
        thumb!.y = Utils.thumbPosition(progress, height, thumbHeight)
        super.onEvent(SliderEvent(SliderEvent.change,progress,self))
        return event
    }
    func onThumbUp(){
        Swift.print("\(self.dynamicType)" + ".onThumbUp() ")
        if(globalMouseMovedHandeler != nil){NSEvent.removeMonitor(globalMouseMovedHandeler!)}//we remove a global mouse move event listener
    }
    func onMouseMove(event:NSEvent)-> NSEvent?{
        progress = Utils.progress(event.localPos(self).y, thumbHeight/2, height, thumbHeight);
        thumb!.y = Utils.thumbPosition(progress, height, thumbHeight);
        super.onEvent(SliderEvent(SliderEvent.change,progress,self))
        return event
    }
    /**
     * Handles actions and drawing states for the down event.
     */
    override func mouseDown(event:MouseEvent) {/*onSkinDown*/
        Swift.print("\(self.dynamicType)" + ".mouseDown() ")
        progress = Utils.progress(event.event!.localPos(self).y, thumbHeight/2, height, thumbHeight);
        thumb!.y = Utils.thumbPosition(progress, height, thumbHeight);
        super.onEvent(SliderEvent(SliderEvent.change,progress,self))/*sends the event*/
        globalMouseMovedHandeler = NSEvent.addLocalMonitorForEventsMatchingMask([.LeftMouseDraggedMask], handler:onMouseMove )//we add a global mouse move event listener
        //super.mouseDown(event)/*passes on the event to the nextResponder, NSView parents etc*/
    }
    override func mouseUp(event: MouseEvent) {
        if(globalMouseMovedHandeler != nil){NSEvent.removeMonitor(globalMouseMovedHandeler!)}//we remove a global mouse move event listener
    }
    override func onEvent(event: Event) {
        //Swift.print("\(self.dynamicType)" + ".onEvent() event: " + "\(event)")
        if(event.origin === thumb && event.type == ButtonEvent.down){onThumbDown()}//if thumbButton is down call onThumbDown
        else if(event.origin === thumb && event.type == ButtonEvent.up){onThumbUp()}//if thumbButton is down call onThumbUp
        //super.onEvent(event)/*forward events, or stop the bubbeling of events by commenting this line out*/
    }
    /**
     * @param progress (0-1)
     */
    func setProgressValue(progress:CGFloat){/*Can't be named setProgress because of objc*/
        self.progress = Swift.max(0,Swift.min(1,progress))/*if the progress is more than 0 and less than 1 use progress, else use 0 if progress is less than 0 and 1 if its more than 1*/
        thumb!.y = Utils.thumbPosition(self.progress, height, thumbHeight)
        thumb?.applyOvershot(progress)/*<--we use the unclipped scalar value*/
    }
    /**
     * Sets the thumbs height and repositions the thumb accordingly
     */
    func setThumbHeightValue(thumbHeight:CGFloat) {/*Can't be named setThumbHeight because of objc*/
        self.thumbHeight = thumbHeight
        thumb!.setSize(thumb!.getWidth(), thumbHeight)
        thumb!.y = Utils.thumbPosition(progress, height, thumbHeight)
    }
    override func setSize(width:CGFloat, _ height:CGFloat) {
        super.setSize(width,height);
        thumb!.setSize(thumb!.width, height);
        thumb!.y = Utils.thumbPosition(progress, height, thumbHeight);
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}/*required by all NSView subclasses*/
}
private class Utils{
    /**
     * Returns the x position of a nodes @param progress
     */
    class func thumbPosition(progress:CGFloat, _ height:CGFloat, _ thumbHeight:CGFloat)->CGFloat {
        let minThumbPos:CGFloat = height - thumbHeight;/*Minimum thumb position*/
        return progress * minThumbPos
    }
    /**
     * Returns the progress derived from a node
     * @return a number between 0 and 1
     */
    class func progress(mouseY:CGFloat,_ tempNodeMouseY:CGFloat,_ height:CGFloat,_ thumbHeight:CGFloat)->CGFloat {
        if(thumbHeight == height) {return 0}/*if the thumbHeight is the same as the height of the slider then return 0*/
        let progress:CGFloat = (mouseY-tempNodeMouseY) / (height-thumbHeight)
        return max(0,min(progress,1))/*Ensures that progress is between 0 and 1 and if its beyond 0 or 1 then it is 0 or 1*/
    }
}
/*
class Thumb:Button2{
    override init(_ width: CGFloat, _ height: CGFloat) {
        super.init(width,height)//<--This can be a zero rect since the children contains the actual graphics. And when you use Layer-hosted views the subchildren doesnt clip
        createContent()
    }
    func createContent(){
        //Swift.print("create content")
        let skin = SkinD(frame:NSRect(0,0,frame.width,frame.height))
        addSubview(skin)
    }
    override func mouseOver(event:MouseEvent) {
        Swift.print("\(self.dynamicType)" + " mouseOver() ")
        super.mouseOver(event)
    }
    override func mouseOut(event:MouseEvent) {
        Swift.print("\(self.dynamicType)" + " mouseOut() ")
        super.mouseOut(event)
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}
*/
/*
class Button2:InteractiveView2{
    init(_ width: CGFloat, _ height: CGFloat) {
        super.init(frame: NSRect(0,0,width,height))//<--This can be a zero rect since the children contains the actual graphics. And when you use Layer-hosted views the subchildren doesnt clip
    }
    override func mouseDown(event: MouseEvent) {
        super.onEvent(ButtonEvent(ButtonEvent.down,self/*,self*/))
    }
    override func mouseUp(event: MouseEvent) {
        super.onEvent(ButtonEvent(ButtonEvent.up,self/*,self*/))
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}
*/