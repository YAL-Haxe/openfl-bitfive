package flash.filters;
#if js


import flash.geom.Point;
import flash.geom.Rectangle;
import js.html.CanvasElement;


class BitmapFilter {
	
	
	private var _mType:String;
	private var _nmeCached:Bool;
	

	public function new(inType:String) {
		
		_mType = inType;
		
	}
	
	
	public function clone():BitmapFilter {
		
		throw "Implement in subclass. BitmapFilter::clone";
		return null;
		
	}
	
	
	public function nmePreFilter(surface:CanvasElement) {
		
		
		
	}
	
	
	public function nmeApplyFilter(surface:CanvasElement, rect:Rectangle = null, refreshCache:Bool = false) {
		
		
		
	}
	
	
}


#end