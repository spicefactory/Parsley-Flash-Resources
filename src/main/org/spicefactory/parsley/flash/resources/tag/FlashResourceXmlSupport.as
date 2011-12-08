/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.parsley.flash.resources.tag {
import org.spicefactory.parsley.xml.mapper.XmlConfigurationNamespaceRegistry;

/**
 * Provides a static method to initalize the Flash Localization XML tag extension.
 * 
 * @author Jens Halm
 */
public class FlashResourceXmlSupport {
	
	
	/**
	 * The XML Namespace of the Flash Localization tag extension.
	 */
	public static const FLASH_RESOURCE_NAMESPACE:String = "http://www.spicefactory.org/parsley/flash/resources";
	
	private static var initialized:Boolean;
	
	
	/**
	 * Initializes the Flash Localization XML tag extension.
	 * Must be invoked before the <code>XmlContextBuilder</code> is used for the first time.
	 */
	public static function initialize () : void {
		if (initialized) return;
		XmlConfigurationNamespaceRegistry
			.getNamespace(FLASH_RESOURCE_NAMESPACE)
			.mappedClasses(ResourceBundleTag, ResourceManagerTag, LocaleTag);
		initialized = true;
	}
	
}
}
