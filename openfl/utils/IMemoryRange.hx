package openfl.utils;
#if js


import openfl.utils.ByteArray;


interface IMemoryRange {
	
	public function getByteBuffer():ByteArray;
	public function getStart():Int;
	public function getLength():Int;
   
}


#end