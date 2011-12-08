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
	import org.spicefactory.parsley.flash.resources.spi.ResourceBundleSpi;
import org.spicefactory.parsley.flash.resources.Locale;
import org.spicefactory.parsley.flash.resources.ResourceManager;	

/**	
 * Service provider interface that extends the public <code>LocaleManager</code> interface.
 * 
 * @author Jens Halm
 */
public interface ResourceManagerSpi extends ResourceManager {
	
	[Init]
	/**
	 * Initializes the <code>ResourceManager</code>. Should be called once at application startup.
	 * 
	 * @param loc the initial <code>Locale</code> to use.
	 */	
	function initialize (loc:Locale = null) : void ;

	/**
	 * The default <code>MessageBundle</code> for this instance.
	 */
	function get defaultBundle () : ResourceBundleSpi;
	
	function set defaultBundle (bundle:ResourceBundleSpi) : void;
	
	/**
	 * Adds a message bundle to this instance.
	 * 
	 * @param bundle the message bundle to add to this instance
	 */
	function addBundle (bundle:ResourceBundleSpi) : void;
	
	[Destroy]
	/**
	 * Called when the <code>ApplicationContext</code> this message source belongs to gets
	 * destroyed. Implementations should remove all references to any loaded message bundles
	 * when this method is invoked.
	 */
	function destroy () : void;	
	
}
	
}