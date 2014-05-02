![OpenFL-bitfive logo](https://raw.github.com/YellowAfterlife/openfl-microtests/master/assets/img/bitfive.png)
# openfl-bitfive
OpenFL-bitfive is an alternative backend to OpenFL-html5, intended for usage with canvas-driven applications, such as ones made with [HaxePunk](http://haxepunk.com/) or [HaxeFlixel](http://haxeflixel.com/) frameworks. It features mostly custom code with several classes (most importantly number of flash.net ones and ByteArray) being taken from original [OpenFL-html5](https://github.com/openfl/openfl-html5).

It currently is compatible with HaxePunk and HaxeFlixel. It may also work with other similar frameworks.

## Differences
A few to mention:
*	DisplayObject trees are presented as actual element trees with inheritance intact.
*	Optimized for performance and smaller "garbage generation" rates, where appropriate.
*	Completely rewritten BitmapData implementation. CopyPixels IS the fastest drawing method in many cases.
*	Slightly better compatibility across desktop and mobile browsers.
*	Easier to inspect DOM (see "node" property and variables while in Debug mode)

## Usage
Compiling (or at least trying to) your projects with openfl-bitfive is pretty straightforward:
Install the library. I suppose that you can figure this out on your own.

Navigate to application.xml of your project and add the following before inclusion of OpenFL library:
```xml
<set name="html5-backend" value="openfl-bitfive" />
```
(note: if you have been previously using openfl-bitfive, make sure to remove a line including the
library after OpenFL, or you'll be getting interesting errors since openfl 1.3.0/lime-tools 1.3.1)

Run the project. If everything was done right, first noticeable difference will be in stage background covering whole browser tab, as well as HTML elements forming a more common DOM tree and having "node" properties indicating their names in code (if ran in Debug mode).

For audio to work equally in all browsers, project should also include OGG versions of audio files (as opposed to MP3). This can be done with code like this:

```xml
<assets path="assets/snd" rename="snd" include="*.ogg" if="html5" />
```

## Notable incompatibilities
*	BitmapData and Graphics objects can only be bound to a single DisplayObject at time.
*	TextField-related classes are fairly draft. These will make attempts to display provided text anyway (for sake of compatibility), but they do not support embed fonts and most of needed properties.
*	HTML5 touch events are currently not being mapped to Flash touch events. Mouse events are mapped and dispatched fine though (including mapping of touch events into mouse events).
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
