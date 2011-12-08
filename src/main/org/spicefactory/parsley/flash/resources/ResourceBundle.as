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
 
package org.spicefactory.parsley.flash.resources {
	import org.spicefactory.parsley.flash.resources.Locale;
	
/**
 * A single message bundle containing localized messages.
 * 
 * @author Jens Halm
 */
public interface ResourceBundle {
	
	/**
	 * The id of the bundle.
	 */
	function get id () : String;
	
	/**
	 * Indicates whether this bundle caches messages.
	 * If this property is set to false all bundles will be reloaded each time
	 * the current <code>Locale</code> is switched.
	 */
	function get cacheable () : Boolean;

	function set cacheable (cacheable:Boolean) : void;
	
	/**
	 * Adds messages for the specified <code>Locale</code>.
	 * 
	 * @param loc the Locale the specified messages belong to
	 * @param the messages to add to this bundle
	 */
	function addMessages (loc:Locale, messages:Object) : void;
	
	/**
	 * Returns a localized message for the specified key.
	 * 
	 * @param messageKey the key of the message
	 * @param params optional parameters for parameterized messages
	 * @return the localized message for the specified key with all parameters applied
	 */
	function getMessage (messageKey:String, params:Array) : String;	
	
}
	
}