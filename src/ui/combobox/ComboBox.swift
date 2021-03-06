import Cocoa
/** 
 * @Note for multiSelect option make MultiCheckComboBox.as aand CheckComboBox?
 * @Note: to get the height while the list is pulled down: comboBox.height * comboBox.maxShowingItems
 * // :TODO: add isScrollBarVisible as an argument at the end, butbefore, parent and name
 * // :TODO: add a way to set the init selected list item, and have this update the header, (if headerText != null that is)
 * // :TODO: add height as an argument to the constructor
 * // :TODO: find a way to add a mask that can have rounded corners, if a TextButton has a square fill then it overlaps outside the combobox
 * //closeOnClick
 * //defaultText
 */
class ComboBox:Element{
    var headerButton:TextButton?
    var itemHeight:CGFloat// :TODO: this should be set in the css?
    var dataProvider:DataProvider?
    var list:SliderList?
    var isOpen:Bool
    var depth:Int?/*used to store the temp sprite depth so the popover can hover over other instance siblings*/
    var initSelected:Int
	init(_ width:CGFloat = NaN, _ height:CGFloat = NaN, _ itemHeight:CGFloat = NaN ,_ dataProvider:DataProvider? = nil, _ isOpen:Bool = false, _ initSelected:Int = 0, _ parent:IElement? = nil, _ id:String? = nil){
		self.itemHeight = itemHeight
		self.dataProvider = dataProvider
		self.isOpen = isOpen
		self.initSelected = initSelected
		super.init(width,height,parent,id)
	}
	override func resolveSkin(){
		super.resolveSkin()
		headerButton = addSubView(TextButton(width, itemHeight,"", self))// :TODO: - _itemHeight should be something else
        list = /*addSubView*/(SliderList(width, height, itemHeight, dataProvider, self))
        ListModifier.selectAt(list!, initSelected)
        headerButton!.setTextValue(ListParser.selectedTitle(list!))
        setOpen(isOpen)
	}
	func onHeaderMouseDown(event:ButtonEvent) {
		setOpen(!isOpen)
        super.onEvent(ComboBoxEvent(ComboBoxEvent.headerClick,ListParser.selectedIndex(list!),self))/*send this event*/
	}
	func onGlobalClick() {//On clicks outside combobox, close the combobox
		//if (!hitTestPoint(x, y)) {//you sort of check if the mouse-click didnt happen within the bounds of the comboBox
			//setOpen(false);
			//remove the globalListener here
		//}
	}
	/**
	 * the select event should be fired only onReleaseInside not as it is now onPress
	 */
	func onListSelect(event:ListEvent) {
		let text:String = ListParser.selectedTitle(list!)
		headerButton!.setTextValue(text)
		setOpen(false)
	}
	override func onEvent(event:Event){
		if(event.type == ListEvent.select && event.origin === list){onListSelect(event as! ListEvent)}
		if(event.type == ButtonEvent.down && event.origin === headerButton){onListSelect(event as! ListEvent)}
	}
	func setOpen(isOpen:Bool) {
		/*
        if(isOpen){
			depth = (getParent(true) as! NSView).getSubViewIndex(self)
			DepthModifier.toFront(this,getParent(true))// :TODO: will this work in Element 2 framework? it does for now, and use parennt.setChildIndex this method is old
		}else if(self.window != null) (getParent(true) as! NSView).setSubViewIndex(self, depth)
		self.isOpen = isOpen// :TODO: here is the problem since if you resize the skin is updated and visible is reset, also mask in list should be an element with float and clear set to none, do a test and see if you can overlap 2 elements
		ElementModifier.hide(list, isOpen)
		if(isOpen && window != null && !window.hasEventListener(MouseEvent.MOUSE_DOWN)) {}//add globalListener
		if(!isOpen && window != null && widn.hasEventListener(MouseEvent.MOUSE_DOWN)) {}//remove globalListener // :TODO: fix this mess
        */
	}
	override func setSize(width:CGFloat, _ height:CGFloat)  {
		super.setSize(width, height)
		list!.setSize(width, StylePropertyParser.height(list!.skin!)!)/*temp solution*/
		headerButton!.setSize(width, StylePropertyParser.height(headerButton!.skin!)!)/*temp solution*/
	}
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}