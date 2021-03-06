import Cocoa

class ElementParser{
    /**
     * Returns all children in @param element that is of type IElement
     * NOTE: if this doesnt work just use the array casting technique with the NSParser.children method
     */
    class func children<T>(view:NSView,_ type:T.Type)->Array<T> {
        return NSViewParser.childrenOfType(view, type);
    }
    /**
     * Returns an Array instance comprised of Selector instances for each (element,classId,id and state) in the element "cascade" (the spesseficity)
     * @Note to get the stackString use: print(SelectorUtils.toString(StyleResolver.stack(checkButton)));
     */
    class func selectors(element:IElement)->Array<ISelector>{
        //Swift.print("ElementParser.selectors()")
        let elements:Array<IElement> = ArrayModifier.append(parents(element),element)
        var selectors:Array<ISelector> = []
        for  e : IElement in elements {
            selectors.append(selector(e));
        }
        return selectors;
    }
    /**
     *
     */
    class func selector(element:IElement)->ISelector{
        let selector:Selector = Selector();
        selector.element = element.getClassType();
        //if(e.classId != null) selector.classIds = e.classId.indexOf(" ") != -1 ? e.classId.split(" ") : [e.classId];
        selector.id = element.id ?? "";
        selector.states = (element.skin != nil ? element.skin!.state : element.getSkinState()).match("\\b\\w+\\b");/*Matches words with spaces between them*/
        return selector
    }
    /**
     * Returns an array populated with IElement parents of the target (Basically the ancestry)
     */
    class func parents(element:IElement)->Array<IElement> {
        var parents:Array<IElement> = [];
        var parent:IElement? = element.getParent() as? IElement// :TODO: seperate this into a check if its DO then that, if its Window then do that
        while(parent != nil) {//loops up the object hierarchy as long as the parent is a Element supertype
            ArrayModifier.unshift(&parents,parent!)
            parent = parent!.getParent() as? IElement
        }
        return parents;
    }
    /**
     * This method can be used to print the StyleSelector for an Element instance 
     * Returns the absolute ancestry as a space delimited string in this format: elementId:classIds#id:states
     */
    class func stackString(element:IElement)->String{
        return SelectorParser.string(selectors(element))
    }
}