package flash.ui;
#if js


class Keyboard {
	//
	@:extern public static inline var NUMBER_0 = 48;
	@:extern public static inline var NUMBER_1 = 49;
	@:extern public static inline var NUMBER_2 = 50;
	@:extern public static inline var NUMBER_3 = 51;
	@:extern public static inline var NUMBER_4 = 52;
	@:extern public static inline var NUMBER_5 = 53;
	@:extern public static inline var NUMBER_6 = 54;
	@:extern public static inline var NUMBER_7 = 55;
	@:extern public static inline var NUMBER_8 = 56; 
	@:extern public static inline var NUMBER_9 = 57; 
	@:extern public static inline var A = 65;
	@:extern public static inline var B = 66;
	@:extern public static inline var C = 67;
	@:extern public static inline var D = 68;
	@:extern public static inline var E = 69;
	@:extern public static inline var F = 70;
	@:extern public static inline var G = 71;
	@:extern public static inline var H = 72;
	@:extern public static inline var I = 73;
	@:extern public static inline var J = 74;
	@:extern public static inline var K = 75;
	@:extern public static inline var L = 76;
	@:extern public static inline var M = 77;
	@:extern public static inline var N = 78;
	@:extern public static inline var O = 79;
	@:extern public static inline var P = 80;
	@:extern public static inline var Q = 81;
	@:extern public static inline var R = 82;
	@:extern public static inline var S = 83;
	@:extern public static inline var T = 84;
	@:extern public static inline var U = 85;
	@:extern public static inline var V = 86;
	@:extern public static inline var W = 87;
	@:extern public static inline var X = 88;
	@:extern public static inline var Y = 89;
	@:extern public static inline var Z = 90;
	
	@:extern public static inline var NUMPAD_0 = 96;
	@:extern public static inline var NUMPAD_1 = 97;
	@:extern public static inline var NUMPAD_2 = 98;
	@:extern public static inline var NUMPAD_3 = 99;
	@:extern public static inline var NUMPAD_4 = 100;
	@:extern public static inline var NUMPAD_5 = 101;
	@:extern public static inline var NUMPAD_6 = 102;
	@:extern public static inline var NUMPAD_7 = 103;
	@:extern public static inline var NUMPAD_8 = 104;
	@:extern public static inline var NUMPAD_9 = 105;
	@:extern public static inline var NUMPAD_MULTIPLY = 106;
	@:extern public static inline var NUMPAD_ADD = 107;
	@:extern public static inline var NUMPAD_ENTER = 108;
	@:extern public static inline var NUMPAD_SUBTRACT = 109;
	@:extern public static inline var NUMPAD_DECIMAL = 110;
	@:extern public static inline var NUMPAD_DIVIDE = 111;
	
	@:extern public static inline var F1 = 112;
	@:extern public static inline var F2 = 113;
	@:extern public static inline var F3 = 114;
	@:extern public static inline var F4 = 115;
	@:extern public static inline var F5 = 116;
	@:extern public static inline var F6 = 117;
	@:extern public static inline var F7 = 118;
	@:extern public static inline var F8 = 119;
	@:extern public static inline var F9 = 120;
	@:extern public static inline var F10 = 121; //  F10 is used by browser.
	@:extern public static inline var F11 = 122;
	@:extern public static inline var F12 = 123;
	@:extern public static inline var F13 = 124;
	@:extern public static inline var F14 = 125;
	@:extern public static inline var F15 = 126;
	
	@:extern public static inline var BACKSPACE = 8;
	@:extern public static inline var TAB = 9;
	@:extern public static inline var ENTER = 13;
	@:extern public static inline var SHIFT = 16;
	@:extern public static inline var CONTROL = 17;
	@:extern public static inline var CAPS_LOCK = 18;
	@:extern public static inline var ESCAPE = 27;
	@:extern public static inline var SPACE = 32;
	@:extern public static inline var PAGE_UP = 33;
	@:extern public static inline var PAGE_DOWN = 34;
	@:extern public static inline var END = 35;
	@:extern public static inline var HOME = 36;
	@:extern public static inline var LEFT = 37;
	@:extern public static inline var RIGHT = 39;
	@:extern public static inline var UP = 38;
	@:extern public static inline var DOWN = 40;
	@:extern public static inline var INSERT = 45;
	@:extern public static inline var DELETE = 46;
	@:extern public static inline var NUMLOCK = 144;
	@:extern public static inline var BREAK = 19;
	
	public static var capsLock(default, null):Bool;
	public static var numLock(default, null):Bool;
	
	
	public static function isAccessible():Bool {
		
		// default browser security restrictions are always enforced
		return false;
		
	}
}
#end
