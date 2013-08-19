package openfl.utils;
#if js


import flash.utils.ByteArray;


interface IMemoryRange {
	
	public function getByteBuffer():ByteArray;
	public function getStart():Int;
	public function getLength():Int;
   
}


#end