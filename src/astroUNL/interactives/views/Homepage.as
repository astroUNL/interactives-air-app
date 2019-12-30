
package astroUNL.interactives.views {
	
	import astroUNL.interactives.data.SectionsList;
	import astroUNL.interactives.events.StateChangeRequestEvent;
	
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class Homepage extends SWCHomepage {
		
		protected var _sectionsList:SectionsList = null;
		
		// sectionLinks contains the references to the ClickableText
		// instances associated with each section
		protected var _sectionLinks:Dictionary;
				
		protected var _content:Sprite;
		
		protected var _headingFormat:TextFormat;
		protected var _itemFormat:TextFormat;
		
		// Note: there's no Nav Button since there will always be enough space for all sections.
		
		protected var _panelWidth:Number;
		protected var _panelHeight:Number;
		protected var _navButtonSpacing:Number = 40;
		protected var _panesTopMargin:Number = 40;
		protected var _panesSideMargin:Number = 15;
		protected var _panesBottomMargin:Number = 45;
		protected var _panesWidth:Number;
		protected var _panesHeight:Number;
		protected var _columnSpacing:Number = 20;
		protected var _numColumns:int = 2;
		protected var _easeTime:Number = 250;
				
		protected var _headingTopMargin:Number = 10;
		protected var _headingBottomMargin:Number = 4;
		protected var _headingMinLeftOver:Number = 25;
		protected var _itemLeftMargin:Number = 7;
		protected var _itemBottomMargin:Number = 9;
		protected var _itemMinLeftOver:Number = -9;
		
		protected var _panes:ScrollableLayoutPanes;
		
		
		protected var _standardHeading:TextField;
		
		public function Homepage(w:Number, h:Number) {
			
			_panelWidth = w;
			_panelHeight = h;
			
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			
			_sectionLinks = new Dictionary();
			
			trace(_panesWidth+', '+_panesHeight);
			
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: _panesSideMargin, rightMargin: _panesSideMargin, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			addChild(_panes);
			
			_headingFormat = new TextFormat("Verdana", 15, 0x0, true);
			_itemFormat = new TextFormat("Verdana", 14, 0x0);
		
			_standardHeading = createHeading("");
			
		/*
			_leftButton = new ResourcePanelNavButton();
			_leftButton.x = _navButtonSpacing;
			_leftButton.y = _panelHeight/2;
			_leftButton.scaleX = -1;
			_leftButton.addEventListener(MouseEvent.CLICK, onLeftButtonClicked);
			_leftButton.visible = false;
			addChild(_leftButton);
			
			_rightButton = new ResourcePanelNavButton();
			_rightButton.x = _panelWidth - _navButtonSpacing;
			_rightButton.y = _panelHeight/2;
			_rightButton.addEventListener(MouseEvent.CLICK, onRightButtonClicked);
			_rightButton.visible = false;
			addChild(_rightButton);				
			*/
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
			
			var rightMargin:Number = 40;
		
			_descriptionField.x = _panelWidth - _descriptionField.width - rightMargin;
			_creditsField.x = _panelWidth - _creditsField.width - rightMargin;
			_linkField.x = _panelWidth - _linkField.width - rightMargin;
			_versionField.x = _panelWidth - _versionField.width - rightMargin;
			
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
			_standardHeading.width = _panes.columnWidth;
			for each (var link:ClickableText in _sectionLinks) link.setWidth(_panes.columnWidth-_itemLeftMargin);
		
			_dimensionsUpdateNeeded = false;
		}
		
		protected function redraw():void {
			
			if (_sectionsList == null) {
				return;
			}
			
			if (_dimensionsUpdateNeeded) {
				doDimensionsUpdate();
			}
			
			var oldPaneNum:int = _panes.paneNum;
			
			_panes.reset();
			
			var headingParams:Object = {topMargin: _headingTopMargin, bottomMargin: _headingBottomMargin, minLeftOver: _headingMinLeftOver};
			var itemParams:Object = {columnTopMargin: 45, leftMargin: _itemLeftMargin, bottomMargin: _itemBottomMargin, minLeftOver: _itemMinLeftOver};

			_panes.addContent(_standardHeading, headingParams);
			
			var i:int;
			var ct:ClickableText;
						
			for (i=0; i<_sectionsList.sections.length; i++) {
				if (_sectionLinks[_sectionsList.sections[i]] == undefined) {
					var sectionName:String = (i+1) + ". " + _sectionsList.sections[i].name;
					ct = new ClickableText(sectionName, _sectionsList.sections[i], _itemFormat, _panes.columnWidth-_itemLeftMargin);		
					ct.addEventListener(ClickableText.ON_CLICK, onSectionClicked, false, 0, true);
					_sectionLinks[_sectionsList.sections[i]] = ct;
				}
				_panes.addContent(_sectionLinks[_sectionsList.sections[i]], itemParams);
			}
			
		}
		
		
		
		public function get sectionsList():SectionsList {
			return _sectionsList;
		}
		
		public function set sectionsList(list:SectionsList):void {
			_sectionsList = list;
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
		
		protected function onSectionClicked(evt:Event):void {
			dispatchEvent(new StateChangeRequestEvent(evt.target.data, true));
		}
		
	}
	
}
