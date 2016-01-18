import Foundation

class SVGAsset:BaseGraphic {
    var svg:SVG;
    var width:CGFloat
    var height:CGFloat
    var x:CGFloat
    var y:CGFloat
    init(_ path:String, _ position: CGPoint, _ size: CGSize, _ decoratable: IGraphicDecoratable) {
        Swift.print("SVGAsset.init()")
        width = size.width
        height = size.height
        x = position.x
        y = position.y
        //var xml:XML = FileParser.xml(new File(File.applicationDirectory.url+path));
        let content = FileParser.content(path.tildePath)
        let xmlDoc:NSXMLDocument = try! NSXMLDocument(XMLString: content!, options: 0)
        let rootElement:NSXMLElement = xmlDoc.rootElement()!
        svg = SVGParser.svg(rootElement);
        super.init()
        graphic.addSubview(svg)
    }
    override func drawFill() {
        Swift.print("SVGAsset.drawFill()")
        
        let scale:CGPoint = CGPoint(width/svg.width,height/svg.height);
        SVGModifier.scale(svg, CGPoint(x,y), scale);
        
        
        //CGRect(x,y,width,height)
        
        //CGRect(0,0,width,height)
    }
    override func drawLine() {
        //nothing
    }
    override func fill() {
        if(graphic.fillStyle != nil && graphic.lineStyle != nil){
            Swift.print("SVGAsset.fill()")
            //Swift.print("lineStyle: " + "\(lineStyle)")
            //Swift.print("fillStyle.color: " + "\(fillStyle.color)")
            //Swift.print("fillStyle.alpha: " + "\(fillStyle.alpha)")
            //Swift.print("lineStyle.color: " + "\(lineStyle.color)")
            //Swift.print("lineStyle.alpha: " + "\(lineStyle.alpha)")
            //Swift.print("lineStyle.thickness: " + "\(lineStyle.thickness)")
            //Swift.print("lineStyle.capStyle: " + "\(lineStyle.capStyle)")
            //Swift.print("lineStyle.jointStyle: " + "\(lineStyle.jointStyle)")
            //Swift.print("lineStyle.miterLimit: " + "\(lineStyle.miterLimit)")
            let fillStyle:IFillStyle = graphic.fillStyle!
            let lineStyle:ILineStyle = graphic.lineStyle!
            let svgStyle = SVGStyle(fillStyle.color,fillStyle.color.alphaComponent,nil,lineStyle.thickness,lineStyle.color,lineStyle.color.alphaComponent,LineStyleParser.lineCapType(lineStyle.lineCap),LineStyleParser.lineJoinType(lineStyle.lineJoin),lineStyle.miterLimit)
            SVGModifier.style(svg, svgStyle)
        }
    }
    override func line() {
        //nothing
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
        
    
}