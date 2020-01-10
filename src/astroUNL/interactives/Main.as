
package astroUNL.interactives {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourceWindowsManager;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import astroUNL.interactives.data.SectionsList;
	import astroUNL.interactives.data.Section;
	
	import astroUNL.interactives.views.Homepage;
	import astroUNL.interactives.views.HeaderBar;
	import astroUNL.interactives.views.SectionView;
	
	import astroUNL.interactives.events.StateChangeRequestEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;


	public class Main extends Sprite {
		
		protected var _sectionsList:SectionsList;
		
		protected var _header:HeaderBar;
		protected var _homepage:Homepage;
		protected var _sectionView:SectionView;
		
		public function Main() {
			
			trace("Main constructor");
			trace(" stage.stageWidth: "+stage.stageWidth);
			trace(" stage.stageHeight: "+stage.stageHeight);
			trace(" stage.width: "+stage.width);
			trace(" stage.height: "+stage.height);
			
			stage.color = 0xffffff;
			stage.nativeWindow.addEventListener(Event.CLOSING, onMainWindowClosing);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		
		protected const _minWidth:Number = 845;
		protected const _minHeight:Number = 695;
		
		//protected const _homepageMargins:Object = {left: 20, right: 5, top: 10, bottom: 10};
		protected const _sectionViewMargins:Object = {left: 20, right: 5, top: 15, bottom: 10};
		
		protected function onAddedToStage(evt:Event):void {
			trace("onAddedToStage");
			
			// updateDimensions gets called at the end the loading sequence (before the views are first made
			// visible), but some components need dimensions at initialization and so we might as well give
			// them the correct information now and save a few milliseconds
			var windowWidth:Number = Math.max(stage.stageWidth, _minWidth);
			var windowHeight:Number = Math.max(stage.stageHeight, _minHeight);
			stage.stageWidth = windowWidth;
			stage.stageHeight = windowHeight;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResized);
			
			Downloader.init("files/");
			
			_sectionsList = new SectionsList("interactives.xml");
			_sectionsList.addEventListener(SectionsList.LOAD_FINISHED, onSectionsListLoadFinished);
			
			_homepage = new Homepage(stage.stageWidth, stage.stageHeight);
			_homepage.addEventListener(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, onStateChangeRequested);
			_homepage.visible = false;
			addChild(_homepage);
			
			_sectionView = new SectionView(stage.stageWidth, stage.stageHeight);
			_sectionView.visible = false;
			addChild(_sectionView);
			
			_header = new HeaderBar(windowWidth);
			_header.addEventListener(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, onStateChangeRequested);
			_header.x = 0;
			_header.y = 0;
			addChild(_header);
						
			updateDimensions();
			
			setView(null);
		}
		
		protected function onStageResized(evt:Event):void {
			trace("onStageResized");
			updateDimensions();
		}
		
		protected function onLabSelected(evt:MenuEvent):void {
			setView(evt.data);
		}
		
		protected function onStateChangeRequested(evt:StateChangeRequestEvent):void {
			setView(evt.section);			
		}
		
		protected var _selectedSection:Section = null;
		
		protected function setView(section:Section=null):void {
			trace("setView");
			
			
			_homepage.visible = false;
			_sectionView.visible = false;
						
			_selectedSection = section;
			
			_header.setState(_selectedSection);
			
			if (_selectedSection == null) {
				_homepage.visible = true;
			} else {
				_sectionView.section = _selectedSection;
				_sectionView.visible = true;
			}
			
		}
		
		
		
		protected function updateDimensions():void {
			
			trace("Main Window, updateDimensions");
			trace(" stage.stageWidth (before): "+stage.stageWidth);
			trace(" stage.stageHeight (before): "+stage.stageHeight);
			
			var windowWidth:Number = Math.max(stage.stageWidth, _minWidth);
			var windowHeight:Number = Math.max(stage.stageHeight, _minHeight);
			stage.stageWidth = windowWidth;
			stage.stageHeight = windowHeight;
			
			_header.width = windowWidth;
			
			var freeVerticalSpace:Number = windowHeight - Math.ceil(_header.height);
			
			_homepage.x = 0;
			_homepage.y = _header.height;
			_homepage.setDimensions(windowWidth, freeVerticalSpace);
			
			_sectionView.x = _sectionViewMargins.left;
			_sectionView.y = _header.height + _sectionViewMargins.top;	
			_sectionView.setDimensions(windowWidth-_sectionViewMargins.left-_sectionViewMargins.right, freeVerticalSpace-_sectionViewMargins.top-_sectionViewMargins.bottom);
		}
		
		
		protected function onSectionsListLoadFinished(evt:Event):void {
			
			_homepage.sectionsList = _sectionsList;
			
			/*
			trace("onLabsListLoadFinished");
			for each (var section:Section in _sectionsList.sections) {
				trace(section.name);
				for each (var item:ResourceItem in section.flashBased) {
					trace(" "+item.name);
				}
				for each (var obj:Object in section.paperBased) {
					trace(" "+obj.name);
				}
			}
			*/
		}
		
		protected function onMainWindowClosing(evt:Event):void {
			trace("Main window is closing, resource windows should follow.");
			ResourceWindowsManager.closeAll();
		}
	}
}
