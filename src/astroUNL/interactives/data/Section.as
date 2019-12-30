

package astroUNL.interactives.data {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.utils.logger.Logger;
	
	public class Section {
		
		protected var _name:String = "";
		
		// The flashBased array consists ResourceItem instances.
		// The paperBased array consists of objects with these properties:
		//	name
		//	file - "files/" is added automatically
		public var flashBased:Array = [];
		public var paperBased:Array = [];
		
		
		public function Section(sectionXML:XML) {
			var itemXML:XML;
			var item:ResourceItem;
			
			try {
				_name = sectionXML.attribute("name").toString();
								
				for each (itemXML in sectionXML["online"].elements()) {
					
					var newXML:XML = new XML("<ANIMATION></ANIMATION>");
					newXML.@id = "NA";
					newXML.Name = itemXML.attribute("name").toString();
					newXML.Description = "NA";
					newXML.File = itemXML.filename.toString();
					newXML.Width = itemXML.width.toString();
					newXML.Height = itemXML.height.toString();
					newXML.Keywords = "NA";
					
					trace(itemXML.attribute("name").toString());
					
					item = new ResourceItem(ResourceItem.ANIMATION, newXML);
					flashBased.push(item);
				}
				
				for each (itemXML in sectionXML["paper"].elements()) {
					paperBased.push({
										name: itemXML.attribute("name").toString(),
										file: "files/" + itemXML.filename.toString()
									});
				}
				
			} catch (err:Error) {
				Logger.report("Failed to initialize Section object from XML.");
			}
		}
		
		public function get name():String {
			return _name;
		}
	}
	
}

