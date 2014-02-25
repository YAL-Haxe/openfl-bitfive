package flash.display;
import flash.geom.Matrix;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
#if js

class DisplayObjectContainer extends InteractiveObject {
	public var children(default, null):Array<DisplayObject>;
	public var numChildren(get, null):Int;
	public var mouseChildren:Bool;
	//
	public function new() {
		super();
		children = [];
		mouseChildren = true;
	}
	
	private function get_numChildren():Int {
		return children.length;
	}
	
	public function addChild(o:DisplayObject):DisplayObject {
		if (o.parent != null) o.parent.removeChild(o);
		o.parent = this;
		o.stage = stage;
		children.push(o);
		component.appendChild(o.component);
		var e:Event = new Event(Event.ADDED);
		o.dispatchEvent(e);
		this.dispatchEvent(e);
		return o;
	}
	
	public function removeChild(o:DisplayObject):DisplayObject {
		o.parent = null;
		o.stage = null;
		children.remove(o);
		component.removeChild(o.component);
		var e:Event = new Event(Event.REMOVED);
		o.dispatchEvent(e);
		this.dispatchEvent(e);
		return o;
	}
	
	public function addChildAt(o:DisplayObject, v:Int):DisplayObject {
		if (v < children.length) {
			if (o.parent != null) o.parent.removeChild(o);
			o.parent = this;
			o.stage = stage;
			component.insertBefore(o.component, children[v].component);
			children.insert(v, o);
			return o;
		} else return addChild(o);
	}
	
	public function removeChildAt(v:Int):DisplayObject {
		return removeChild(children[v]);
	}
	
	public function getChildAt(v:Int):DisplayObject {
		return children[v];
	}
	
	public function getChildIndex(v:DisplayObject):Int {
		var i:Int = -1, l:Int = children.length;
		while (++i < l) if (children[i] == v) return i;
		return -1;
	}
	
	public function contains(v:DisplayObject):Bool {
		for (o in children) if (o == v) return true;
		return false;
	}
	
	override public function broadcastEvent(e:Event):Void {
		dispatchEvent(e);
		for (o in children) o.broadcastEvent(e);
	}
	
	//
	override public function broadcastMouse(h:Array<DisplayObject>, e:MouseEvent,
	ms:Array<Matrix>, mc:Array<Matrix>):Bool {
		var r:Bool = false, l:Int = children.length, i:Int = children.length;
		// loop through child nodes, front-to-back:
		if (mouseChildren) {
			h.push(this);
			while (--i >= 0) r = r || children[i].broadcastMouse(h, e, ms, mc);
			h.pop();
		}
		// execute own check if everything fails:
		r = r || super.broadcastMouse(h, e, ms, mc);
		// clean-up:
		while (ms.length > h.length) mc.push(ms.pop());
		return r;
	}
	
	override public function hitTestLocal(x:Float, y:Float):Bool {
		var r:Bool = false, i:Int = children.length;
		while (--i >= 0) if (children[i].hitTestLocal(x, y)) return true;
		return false;
	}
	
	override private function set_stage(v:Stage):Stage {
		super.set_stage(v);
		for (o in children) o.set_stage(v);
		return v;
	}
}
#end