import Cocoa

class SpinnerEvent :Event{
    static var change : String = "spinnerEventChange"
    var value:CGFloat
    init(_ type:String, _ value:CGFloat, _ origin:NSView){
        self.value = value
        super.init(type, origin)
    }
}