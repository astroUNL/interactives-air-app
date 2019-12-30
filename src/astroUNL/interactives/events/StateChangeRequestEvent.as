
package astroUNL.interactives.events {
	
	import flash.events.Event;
	
	import astroUNL.interactives.data.Section;
	
	
	public class StateChangeRequestEvent extends Event {
		
		public static const STATE_CHANGE_REQUESTED:String = "stateChangeRequested";
		
		public var section:Section;
		
		public function StateChangeRequestEvent(section:Section=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, bubbles, cancelable);
			this.section = section;
		}
		
		override public function clone():Event {
			return new StateChangeRequestEvent(section, bubbles, cancelable);
		}
		
		override public function toString():String {
			return formatToString("StateChangeRequestEvent", "section", "bubbles", "cancelable", "eventPhase"); 
		}
			
	}	
}

