
package astroUNL.interactives.views {
	
	import astroUNL.interactives.data.Section;
	
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
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	
	public class SectionView extends SWCSectionView {
				
		protected var _section:Section = null;
		
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
		
		
		protected var _paperHeading:TextField;
		protected var _flashHeading:TextField;
		
		
		public function SectionView(w:Number, h:Number) {
			
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
		
			_paperHeading = createHeading("Paper-based Tasks");
			_flashHeading = createHeading("Interactive Tasks");
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
			
			_title.x = 0.5*(_panelWidth - _title.width);
		
			// adjust the panes
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			_panes.setDimensions(_panesWidth, _panesHeight);
			_panes.reset(); // needed here to recalculate columnWidth -- gets called again in redraw
			
			// adjust the layout
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			
			// adjust the text widths
			_flashHeading.width = _panes.columnWidth;
			_paperHeading.width = _panes.columnWidth;
			for each (var link:ClickableText in _links) link.setWidth(_panes.columnWidth-_itemLeftMargin);
		
			_dimensionsUpdateNeeded = false;
		}
				
		protected function redraw():void {
			
			if (_section == null) {
				return;
			}
			
			_title.text = _section.name;
			
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
			var obj:Object;
			
			if (_section.flashBased.length > 0) {			
				_panes.addContent(_flashHeading, headingParams);
				for (i=0; i<_section.flashBased.length; i++) {
					item = _section.flashBased[i];
					if (_links[item] == undefined) {
						ct = new ClickableText(item.name, item, _itemFormat, _panes.columnWidth-_itemLeftMargin);		
						ct.addEventListener(ClickableText.ON_CLICK, onFlashItemClicked, false, 0, true);
						_links[item] = ct;
					}
					_panes.addContent(_links[item], itemParams);
				}
			}
			
			if (_section.paperBased.length > 0) {
				_panes.addContent(_paperHeading, headingParams);
				for (i=0; i<_section.paperBased.length; i++) {
					obj = _section.paperBased[i];
					if (_links[obj] == undefined) {
						ct = new ClickableText(obj.name, obj, _itemFormat, _panes.columnWidth-_itemLeftMargin);		
						ct.addEventListener(ClickableText.ON_CLICK, onPaperItemClicked, false, 0, true);
						_links[obj] = ct;
					}
					_panes.addContent(_links[obj], itemParams);
				}
			}
		}
		
		
		
		public function get section():Section {
			return _section;
		}
		
		public function set section(arg:Section):void {
			_section = arg;
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
		
		protected function onFlashItemClicked(evt:Event):void {
			trace("onFlashItemClicked");
			var item:ResourceItem = evt.target.data;
			ResourceWindowsManager.open(item);
		}
		
		protected function onPaperItemClicked(evt:Event):void {
			trace("onPaperItemClicked");
			var req:URLRequest = new URLRequest(evt.target.data.file);
			navigateToURL(req, "_blank");
		}
	}
	
}
