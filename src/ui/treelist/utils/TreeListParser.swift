import Cocoa

class TreeListParser{
    /**
     * Returns the total height of the items
     * @Note another name for this could be getTotalItemsHeight?
     */
    class func itemsHeight(treeList:ITreeList)->CGFloat{
        var height:CGFloat = 0
        for (var i : Int = 0; i < treeList.itemContainer.subviews.count; i++) {
            height += treeList.itemContainer.getSubviewAt(i) is TreeListItem ? (treeList.itemContainer.getSubviewAt(i) as! TreeListItem).getHeight() : (treeList.itemContainer.getSubviewAt(i) as! Element).getHeight()
        }
        return height
    }
    /**
     * Returns an array of descendants in @param treeList
     */
    class func descendants(treeList:ITreeList)->Array<ITreeList>{
        var items:Array<ITreeList> = []
        let numChildren:Int = treeList.itemContainer.subviews.count
        for (var i : Int = 0; i < numChildren; i++) {
            let view:NSView = treeList.itemContainer.getSubviewAt(i)
            items.append(view as! ITreeList)
            if(view is ITreeList) {items += (descendants(view as! ITreeList))}
        }
        return items
    }
    /**
     *
     */
    class func decendantsOfType<T>(treeList:ITreeList,_ type:T.Type? = nil)->Array<ITreeList> {
        var items:Array<ITreeList> = []
        for (var i : Int = 0; i < treeList.itemContainer.subviews.count; i++) {
            let view:NSView = treeList.itemContainer.getSubviewAt(i)
            if(type == nil || (type != nil && view as? T != nil)) {//<--Inspired from the ClassParser.ofType() method
                items.append(view as! ITreeList)
                items += (decendantsOfType(view as! ITreeList,type))
            }
        }
        return items
    }
    /**
     * Returns the index of @param item from @param treeList
     * // :TODO: this code could possibly be optimized Check similar function: XMLParser.index(xml,attribute) this has simpler syntax
     */
    class func index(treeList:ITreeList,_ item:NSView)->Array<Int> {
        var index:Array<Int> = []
        for (var i : Int = 0; i < treeList.itemContainer.subviews.count; i++) {
            let view:NSView = treeList.itemContainer.getSubviewAt(i)
            if(view === item) {index = [i]}
            else if (view is ITreeList && (view as! ITreeList).itemContainer.subviews.count > 0){
                let tempIndex:Array<Int> = (TreeListParser.index(view as! ITreeList, item))
                if(tempIndex.count > 0) {index = [i] + tempIndex}
            }
        }
        return index
    }
    /**
     * Returns the index of the selected ISelectable instance in @param treeList
     */
    class func selectedIndex(treeList:ITreeList) -> Array<Int>{
        return index(treeList, selected(treeList) as! NSView)
    }
    /**
     * Returns the selected ISelectable instance in the @param treeList
     */
    class func selected(treeList:ITreeList)->ISelectable?{
        var selectable:ISelectable?
        for (var i : Int = 0; i < treeList.itemContainer.subviews.count; i++) {
            let treeItem:NSView = treeList.itemContainer.getSubviewAt(i)
            if(treeItem is ISelectable && (treeItem as! ISelectable).isSelected) {selectable = treeItem as? ISelectable}
            if(treeItem is ITreeListItem && (treeItem as! ISelectable).isSelected) {selectable = TreeListParser.selected(treeItem as! ITreeList)}
            if(selectable != nil) {break}//<--what does this break do?
        }
        return selectable
    }
    /**
    * Returns an NSView instance at @param index in @param treeList
    */
    class func itemAt(treeList:ITreeList,_ index:Array<Int>) -> NSView{
        if(index.count == 1 && treeList.itemContainer.subviews.count > index[0] != nil) {
            return treeList.itemContainer.getChildAt(index[0]);
        }else if(index.length > 1 && treeList.itemContainer.numChildren > 0 && treeList.itemContainer.getChildAt(index[0]) as ITreeList) {
            return itemAt(treeList.itemContainer.getChildAt(index[0]) as ITreeList, index.slice(1, index.length));
        }else {
            return treeList as DisplayObject;/*index.length == 0*/
        }
    }
}
