import Cocoa

class SelectParser {
    /**
     * Returns the  first selected ISelectable in an array of an NSView with ISelectables
     */
    class func selected(view:NSView) -> ISelectable? {
        let selectables:Array<ISelectable> = self.selectables(view)
        return selected(selectables)
    }
    /**
     * Returns the  first selected ISelectable in an array of ISelectables or a
     */
    class func selected(selectables:Array<ISelectable>) -> ISelectable? {
        for selectable : ISelectable in selectables {if(selectable.isSelected) {return selectable}}
        return nil
    }
    /**
     * Returns an array from every child that is an ISelectable in @param displayObjectContainer
     */
    class func selectables(view:NSView)->Array<ISelectable> {
        return NSViewParser.childrenOfType(view, ISelectable.self);
    }
}