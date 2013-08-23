![OpenFL-bitfive logo](https://raw.github.com/YellowAfterlife/openfl-microtests/master/assets/img/bitfive.png)
# openfl-bitfive
OpenFL-bitfive is an alternative backend to OpenFL-html5, intended for usage with canvas-driven applications, such as ones made with [HaxePunk](http://haxepunk.com/) or [HaxeFlixel](http://haxeflixel.com/) frameworks. It features mostly custom code with several classes (most importantly number of flash.net ones and ByteArray) being taken from original [OpenFL-html5](https://github.com/openfl/openfl-html5).

It currently is compatible with HaxePunk, will be compatible with HaxeFlixel later on (a minor change is needed for code to work), and may also work with other similar frameworks.

## Differences
A few to mention:
*	DisplayObject trees are presented as actual element trees with inheritance intact.
*	Optimized for performance and smaller "garbage generation" rates, where appropriate.
*	Completely rewritten BitmapData implementation. CopyPixels IS the fastest drawing method in many cases.
*	Slightly better compatibility across desktop and mobile browsers.
*	Easier to inspect DOM (see "node" property and variables while in Debug mode)

## Usage
Compiling (or at least trying to) your projects with openfl-bitfive is pretty straightforward:
1.	Install the library. I suppose that you can figure this out on your own.
2.	Navigate to application.xml of your project and add the following after inclusion of OpenFL library
```xml
<haxelib name="openfl-bitfive" if="html5" />
```
3.	Run the project. If everything was done right, first noticeable difference will be in stage background covering whole browser tab, as well as HTML elements forming a more common DOM tree and having "node" properties indicating their names in code (if ran in Debug mode).
4.	For audio to work equally in all browsers, project should also include OGG versions of audio files (as opposed to MP30. This can be done with code like this:
```xml
<assets path="assets/snd" rename="snd" include="*.ogg" if="html5" />
```

## Improving usage with HaxePunk
Several minor edits can be done to HaxePunk code to improve performance or gain other advantages:

### Running (most) games without web server
```haxe
// com.haxepunk.graphics.Canvas.render()
target.lock();
// ->
#if !bitfive target.lock(); #end
```
(and similarly)
```haxe
// com.haxepunk.graphics.Canvas.render()
target.unlock();
// ->
#if !bitfive target.unlock(); #end
```
Following common usage pattern, bitfive assumes that BitmapData.lock() precedes per-pixel manipulations. That means that it a ImageData instance should be retrieved for faster manipulations. Which in turn is not possible when running on local filesystem due to security restrictions.
For certain manipulations (in which per-pixel processing is unavoidable) web server will be needed though.

### Less doubtful buffering
```haxe
// com.haxepunk.Screen.swap()
_current = 1 - _current;
// ->
#if !bitfive _current = 1 - _current; #end
```
Double buffering is obviously pretty cool (citation needed), but has no positive effects in HTML5, where imagery is already redrawn "all at once". Disabling it, on other hand, frees browser from unnecessary DO swapping, granting 15-25% performance boost, depending on browser.

### Colours of the screen
```haxe
// com.haxepunk.Screen.set_color(value)
#if flash
// ->
#if flash||bitfive
```
BitmapData.fillRect operation is not expensive in bitfive, just as it isn't in Flash. Though you can leave this as-is - when clearing BitmapData with fillRect operation, width modification is used, which can be slightly faster in some browsers.

## Things that do not work (yet)
*	Graphics.drawTiles(). This will be added later.
*	BitmapData and Graphics objects can only be bound to a single DisplayObject at time.
*	TextField-related classes are fairly draft. These will make attempts to display provided text anyway (for sake of compatibility), but they do not support embed fonts and most of needed properties.
*	Touch events. JavaScript touch events are fairly different from Flash ones, making it not possible to "simply" convert between two. Mouse events will work just fine though.
*	BitmapFilters are currently not implemented, but will be later on.

## License
Actually I was going to write a mixed licence that would seem more appropriate for library of this kind, but that has to be well-thought (and couple other factors), so there's MIT licence for time being:
- - -
Copyright (C) 2013 Vadim "YellowAfterlife" Dyachenko

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Keep in touch
For updates and reports, this Github repository can be used.
Otherwise you can reach me on twitter:
[![@yellowafterlife](https://dl.dropboxusercontent.com/u/3594143/yal.cc/13-08/twitter.png)](http://twitter.com/yellowafterlife)