/*
 * Copyright 2007-2008 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
package org.spicefactory.parsley.flash.resources.events {
	
import flash.events.Event;
import org.spicefactory.parsley.flash.resources.Locale;

/**
 * Event fired when switching the current <code>Locale</code> starts or is completed.
 */
public class LocaleSwitchEvent extends Event {
	
	/**
	 * Constant for the type of event fired when switching the <code>Locale</code> starts.
	 * 
	 * @eventType start
	 */
	public static var START : String = "start"; 

	/**
	 * Constant for the type of event fired when switching the <code>Locale</code> is completed.
	 * 
	 * @eventType complete
	 */
	public static var COMPLETE : String = "complete";

	
	private var _newLocale:Locale;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param type the type of this event.
	 * @param loc the Locale associated with the event 
	 */
	public function LocaleSwitchEvent (type:String, loc:Locale) {
		super(type);
		_newLocale = loc;
	}
	
	/**
	 * The new <code>Locale</code> that now is active.
	 */
	public function get newLocale () : Locale {
		return _newLocale;
	}
	
	
	/**
	 * @private
	 */
	public override function clone () : Event {
		return new LocaleSwitchEvent(type, newLocale);
	}	
	
}

}