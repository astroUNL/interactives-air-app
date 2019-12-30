
package astroUNL.interactives.data {
	
	import astroUNL.classaction.browser.download.IDownloadable;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.utils.logger.Logger;
	
	import astroUNL.interactives.data.Section;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	
	public class SectionsList extends EventDispatcher implements IDownloadable {
		
		// loadFinished dispatched when the module has finished loading (not necessarily successfully, check the loaded property)
		public static const LOAD_FINISHED:String = "loadFinished";
		
		// the update event is dispatched when the modules list is changed after loading
		public static const UPDATE:String = "update";
		
		protected var _name:String = "";
		protected var _filename:String = "";
		protected var _fractionLoaded:Number = 0;
		protected var _downloadState:int = Downloader.NOT_QUEUED;
		protected var _listLoaded:Boolean = false;
		protected var _loadFinished:Boolean = false;
		
		public var sections:Array = [];
		
		
		public function SectionsList(filename:String) {
			_filename = filename;
			
			Downloader.get(this);			
		}
		
		
		
		public function get downloadURL():String {
			return _filename;
		}
		
		public function get downloadFormat():String {
			return URLLoaderDataFormat.TEXT;
		}
		
		public function get downloadPriority():int {
			return 2000001;
		}
		
		public function get downloadState():int {
			return _downloadState;
		}
		
		public function get downloadNoCache():Boolean {
			return true;
		}
		
		public function onDownloadProgress(bytesLoaded:uint, bytesTotal:uint):void {
			_fractionLoaded = bytesLoaded/bytesTotal;			
		}
		
		public function onDownloadStateChanged(state:int, data:*=null):void {
			_downloadState = state;
			if (_downloadState==Downloader.DONE_SUCCESS) {
				_fractionLoaded = 1;
				parseData(data);
			}
			else if (_downloadState==Downloader.DONE_FAILURE) {
				_loadFinished = true;
				dispatchEvent(new Event(SectionsList.LOAD_FINISHED));
			}
		}
		
		protected function parseData(data:String):void {
			try {
				trace("XML Download OK");
				var sectionsXML:XML = new XML(data);
				
				sections = [];
				
				for each (var sectionXML:XML in sectionsXML.elements()) {
					var s:Section = new Section(sectionXML);
					sections.push(s);
				}
				
				_loadFinished = true;
				_listLoaded = true;
				dispatchEvent(new Event(SectionsList.LOAD_FINISHED));
				
			} catch (err:Error) {
				Logger.report("Failed to parse interactives XML.");
				_loadFinished = true;
				_listLoaded = true;
				dispatchEvent(new Event(SectionsList.LOAD_FINISHED));
			}
		}

		
		// the listLoaded property will be true once the modules list file is loaded and successfully parsed
		public function get listLoaded():Boolean {
			return _listLoaded;
		}
		
		// the loadFinished property is true when...
		//   - the modules list file could not be loaded or parsed
		//   - all the module files have finished loading, whether successfully or not
		// note that this means the load finished property may be false while the xmlLoaded property is true
		public function get loadFinished():Boolean {
			return _loadFinished;
		}
		
	}
}
