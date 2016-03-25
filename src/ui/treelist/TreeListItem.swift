import Cocoa
/**
 * @Note: Keep the TreeListItem name, since you might want to create TreeMenuItem one day
 * // :TODO: why doesnt the treeListItem extend a class that ultimatly extends a TextButton?, has it something to do with the indentation via css?
 */
class TreeListItem:SelectCheckBoxButton{
    var itemContainer : Container?
    init(_ width:CGFloat, _ height:CGFloat, _ text:String = "defaultText", _ isChecked:Bool = false, _ isSelected:Bool = false, parent:IElement? = nil, id:String = "") {
        super.init(width, height, text, isSelected, isChecked, parent, id)
    }
    override func resolveSkin(){
        super.resolveSkin();
        itemContainer = addSubView(Container(NaN,NaN,self,"lable"))//0. add _itemContainer
        itemContainer!.hidden = isChecked
    }
    func addItem(item:NSView){
        itemContainer!.addSubView(item)
        ElementModifier.floatChildren(itemContainer!)
    }
    func addItemAt(item:NSView,_ index:Int){
        itemContainer!.addSubviewAt(item, index)
        ElementModifier.floatChildren(itemContainer!)
    }
    func removeAt(index:Int){
        itemContainer!.removeSubviewAt(index)
        ElementModifier.floatChildren(itemContainer!)
    }
    func open(){
        setChecked(true)
        checkBox?.onEvent(CheckEvent(CheckEvent.check, true, checkBox!))
    }
    func close(){
        setChecked(false)
        checkBox?.onEvent(CheckEvent(CheckEvent.check, false, checkBox!))
    }
    func onItemCheck(event : CheckEvent) {
        if((event.origin as! NSView).superview === self){itemContainer!.hidden = event.isChecked}/*Checks if its this.checkButton is dispatching the event*///for (var i : int = 0; i < _itemContainer.numChildren; i++) (_itemContainer.getChildAt(i) as DisplayObject).visible = event.checked;
        if(isChecked) {ElementModifier.floatChildren(itemContainer!)}/*this is called from any decending treeListItem*/
    }
    override func onEvent(event: Event) {
        super.onEvent(event)
        if(event.type == CheckEvent.check){onItemCheck(event as! CheckEvent)}/*this listens to all treeListItem decendants*/
    }
    func getLength()->Int{//rename to count?
        return itemContainer!.subviews.count
    }
    override func getHeight() -> CGFloat {
        var height:CGFloat = SkinParser.totalHeight(skin!)
        if(isChecked) {
            for (var i : Int = 0; i < itemContainer!.subviews.count; i++) {
                height += SkinParser.totalHeight((itemContainer?.getSubviewAt(i) as! IElement).skin!)
            }
        }
        return height
    }
    override func setSize(width:CGFloat, _ height:CGFloat){
        super.setSize(width,height)
        ElementModifier.size(itemContainer!, CGPoint(width,height))/*so that descendants is updated when the TreeList is resized*/
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}