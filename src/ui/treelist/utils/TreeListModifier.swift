import Cocoa
/**
 * TODO: some way to move items up/down the hierarchy
 */
class TreeListModifier {
    /**
     * Scrolls the treeList to a scalar position (value 0-1)
     */
    class func scrollTo(treeList:ITreeList,_ progress:CGFloat){
        treeList.itemContainer!.y = SliderParser.y(progress, treeList.getHeight(),  TreeListParser.itemsHeight(treeList))
    }
    /**
     * @Note: to explode the entire treeList pass an empty array as @param index
     */
    class func explodeAt(var treeList:ITreeList,_ index:Array<Int>) {
        treeList = TreeListParser.itemAt(treeList, index) as! ITreeList
        if(treeList is ITreeListItem){(treeList as! ITreeListItem).open()}
        let decendants:Array<ITreeListItem> = TreeListParser.decendantsOfType(treeList,ITreeListItem.self)
        for treeListItem:ITreeListItem in decendants{
            if(!(treeListItem as! ICheckable).getChecked()) {treeListItem.open()}
        }
    }
    /**
     * @Note: to collapse the entire treeList pass an empty array as @param index
     * @Note this method collapses all nodes from the @param index
     */
    class func collapseAt(var treeList:ITreeList,_ index:Array<Int>) {
        treeList = TreeListParser.itemAt(treeList, index) as! ITreeList
        let decendants:Array<ITreeListItem> = TreeListParser.decendantsOfType(treeList,ITreeListItem.self)
        //Swift.print("decendants.count: " + "\(decendants.count)")
        for treeListItem : ITreeListItem in decendants {
            //Swift.print("treeListItem: " + "\(treeListItem)")
            if((treeListItem as! ICheckable).getChecked()) {treeListItem.close()}
        }
    }
    /**
     * @Note this method is recursive
     * NOTE: Use TreeList.node.addAt method if you want to add things to the TreeList, this method is then eventually used internally
     */
    class func addAt(treeList:ITreeList,_ index:Array<Int>,_ item:NSView) {
        if(index.count == 1) {treeList.addItemAt(item,index[0])}
        else if(index.count > 1 && treeList.itemContainer!.subviews.count > 0 && treeList.itemContainer!.getSubViewAt(index[0]) is ITreeList) {
            addAt(treeList.itemContainer!.getSubViewAt(index[0]) as! ITreeList, index.slice2(1,index.count),item)
        }
    }
    /**
     * Sets a selectable in @param treeList at @param index (array index)
     * NOTE: this does not unselect previously selected items. 
     */
    class func selectAt(treeList:ITreeList, _ index:Array<Int>,_ isSelected:Bool = true) {
        if(index.count == 1 && treeList.itemContainer!.subviews.count > 0 && treeList.itemContainer!.getSubViewAt(index[0]) is ISelectable) {
            (treeList.itemContainer!.getSubViewAt(index[0]) as! ISelectable).setSelected(isSelected)
        }
        else if(index.count > 1 && treeList.itemContainer!.subviews.count > 0 && treeList.itemContainer!.getSubViewAt(index[0]) is ITreeList) {
            selectAt(treeList.itemContainer!.getSubViewAt(index[0]) as! ITreeList, index.slice2(1,index.count),isSelected)
        }
    }
    /**
     *
     */
    class func setTitleAt(treeList:ITreeList, _ index:Array<Int>, _ name:String){
        if(index.count == 1 && treeList.itemContainer!.subviews.count > 0 && treeList.itemContainer!.getSubViewAt(index[0]) is TextButton) {
            treeList.itemContainer!.getSubViewAt(index[0]) is TextButton ? (treeList.itemContainer!.getSubViewAt(index[0]) as! TextButton).setTextValue(name) : (treeList.itemContainer!.getSubViewAt(index[0]) as! TreeListItem).text!.setText(name)
        }
        else if(index.count > 1 && treeList.itemContainer!.subviews.count > 0 && treeList.itemContainer!.getSubViewAt(index[0]) is ITreeList) {
            setTitleAt(treeList.itemContainer!.getSubViewAt(index[0]) as! ITreeList, index.slice2(1,index.count),name)
        }
    }
    /**
     * Removes an NSView instance at @param index in @param treeList
     * NOTE: Use TreeList.node.removeAt method if you want to add things to the TreeList, this method is then eventually used internally 
     */
    class func removeAt(treeList:ITreeList,_ index:Array<Int>) {
        if(index.count == 1 && treeList.itemContainer!.subviews.count > 0 && treeList.itemContainer!.getSubViewAt(index[0]) != nil) {
            treeList.removeAt(index[0])
        }else if(index.count > 1 && treeList.itemContainer!.subviews.count > 0 && treeList.itemContainer!.getSubViewAt(index[0]) is ITreeList) {
            removeAt(treeList.itemContainer!.getSubViewAt(index[0]) as! ITreeList, index.slice2(1,index.count))
        }
    }
    /**
     * Removes an NSView instance in @param treeList
     */
    class func remove(treeList:ITreeList,_ item:NSView) {
        let index:Array<Int> = TreeListParser.index(treeList, item)
        removeAt(treeList, index)
    }
    /**
     *
     */
    class func removeAll(treeList:ITreeList) {
        while(treeList.itemContainer!.subviews.count > 0) {removeAt(treeList, [0])}
    }
    /**
     * // :TODO: can this work?
     */
    class func setSelected(treeList:TreeList, _ key:String, _ value:String) {
        let index:Array<Int> = XMLParser.index(treeList.node.xml, key, value)!
        selectAt(treeList, index)
    }
    /**
     * @Note: this function works as long as multiple selection is not allowed in the treeList
     */
    class func unSelectAll(treeList:ITreeList){
        let selectedIndex:Array<Int> = TreeListParser.selectedIndex(treeList)
        if(selectedIndex.count > 0) {selectAt(treeList, selectedIndex, false)}
    }
    /**
     * @Note the @param index is modified so its wise to clone the array if you wish to use it later
     * // :TODO: use the newIndex to your advantage with slice and the index doesnt have to be modified
     */
    class func moveUp(treeList:TreeList,var index:Array<Int>) -> Array<Int> {
        let removed:NSXMLElement = treeList.node.removeAt(index)
        var integer:Int = index.pop()!
        integer = integer > 0 ? integer-1:0
        let newIndex:Array<Int> = index + [integer]
        treeList.node.addAt(newIndex, removed)
        return newIndex
    }
    /**
     * Moves an item down 1 integer at @param index on the TreeList instance @param treeList
     * @return the new index
     * @param index the index to move from
     * @Note the @param index is modified so make sure you pass a clone of the array
     * // :TODO: fix the code so that it doesnt modifify the @param index
     * // :TODO: what if its already at the bottom?
     * // :TODO: could we have another method maybe? moveToIndex?
     * // :TODO: what about moveUpLevel?
     * // :TODO: do we really need to go from DisplayObject to xml and then again to DisplayObject?, is there a way to grab the DisplayObject, adjust the parent and so forth?, its probably easier for now, remember that the database must mirror the DisplayObject structure
     */
    class func moveDown(treeList:TreeList,var _ index:Array<Int>) -> Array<Int> {
        let removed:NSXMLElement = treeList.node.removeAt(index);
        let childrenCount:Int = NodeParser.childrenCount(treeList.node, index.slice2(0,index.count-1))
        var integer:Int = index.pop()!
        integer = integer < childrenCount ? integer+1:childrenCount
        let newIndex:Array<Int> = index + [integer]
        treeList.node.addAt(newIndex, removed)
        return newIndex
    }
    /**
     *
     */
    class func moveToTop(treeList:TreeList,_ index:Array<Int>) -> Array<Int> {
        let removed:NSXMLElement = treeList.node.removeAt(index)
        let newIndex:Array<Int> = index.slice2(0,index.count-1) + [0]
        treeList.node.addAt(newIndex, removed)
        return newIndex
    }
    /**
     *
     */
    class func moveToBottom(treeList:TreeList,_ index:Array<Int>) -> Array<Int> {
        let removed:NSXMLElement = treeList.node.removeAt(index)
        let childrenCount:Int = NodeParser.childrenCount(treeList.node, index.slice2(0,index.count-1))
        let newIndex:Array<Int> = index.slice2(0,index.count-1) + [childrenCount]
        treeList.node.addAt(newIndex, removed)
        return newIndex
    }
}