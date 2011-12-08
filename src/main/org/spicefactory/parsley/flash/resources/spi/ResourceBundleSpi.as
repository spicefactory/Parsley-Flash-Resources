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
 
package org.spicefactory.parsley.flash.resources.spi {
	import org.spicefactory.parsley.flash.resources.spi.BundleLoaderFactory;
import org.spicefactory.lib.task.TaskGroup;
import org.spicefactory.parsley.flash.resources.Locale;
import org.spicefactory.parsley.flash.resources.ResourceBundle;	

/**	
 * Service provider interface that extends the public <code>MessageBundle</code> interface.
 * 
 * @author Jens Halm
 */
public interface ResourceBundleSpi extends ResourceBundle {

	/**
	 * Called once after this message bundle was instantiated.
	 * 
	 * @param id the id of the message bundle
	 * @param basename the basename for files containing resources of this bundle
	 * @param localized whether this bundle contains localized messages
	 * @param ignoreCountry whether the country/region code should be ignored
	 */
	function init (id:String, basename:String, localized:Boolean, ignoreCountry:Boolean) : void;
	
	/**
	 * The <code>BundleLoaderFactory</code> to use to create loader Tasks.
	 */
	function get bundleLoaderFactory () : BundleLoaderFactory;
	
	function set bundleLoaderFactory (factory:BundleLoaderFactory) : void;
	
	/**
	 * Invoked when the current <code>Locale</code> is switched.
	 * The implementation is expected to add the Tasks required to load the resources for the
	 * new <code>Locale</code> to the specified <code>TaskGroup</code>.
	 * 
	 * @param loc the next active <code>Locale</code>
	 * @param group a TaskGroup to add the Tasks required to load the new resources to
	 */
	function addLoaders (loc:Locale, group:TaskGroup) : void;
	
	/**
	 * Called once after loading of new resources for a new locale has finished.
	 * The implementation is expected to wait for this method call before it switches
	 * to the new resources. Before that method call it should still return messages for
	 * the previous locale even if it has already finished loading the new resources.
	 * This way a synchronized switch of all message bundles is possible.
	 */
	function applyNewMessages () : void;
	
	/**
	 * Called when the <code>ApplicationContext</code> this message bundle belongs to gets
	 * destroyed. Implementations should remove all references to any loaded message resources
	 * when this method is invoked.
	 */	
	function destroy () : void;
		
}

}