package flash.utils;
#if js

import flash.errors.IOError;
import flash.utils.UInt;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesData;
import haxe.io.Input;
import js.html.DataView;
import js.html.Uint8Array;
#if format
import format.tools.Inflate;
#end

/**
 * Did a couple edits here in attempt to reduce output size.
 */
@:autoBuild(openfl.Assets.embedFile())
class ByteArray implements ArrayAccess<Int> {
	
	
	public var bytesAvailable(get, null):Int;
	public var endian(get, set):String;
	public var length(default, set):Int = 0;
	public var objectEncoding:Int;
	public var position:Int = 0;
	
	private var allocated:Int = 0;
	public var byteView:Uint8Array;
	private var data:DataView;
	// NOTE: default ByteArray endian is BIG_ENDIAN
	private var littleEndian:Bool = false;
	
	
	public function new():Void {
		
		_nmeResizeBuffer(allocated);
		//this.byteView = untyped __new__("Uint8Array", allocated);
		//this.data = untyped __new__("DataView", this.byteView.buffer);
		
	}
	
	
	public function __get(pos:Int):Int { return data.getUint8(pos); }
	public function __set(pos:Int, v:Int):Void { data.setUint8(pos, v); }
	
	
	private function _getUTFBytesCount(value:String):Int {
		
		var count:Int = 0;
		// utf8-decode
		
		for (i in 0...value.length) {
			
			var c = StringTools.fastCodeAt(value, i);
			
			if (c <= 0x7F) {
				
				count += 1;
				
			} else if (c <= 0x7FF) {
				
				count += 2;
				
			} else if (c <= 0xFFFF) {
				
				count += 3;
				
			} else {
				
				count += 4;
				
			}
			
		}
		
		return count;
		
	}
	
	
	private function _nmeResizeBuffer(len:Int):Void {
		var oldByteView:Uint8Array = this.byteView;
		var newByteView:Uint8Array = untyped __new__("Uint8Array", len);
		
		if (oldByteView != null) {
			if (oldByteView.length <= len) newByteView.set(oldByteView);
			else newByteView.set(oldByteView.subarray(0, len));
		}

		this.byteView = newByteView;
		this.data = new DataView(newByteView.buffer);
		
	}
	
	
	public function clear() {
		length = position = 0;
	}
	
	
	@:extern private inline function ensureWrite(l:Int):Void {
		if (this.length < l) this.length = l;
	}
	
	public static function fromBytes(inBytes:Bytes) {
		var r = new ByteArray();
		r.nmeFromBytes(inBytes);
		return r;
	}
	
	private inline function nmeFromBytes(inBytes:Bytes):Void {
		byteView = untyped __new__("Uint8Array", inBytes.getData());
		length = byteView.length;
		allocated = length;
	}
	
	public inline function nmeGet(pos:Int):Int {
		return data.getUint8(pos);
	}
	
	
	public inline function nmeGetBuffer() {
		return data.buffer;
	}
	
	
	public static function nmeOfBuffer(buffer:ArrayBuffer):ByteArray {
		var r = new ByteArray();
		r.length = r.allocated = buffer.byteLength;
		r.data = new DataView(buffer);
		r.byteView = new Uint8Array(buffer);
		return r;
	}
	
	
	public inline function nmeSet(p:Int, v:Int):Void {
		data.setUint8(p, v);
	}
	
	
	public inline function readBoolean():Bool {
		return (this.readByte() != 0);
	}
	
	
	public inline function readByte():Int {
		return data.getUint8(this.position++);
	}
	
	
	public function readBytes(bytes:ByteArray, ?offset:Int, ?length:Int):Void {
		if (offset == null) offset = 0;
		if (length == null) length = this.length;
		if (offset < 0 || length < 0) throw new IOError("Read error - Out of bounds");		
		
		bytes.ensureWrite(offset + length);
		
		bytes.byteView.set(byteView.subarray(this.position, this.position + length), offset);
		bytes.position = offset;
		
		this.position += length;
		if (bytes.position + length > bytes.length) bytes.length = bytes.position + length;
		
	}
	
	
	public function readDouble():Float {
		var r = data.getFloat64(this.position, littleEndian);
		this.position += 8;
		return r;
	}
	
	
	public function readFloat():Float {
		var r = data.getFloat32(this.position, littleEndian);
		this.position += 4;
		return r;
	}
	
	
	private function readFullBytes(bytes:Bytes, pos:Int, len:Int):Void {
		// NOTE: It is used somewhere?
		ensureWrite(len);
		for (i in pos...(pos + len)) {
			data.setInt8(this.position++, bytes.get(i));
		}
	}
	
	public function readInt():Int {
		var r = data.getInt32(this.position, littleEndian);
		this.position += 4;
		return r;
	}
	
	public function readShort():Int {
		var r = data.getInt16(this.position, littleEndian);
		this.position += 2;
		return r;
	}
	
	
	public inline function readUnsignedByte():Int {
		return data.getUint8(this.position++);
	}
	
	
	public function readUnsignedInt():Int {
		var uInt = data.getUint32(this.position, littleEndian);
		this.position += 4;
		return uInt;
	}
	
	
	public function readUnsignedShort():Int {
		var r = data.getUint16(this.position, littleEndian);
		this.position += 2;
		return r;
	}
	
	public function readUTF():String {
		return readUTFBytes(readUnsignedShort());
	}
	
	public function readUTFBytes(len:Int):String {
		var r = "", max = this.position + len;
		// utf8-encode
		while (this.position < max) {
			var c = data.getUint8(this.position++);
			if (c < 0x80) {
				if (c == 0) break; // EOF
				r += String.fromCharCode(c);
			} else if (c < 0xE0) {
				r += String.fromCharCode(((c & 0x3F) << 6) |(data.getUint8(this.position++) & 0x7F));
			} else if (c < 0xF0) {
				var c2 = data.getUint8(this.position++);
				r += String.fromCharCode(((c & 0x1F) << 12) |((c2 & 0x7F) << 6) |(data.getUint8(this.position++) & 0x7F));
			} else {
				var c2 = data.getUint8(this.position++);
				var c3 = data.getUint8(this.position++);
				r += String.fromCharCode(((c & 0x0F) << 18) |((c2 & 0x7F) << 12) |((c3 << 6) & 0x7F) |(data.getUint8(this.position++) & 0x7F));
			}
		}
		return r;
	}
	
	
	public function toString():String {
		var o = position, r;
		position = 0;
		r = readUTFBytes(length);
		position = o;
		return r;
	}
	
	public function toBase64():String {
		var o:ByteArray = this, q = o.position, l = o.length, p = -1, v:DataView = o.data,
			r:String = "",
			m:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
			a:Int, b:Int, c:Int;
		while (++p < l) {
			a = v.getUint8(p);
			b = ++p < l ? v.getUint8(p) : 0;
			c = ++p < l ? v.getUint8(p) : 0;
			r += m.charAt(a >> 2)
				+ m.charAt(((a & 0x3) << 4) | (b >> 4))
				+ (p - 1 < l ? m.charAt(((b & 0xF) << 2) | (c >> 6)) : "=")
				+ (p < l ? m.charAt(c & 0x3F) : "=");
		}
		return r;
	}
	
	
	#if format
	public function uncompress():Void {
		var bytes = Bytes.ofData(cast byteView);
		var buf = Inflate.run(bytes).getData();
		this.byteView = untyped __new__("Uint8Array", buf);
		this.data = untyped __new__("DataView", byteView.buffer);
		this.length = this.allocated = byteView.buffer.byteLength;
	}
	#end
	
	
	public inline function writeBoolean(v:Bool):Void {
		this.writeByte(v ? 1 : 0);
	}
	
	
	public function writeByte(v:Int):Void {
		ensureWrite(this.position + 1);
		var data:Dynamic = data;
		data.setInt8(this.position, v);
		this.position += 1;
	}
	
	
	public function writeBytes(bytes:ByteArray, ?offset:UInt, ?length:UInt):Void {
		if (offset < 0 || length < 0) throw new IOError("Write error - Out of bounds");
		
		ensureWrite(this.position + length);
		byteView.set(bytes.byteView.subarray(offset, offset + length), this.position);
		this.position += length;
	}
	
	
	public function writeDouble(x:Float):Void {
		
		ensureWrite(this.position + 8);
		data.setFloat64(this.position, x, littleEndian);
		this.position += 8;
		
	}
	
	
	public function writeFloat(x:Float):Void {
		
		ensureWrite(this.position + 4);
		data.setFloat32(this.position, x, littleEndian);
		this.position += 4;
		
	}
	
	
	public function writeInt(value:Int):Void {
		
		ensureWrite(this.position + 4);
		data.setInt32(this.position, value, littleEndian);
		this.position += 4;
		
	}
	
	
	public function writeShort(value:Int):Void {
		
		ensureWrite(this.position + 2);
		data.setInt16(this.position, value, littleEndian);
		this.position += 2;
		
	}
	
	
	public function writeUnsignedInt(value:Int):Void {
		
		ensureWrite(this.position + 4);
		data.setUint32(this.position, value, littleEndian);
		this.position += 4;
		
	}
	
	
	public function writeUnsignedShort(value:Int):Void {
		
		ensureWrite(this.position + 2);
		data.setUint16(this.position, value, littleEndian);
		this.position += 2;
		
	}
	
	
	public function writeUTF(value:String):Void {
		
		writeUnsignedShort(_getUTFBytesCount(value));
		writeUTFBytes(value);
		
	}
	
	
	public function writeUTFBytes(value:String):Void {
		
		// utf8-decode
		for (i in 0...value.length) {
			
			var c = StringTools.fastCodeAt(value, i);
			
			if (c <= 0x7F) {
				
				writeByte(c);
				
			} else if (c <= 0x7FF) {
				
				writeByte(0xC0 |(c >> 6));
				writeByte(0x80 |(c & 63));
				
			} else if (c <= 0xFFFF) {
				
				writeByte(0xE0 |(c >> 12));
				writeByte(0x80 |((c >> 6) & 63));
				writeByte(0x80 |(c & 63));
				
			} else {
				
				writeByte(0xF0 |(c >> 18));
				writeByte(0x80 |((c >> 12) & 63));
				writeByte(0x80 |((c >> 6) & 63));
				writeByte(0x80 |(c & 63));
				
			}
			
		}
		
	}
	
	// Getters & Setters
	
	private inline function get_bytesAvailable():Int { return length - position; }
	
	private inline function get_endian():String {
		return littleEndian ? Endian.LITTLE_ENDIAN : Endian.BIG_ENDIAN;
	}
	
	private inline function set_endian(endian:String):String {
		littleEndian = endian == Endian.LITTLE_ENDIAN;
		return endian;
	}
	
	private /*inline*/ function set_length(value:Int):Int {
		if (allocated < value)
			_nmeResizeBuffer(allocated = Std.int(Math.max(value, allocated * 2)));
		else if (allocated > value)
			_nmeResizeBuffer(allocated = value);
		return (length = value);
	}
	
}
#end
