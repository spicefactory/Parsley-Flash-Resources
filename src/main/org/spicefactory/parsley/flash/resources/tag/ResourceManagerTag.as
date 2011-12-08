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
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.flash.resources.Locale;
import org.spicefactory.parsley.flash.resources.adapter.FlashResourceBindingAdapter;
import org.spicefactory.parsley.flash.resources.impl.DefaultResourceManager;
import org.spicefactory.parsley.flash.resources.spi.ResourceManagerSpi;

import flash.utils.getQualifiedClassName;

[XmlMapping(elementName="resource-manager")]
/**
 * Represent the resource-manager XML tag.
 * 
 * @author Jens Halm
 */
public class ResourceManagerTag {
	
	
	/**
	 * The id of the ResourceManager in the Parsley Context.
	 */
	public var id:String;
	
	[ChoiceType("org.spicefactory.parsley.flash.resources.tag.LocaleTag")]
	/**
	 * The supported locales.
	 */
	public var locales:Array;
	
	/**
	 * The type of the ResourceManager implementation.
	 */
	public var type:Class = DefaultResourceManager;
	
	/**
	 * Indicates whether loaded bundles should be cached.
	 */
	public var cacheable:Boolean = false;

	/**
	 * Indicates whether the ResourceManager
	 * should store the last active locale in a Local Shared Object and restore it on the next application start.
	 */
	public var persistent:Boolean = false;
	
	
	[Factory]
	/**
	 * Creates a new ResourceManager instance based on the properties of this tag class.
	 * 
	 * @return a new ResourceManager instance
	 */
	public function createResourceManager () : ResourceManagerSpi {
		var typeInfo:ClassInfo = ClassInfo.forClass(type);
		if (!typeInfo.isType(ResourceManagerSpi)) {
			throw new IllegalArgumentError("Specified type " + getQualifiedClassName(type) 
					+ " does not implement ResourceManagerSpi"); 
		}
		var manager:ResourceManagerSpi = typeInfo.newInstance([]) as ResourceManagerSpi;
		
		FlashResourceBindingAdapter.manager = manager;
		
		manager.cacheable = cacheable;
		manager.persistent = persistent;
		
		var first:Boolean = true;
		for each (var locTag:LocaleTag in locales) {
			var loc:Locale = new Locale(locTag.language, locTag.country);
			if (first) {
				first = false;
				manager.defaultLocale = loc;
			}
			else {
				manager.addSupportedLocale(loc);
			}
		}
		return manager;
	}
	
	
}
}
