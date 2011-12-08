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
import flash.events.IEventDispatcher;
	
/**
 * Dispatched when switching the <code>Locale</code> starts.
 * 
 * @eventType org.spicefactory.lib.task.events.TaskEvent.START
 */
[Event(name="start", type="org.spicefactory.parsley.flash.resources.events.LocaleSwitchEvent")]

/**
 * Dispatched when switching the <code>Locale</code> is completed.
 * 
 * @eventType org.spicefactory.lib.task.events.TaskEvent.COMPLETE
 */
[Event(name="complete", type="org.spicefactory.parsley.flash.resources.events.LocaleSwitchEvent")]

/**
 * The central manager for all internationalization features.
 * Usually there is always at most one active <code>ResourceManager</code> instance in 
 * an application.
 * 
 * @author Jens Halm
 */
public interface ResourceManager extends IEventDispatcher {
	
	/**
	 * Indicates whether the current <code>Locale</code> will be stored
	 * in a local shared object so that it can be restored the next time the application
	 * is started again.
	 */
	function get persistent () : Boolean ;
	
	function set persistent (persistent:Boolean) : void ;

	/**
	 * Indicates whether bundles managed by this instance should be cached.
	 * If this property is set to false all bundles will be reloaded each time
	 * the current <code>Locale</code> is switched.
	 */
	function get cacheable () : Boolean;
	
	function set cacheable (cacheable:Boolean) : void;
	
	/**
	 * The currently active <code>Locale</code>.
	 */
	function get currentLocale () : Locale ;
	
	function set currentLocale (loc:Locale) : void ;

	/**
	 * Adds a <code>Locale</code> that the set of Locales supported by this <code>LocaleManager</code>.
	 * 
	 * @param loc the Locale to add to the set of supported Locales
	 */
	function addSupportedLocale (loc:Locale) : void ;	

	/**
	 * Checks whether the specified <code>Locale</code> is supported by this <code>LocaleManager</code>.
	 * 
	 * @param loc the Locale to check
	 * @return true if the specified <code>Locale</code> is supported by this <code>LocaleManager</code>
	 */
	function isSupportedLocale (loc:Locale) : Boolean ;
		
	/**
	 * All <code>Locale</code> instances supported by this <code>LocaleManager</code>.
	 */
	function get supportedLocales () : Array ;
		
	/**
	 * The default <code>Locale</code> for this <code>LocaleManager</code>.
	 * This <code>Locale</code> will be used initially if no value for <code>currentLocale</code>
	 * was explicitly specified and no persistent <code>Locale</code> could be retrieved either.
	 */
	function get defaultLocale () : Locale ;

	function set defaultLocale (loc:Locale) : void ;
	
	/**
	 * Returns the message bundle for the specified id.
	 * If the id parameter is omitted the default bundle will be returned.
	 * 
	 * @param bundleId the id of the message bundle
	 * @return the message bundle with the specified id or null if no such bundle exists
	 */
	function getBundle (bundleId:String = null) : ResourceBundle;
	
	/**
	 * @copy org.spicefactory.parsley.context.ApplicationContext#getMessage()
	 */
	function getMessage (messageKey:String, bundleId:String = null, params:Array = null) : String;
		
	
}
	
}