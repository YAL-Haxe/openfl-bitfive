package flash.display;
import flash.display.Stage;
import flash.events.Event;
#if js

class DisplayObjectContainer extends InteractiveObject {
	public var children(default, null):Array<DisplayObject>;
	public var numChildren(get, null):Int;
	//
	public function new() {
		super();
		children = [];
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
	
	override private function set_stage(v:Stage):Stage {
		super.set_stage(v);
		for (o in children) o.set_stage(v);
		return v;
	}
}
#end