﻿/*
LabView.as
2019-09-19
*/

package astroUNL.naap.views {
	
	import astroUNL.naap.data.Lab;
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class LabView extends SWCLabView {
		
		public static const LAUNCH_ITEM_SELECTED:String = "launchItemSelected";
		
		protected var _lab:Lab = null;
		
		protected var _links:Dictionary;
		
		protected var _headingFormat:TextFormat;
		protected var _itemFormat:TextFormat;
		
		protected var _panelWidth:Number;
		protected var _panelHeight:Number;
		protected var _navButtonSpacing:Number = 20;
		protected var _panesTopMargin:Number = 0;
		protected var _panesSideMargin:Number = 15;
		protected var _panesBottomMargin:Number = 45;
		protected var _panesWidth:Number;
		protected var _panesHeight:Number;
		protected var _columnSpacing:Number = 20;
		protected var _numColumns:int = 2;
		protected var _easeTime:Number = 250;
				
		protected var _headingTopMargin:Number = 10;
		protected var _headingBottomMargin:Number = 10;
		protected var _headingMinLeftOver:Number = 25;
		protected var _itemLeftMargin:Number = 7;
		protected var _itemBottomMargin:Number = 9;
		protected var _itemMinLeftOver:Number = -9;
		
		protected var _panes:ScrollableLayoutPanes;
		
		
		protected var _backgroundHeading:TextField;
		protected var _simulatorsHeading:TextField;
		
		
		public function LabView(w:Number, h:Number) {
			
			_panelWidth = w;
			_panelHeight = h;
			
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			
			_links = new Dictionary();
			
			_panesTopMargin = _title.height + _title.y + 20;
						
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: _panesSideMargin, rightMargin: _panesSideMargin, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			addChild(_panes);
			
			_headingFormat = new TextFormat("Verdana", 15, 0x0, true);
			_itemFormat = new TextFormat("Verdana", 14, 0x0);
		
			_backgroundHeading = createHeading("");//Background Interatives");
			_simulatorsHeading = createHeading("");//Simulators");
		}
		
		public function setDimensions(w:Number, h:Number):void {
			if (w==_panelWidth && h==_panelHeight) return;
			_panelWidth = w;
			_panelHeight = h;
			_dimensionsUpdateNeeded = true;
			if (visible) redraw();
		}
		
		override public function set visible(visibleNow:Boolean):void {
			var previouslyVisible:Boolean = super.visible;
			super.visible = visibleNow;			
			if (!previouslyVisible && visibleNow) redraw();
		}
		
		protected var _dimensionsUpdateNeeded:Boolean = true;
		
		protected function doDimensionsUpdate():void {			
		
			// adjust the panes
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			_panes.setDimensions(_panesWidth, _panesHeight);
			_panes.reset(); // needed here to recalculate columnWidth -- gets called again in redraw
			
			// adjust the layout
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			
			// adjust the text widths
			_backgroundHeading.width = _panes.columnWidth;
			_simulatorsHeading.width = _panes.columnWidth;
			for each (var link:ClickableText in _links) link.setWidth(_panes.columnWidth-_itemLeftMargin);
		
			_dimensionsUpdateNeeded = false;
		}
				
		protected function redraw():void {
			
			if (_lab == null) {
				return;
			}
			
			_title.text = _lab.name;
			
			if (_dimensionsUpdateNeeded) {
				doDimensionsUpdate();
			}
			
			var oldPaneNum:int = _panes.paneNum;
			
			_panes.reset();
			
			var headingParams:Object = {topMargin: _headingTopMargin, bottomMargin: _headingBottomMargin, minLeftOver: _headingMinLeftOver};
			var itemParams:Object = {columnTopMargin: 0, leftMargin: _itemLeftMargin, bottomMargin: _itemBottomMargin, minLeftOver: _itemMinLeftOver};
			
			var i:int;
			var ct:ClickableText;
			var item:ResourceItem;
			
			if (_lab.backgroundSWFs.length > 0) {			
				_panes.addContent(_backgroundHeading, headingParams);
				for (i=0; i<_lab.backgroundSWFs.length; i++) {
					item = _lab.backgroundSWFs[i];
					if (_links[item] == undefined) {
						ct = new ClickableText(item.name, item, _itemFormat, _panes.columnWidth-_itemLeftMargin);		
						ct.addEventListener(ClickableText.ON_CLICK, onItemClicked, false, 0, true);
						_links[item] = ct;
					}
					_panes.addContent(_links[item], itemParams);
				}
			}
						
			_panes.addContent(_simulatorsHeading, headingParams);
			for (i=0; i<_lab.mainSWFs.length; i++) {
				item = _lab.mainSWFs[i];
				if (_links[item] == undefined) {
					ct = new ClickableText(item.name, item, _itemFormat, _panes.columnWidth-_itemLeftMargin);		
					ct.addEventListener(ClickableText.ON_CLICK, onItemClicked, false, 0, true);
					_links[item] = ct;
				}
				_panes.addContent(_links[item], itemParams);
			}
		}
		
		
		
		public function get lab():Lab {
			return _lab;
		}
		
		public function set lab(arg:Lab):void {
			_lab = arg;
			redraw();
		}
		
		
		protected function createHeading(text:String):TextField {
			var t:TextField = new TextField();
			t.text = text;
			t.autoSize = "left";
			t.height = 0;
			t.width = _panes.columnWidth;
			t.multiline = true;
			t.wordWrap = true;			
			t.selectable = false;
			t.setTextFormat(_headingFormat);
			t.embedFonts = true;
			return t;
		}				
		
		protected function onItemClicked(evt:Event):void {
			trace("onItemClicked");
			var item:ResourceItem = evt.target.data;
			ResourceWindowsManager.open(item);
		}
		
	}
	
}
