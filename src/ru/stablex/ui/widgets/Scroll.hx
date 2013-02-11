package ru.stablex.ui.widgets;

import nme.display.DisplayObject;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.Lib;
import ru.stablex.ui.events.WidgetEvent;



/**
* Scroll container.
* First child of this widget will be used as container for scrolled content.
*/
class Scroll extends Widget{

    /**
    * :TODO:
    * On cpp application segfaults if scrolling is performed while resizing scroll widget
    */

    //allow vertical scrolling
    public var vScroll : Bool = true;
    //allow horizontal scrolling
    public var hScroll : Bool = true;
    //allow scrolling by mouse wheel
    public var wheelScroll : Bool = true;
    /**
    * Modifier to scroll horizontally instead of vertically, when using mouse wheel
    * Possible values: shift, alt, ctrl
    * Note for flash: some browsers reserve shift+wheel, alt+wheel, ctrl+wheel combinations
    */
    public var hScrollKey : String = 'alt';
    //allow scrolling by dragging
    public var dragScroll : Bool = true;
    /**
    * Container for content. Content is scrolled by moving this container.
    * This is always the first child of Scroll widget
    */
    public var box (_getBox,never) : Widget;

    //scroll position along x axes
    public var scrollX (_getScrollX,_setScrollX) : Float;
    //scroll position along y axes
    public var scrollY (_getScrollY,_setScrollY) : Float;
    //vertical scroll bar
    public var vBar (default,_setVBar) : Slider;
    //horizontal scroll bar
    public var hBar (default,_setHBar) : Slider;


    /**
    * Constructor
    *  `.overflow` = false by default
    */
    public function new () : Void {
        super();
        this.overflow = false;

        this.vBar = UIBuilder.create(Slider, {
            vertical : true,
            right    : 0,
            top      : 0,
            heightPt : 100,
            w        : 10,
            slider   : {widthPt : 100}
        });
        this.hBar = UIBuilder.create(Slider, {
            vertical : false,
            bottom   : 0,
            left     : 0,
            widthPt  : 100,
            h        : 10,
            slider   : {heightPt : 100}
        });
    }//function new()


    /**
    * Getter for `.box`
    *
    */
    private function _getBox () : Widget {
        if( this.numChildren == 0 ){
            Err.trigger('Scroll widget must have at least one child.');
            return null;
        }else{

            var child : DisplayObject = this.getChildAt(0);
            if( !Std.is(child, Widget) ){
                Err.trigger('Instance of Widget must be the first child for Scroll widget');
            }
            return cast(child, Widget);
        }
    }//function _getBox()


    /**
    * Setter for .scrollX
    *
    */
    private function _setScrollX (x:Float) : Float {
        if( x > 0 ) x = 0;
        if( x + this.box._width < this._width ) x = this._width - this.box._width;

        this.box.left = x;

        if( this.hBar != null && Math.abs(this.hBar.value + x) >= 1 ) this.hBar.value = -x;

        return x;
    }//function _setScrollX()


    /**
    * Getter for .scrollX
    *
    */
    private function _getScrollX () : Float {
        return this.box.left;
    }//function _getScrollX()


    /**
    * Setter for .scrollY
    *
    */
    private function _setScrollY (y:Float) : Float {
        if( y > 0 ) y = 0;
        if( y + this.box._height < this._height ) y = this._height - this.box._height;

        this.box.top = y;

        if( this.vBar != null && Math.abs(this.vBar.value - y) >= 1 ) this.vBar.value = y;

        return y;
    }//function _setScrollY()


    /**
    * Getter for .scrollY
    *
    */
    private function _getScrollY () : Float {
        return this.box.top;
    }//function _getScrollY()


    /**
    * Setter for '.vBar'
    *
    */
    private function _setVBar(bar:Slider) : Slider {
        if( bar == null && this.vBar != null ){
            this.vBar.free();
        }
        return this.vBar = bar;
    }//function _setVBar()


    /**
    * Setter for '.hBar'
    *
    */
    private function _setHBar(bar:Slider) : Slider {
        if( bar == null && this.hBar != null ){
            this.hBar.free();
        }
        return this.hBar = bar;
    }//function _setHBar()


    /**
    * Refresh container too
    *
    */
    override public function refresh () : Void {
        this.box.refresh();
        super.refresh();

        //vertical bar
        if( this.vBar != null ){
            this.addChildAt(this.vBar, 1);
            this.vBar.min = (this.h - this.box.h < 0 ? this.h - this.box.h : 0);
            this.vBar.max = 0;
            var k : Float = this.vBar.h / this.box.h;
            if( k > 1 ) k = 1;
            this.vBar.slider.h = this.h * k;
            this.vBar.refresh();
            // this.vBar.addUniqueListener(WidgetEvent.CHANGE, this._onVBarChange);
        }
        //verticalhorizontal bar
        if( this.hBar != null ){
            this.addChildAt(this.hBar, 1);
            this.hBar.max = -(this.w - this.box.w < 0 ? this.w - this.box.w : 0);
            this.hBar.min = 0;
            var k : Float = this.hBar.w / this.box.w;
            if( k > 1 ) k = 1;
            this.hBar.slider.w = this.hBar.w * k;
            this.hBar.refresh();
            // this.hBar.addUniqueListener(WidgetEvent.CHANGE, this._onHBarChange);
        }

        //mouse wheel scrolling
        if( this.wheelScroll ){
            this.addUniqueListener(MouseEvent.MOUSE_WHEEL, this._wheelScroll);
        }else{
            this.removeEventListener(MouseEvent.MOUSE_WHEEL, this._wheelScroll);
        }

        //dragging
        if( this.dragScroll ){
            this.addUniqueListener(MouseEvent.MOUSE_DOWN, this._dragScroll);
        }else{
            this.removeEventListener(MouseEvent.MOUSE_DOWN, this._dragScroll);
        }
    }//function refresh()


    /**
    * On `.vBar` value change
    *
    */
    private function _onVBarChange (e:WidgetEvent) : Void {
        if( Math.abs(this.scrollY - this.vBar.value) >= 1 ){
            this.tweenStop();
            this.scrollY = this.vBar.value;
        }
    }//function _onVBarChange()


    /**
    * On `.hBar` value change
    *
    */
    private function _onHBarChange (e:WidgetEvent) : Void {
        if( Math.abs(this.scrollX + this.hBar.value) >= 1 ){
            this.tweenStop();
            this.scrollX = -this.hBar.value;
        }
    }//function _onHBarChange()


    /**
    * Start scroll by drag
    *
    */
    private function _dragScroll_old (e:MouseEvent) : Void {
        var dx       : Float = this.mouseX - this.scrollX;
        var dy       : Float = this.mouseY - this.scrollY;
        var lastX    : Float = this.mouseX;
        var lastY    : Float = this.mouseY;
        var lastDx   : Float = 0;
        var lastDy   : Float = 0;
        var startX   : Float = this.mouseX;
        var startY   : Float = this.mouseY;
        var scrolled : Bool = false;
        //allowed scroll directions
        var vScroll : Bool = (this.vScroll && this.box.h > this.h);
        var hScroll : Bool = (this.hScroll && this.box.w > this.w);

        //stop previous scrolling
        this.tweenStop(null, false, true);

        //follow mouse pointer
        var fn = function(e:Event) : Void {
            if( hScroll ) this.scrollX = this.mouseX - dx;
            if( vScroll ) this.scrollY = this.mouseY - dy;

            //if user realy wants to scroll instead of interacting with content,
            //disable processing mouse events by children
            if(
                (hScroll && !scrolled && Math.abs(this.mouseX - startX) >= 5)
                || (vScroll && !scrolled && Math.abs(this.mouseY - startY) >= 5)
            ){
                scrolled = true;
                this.box.mouseChildren = false;
                this.dispatchEvent(new WidgetEvent(WidgetEvent.SCROLL_START));
            }

            lastDx = this.mouseX - lastX;
            lastDy = this.mouseY - lastY;

            lastX = this.mouseX;
            lastY = this.mouseY;
        }

        //follow pointer
        this.addUniqueListener(Event.ENTER_FRAME, fn);

        //stop following
        var fnStop : MouseEvent->Void = null;
        fnStop = function(e:MouseEvent) : Void {
            this.removeEventListener(Event.ENTER_FRAME, fn);
            Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, fnStop);

            var finish : Void->Void = function() : Void {
                if( scrolled ){
                    this.dispatchEvent(new WidgetEvent(WidgetEvent.SCROLL_STOP));
                }
            };

            //go-go!
            if( vScroll && hScroll ){
                this.tween(2, {scrollX:this.scrollX + lastDx * 20, scrollY:this.scrollY + lastDy * 20}, 'Expo.easeOut').onComplete(finish);
            }else if( vScroll ){
                this.tween(2, {scrollY:this.scrollY + lastDy * 20}, 'Expo.easeOut').onComplete(finish);
            }else{
                this.tween(2, {scrollX:this.scrollX + lastDx * 20}, 'Expo.easeOut').onComplete(finish);
            }

            if(scrolled) this.box.mouseChildren = true;
        }

        //stop scrolling
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, fnStop);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, fnStop);
    }//function _dragScroll_old()


    /**
    * Scroll by wheel
    *
    */
    private function _wheelScroll (e:MouseEvent) : Void {
        //scroll horizontally
        if(
            this.hScroll
            && (
                (e.altKey && this.hScrollKey == 'alt')
                || (e.shiftKey && this.hScrollKey == 'shift')
                || (e.ctrlKey && this.hScrollKey == 'ctrl')
            )
        ){
            this.tweenStop();
            this.scrollX += e.delta * 10;
        //scroll vertically
        }else if( this.vScroll ){
            this.tweenStop();
            this.scrollY += e.delta * 10;
        }
    }//function _wheelScroll()


    private var _dx       : Float = 0;
    private var _dy       : Float = 0;
    private var _velX     : Array<Float>;
    private var _velY     : Array<Float>;
    private var _prevVelX : Float = 0;
    private var _prevVelY : Float = 0;
    private var _prevTime : Int = 0;
    private var _lastX    : Float = 0;
    private var _lastY    : Float = 0;
    private var _stopped  : Bool = false;
    private var _finished : Bool = false;


    /**
    * Start drag scroll
    *
    */
    private function _dragScroll(e:MouseEvent) : Void {
        this._dx = this.mouseX - this.box.left;
        this._dy = this.mouseY - this.box.top;

        this._prevTime = Lib.getTimer();

        this._velX = [];
        this._velY = [];

        this._lastX = this.mouseX;
        this._lastY = this.mouseY;

        this._prevVelX = this._prevVelY = 0;

        this._finished = this._stopped = false;

        // this.addUniqueListener(Event.ENTER_FRAME, this._followDrag);
        this.addUniqueListener(MouseEvent.MOUSE_MOVE, this._updateDrag);
        this.addUniqueListener(TouchEvent.TOUCH_MOVE, this._updateDrag);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, this._stopDrag);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, this._stopDrag);
    }//function _dragScroll()


    private static inline var _ACCEL = 0.0001;

    /**
    * Stop dragging
    *
    */
    private function _stopDrag(e:Event) : Void {
        this._stopped = true;

        this._updateDrag(e);

        //count starting inertial velocities {
            var weight      : Float = 2;
            var totalWeight : Float = 0;
            this._prevVelX = 0;
            while( this._velX.length > 0 ){
                this._prevVelX += this._velX.shift() * weight;
                totalWeight += weight;
                weight *= 0.83;
            }
            this._prevVelX /= totalWeight;
            this._accelX = (this._prevVelX > 0 ? -_ACCEL : _ACCEL);

            var weight      : Float = 50;
            var totalWeight : Float = 0;
            this._prevVelY = 0;
            while( this._velY.length > 0 ){
                this._prevVelY += this._velY.shift() * weight;
                totalWeight += weight;
                weight *= 0.83;
            }
            this._prevVelY /= totalWeight;
            this._accelY = (this._prevVelY > 0 ? -_ACCEL : _ACCEL);
        //}

        this.addUniqueListener(Event.ENTER_FRAME, this._followDrag);
        this.removeEventListener(MouseEvent.MOUSE_MOVE, this._updateDrag);
        this.removeEventListener(TouchEvent.TOUCH_MOVE, this._updateDrag);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, this._stopDrag);
    }//function _stopDrag()



    /**
    * Update scrolling vars
    *
    */
    private function _updateDrag(e:Event) : Void {
        var tm : Int = Lib.getTimer();
        if( tm - this._prevTime == 0 ) return;

        //add current velocity
        this._velX.unshift(this._prevVelX);
        this._velY.unshift(this._prevVelY);

        //keep velocity stack length <= 10
        if( this._velX.length > 10 ) this._velX.pop();
        if( this._velY.length > 10 ) this._velY.pop();

        //calc current velocity
        this._prevVelX = (this.mouseX - this._lastX) / (tm - this._prevTime);
        this._prevVelY = (this.mouseY - this._lastY) / (tm - this._prevTime);

        //save last position
        this._lastX = this.mouseX;
        this._lastY = this.mouseY;

        //move scrolled content
        this.scrollX = this._lastX - this._dx;
        this.scrollY = this._lastY - this._dy;
    }//function _updateDrag()


    private var _accelX : Float = 0;
    private var _accelY : Float = 0;


    /**
    * Follow dragging
    *
    */
    private function _followDrag(e:Event) : Void {
        trace(this._prevVelY);

        var tm : Int = Lib.getTimer();

        this.scrollY += this._prevVelY * (tm - this._prevTime);
        // this._prevVelY += this._accelY * (tm - this._prevTime);
        this._prevVelY *= 0.8;
        this._prevTime = tm;

        trace(this._prevVelY);

        if( Math.abs(this._prevVelY) < 1e-3 ){
            this.removeEventListener(Event.ENTER_FRAME, this._followDrag);
        }
    }//function _followDrag()


}//class Scroll