OpenFL-bitfive supports a number of flags.
These are to be included in `application.xml` like this:
```xml
<haxedef name="bitfive_logLoading" />
```
Supported flags are as following:
*	`bitfive_trace`: Display trace() output regardless of configuration.
	(by default, no traces will display on Release configuration)
*	`bitfive_setTimeout`: Use `setTimeout` (as opposed to `setInterval`) for
	`Stage.frameRate` timing.
*	`bitfive_logLoading`: Log asset loading process into console.
*	`bitfive_enums`: Switches a fair of classes to use actual enums instead of abstracts.
	(just in case you really need to use Type API)
*	`bitfive_allowContextMenu`: Do not block right-click context menu.
*	`bitfive_mouseTouches`: Dispatch touch events for mouse events (touch screen emulation).
