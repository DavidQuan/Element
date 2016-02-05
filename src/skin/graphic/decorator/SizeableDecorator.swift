import Foundation
/**
 * The responsibility of this class is to provide access to the position of the SizeableGraphic
 */
class SizeableDecorator:PositionalDecorator,ISizeable {
    var size:CGSize{
        get{
            if(decoratable is ISizeable){return (decoratable as! ISizeable).size}
            else{fatalError("Must subclass SizeableGraphic")}
        }
        set{
            if(decoratable is SizeableGraphic){(decoratable as! SizeableGraphic).size = newValue}//<--this line can be merged with the bellow line, just use as! ISizable
            else if(decoratable is SizeableDecorator){(decoratable as! SizeableDecorator).size = newValue}
            else{fatalError("Must subclass SizeableGraphic")}
        }
    }
    override func draw() {
        super.draw()
        
    }
    /**
     * NOTE: This method must remain an instance method so that other decorators can override it (Circle, Line, Path, etc)
     */
    func getSize() -> CGSize {
        return size
    }
    func setSizeValue(size: CGSize) {
        self.size = size
    }
}
