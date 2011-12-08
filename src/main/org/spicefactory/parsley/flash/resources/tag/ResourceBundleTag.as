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
import org.spicefactory.lib.task.SequentialTaskGroup;
import org.spicefactory.lib.task.TaskGroup;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.config.Configuration;
import org.spicefactory.parsley.config.RootConfigurationElement;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.flash.resources.impl.DefaultBundleLoaderFactory;
import org.spicefactory.parsley.flash.resources.impl.DefaultResourceBundle;
import org.spicefactory.parsley.flash.resources.spi.BundleLoaderFactory;
import org.spicefactory.parsley.flash.resources.spi.ResourceBundleSpi;
import org.spicefactory.parsley.flash.resources.spi.ResourceManagerSpi;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;

[XmlMapping(elementName="resource-bundle")]
[AsyncInit]
/**
 * Represent the resource-bundle XML tag.
 * 
 * @author Jens Halm
 */
public class ResourceBundleTag extends EventDispatcher implements RootConfigurationElement {
	
	
	[Required]
	/**
	 * The id of the bundle.
	 */
	public var id:String;
	
	[Required]
	/** 
     * The basename of files containing messages for this bundle.
	 * For the locale #cdi en_US #cdi for example the basename messages/tooltips will instruct Parsley to load the 
	 * following files: #cdi messages/tooltips_en_US.xml #cdi, #cdi messages/tooltips_en.xml #cdi and #cdi messages/tooltips.xml #cdi.
     */ 
	public var basename:String;

	/**
	 * The type of the ResourceBundle implementation.
	 */
	public var type:Class = DefaultResourceBundle;
	
	/**
	 * The type of the BundleLoaderFactory to use when loading bundle files.
	 */
	public var loaderFactory:Class = DefaultBundleLoaderFactory;
	
	/**
	 * Indicates whether the bundle is localized.
	 * If set to false the framework will only load 
     * the resources for the basename like #cdi messages/tooltips.xml #cdi and not look for files with localized messages.
	 */
	public var localized:Boolean = true;
	
	/**
	 * Indicates whether the framework should 
     * ignore the country code of the active locale for this bundle.
	 */
	public var ignoreCountry:Boolean = false;
	
	
	[Inject][Ignore]
	/**
	 * The ResourceManager this bundle belongs to.
	 */
	public var resourceManager:ResourceManagerSpi;
	
	
	[Init]
	/**
	 * Loads the bundle configured by this tag class and adds it to the ResourceManager.
	 */
	public function loadBundle () : void {
		var bundleInstance:Object = new type();
		if (!(bundleInstance is ResourceBundleSpi)) {
			throw new IllegalArgumentError("Specified type " + getQualifiedClassName(type) 
					+ " does not implement ResourceBundleSpi"); 
		}
		var bundle:ResourceBundleSpi = bundleInstance as ResourceBundleSpi;
		var factoryInstance:Object = new loaderFactory();
		if (!(factoryInstance is BundleLoaderFactory)) {
			throw new IllegalArgumentError("Specified loaderFactory " + getQualifiedClassName(type) 
					+ " does not implement BundleLoaderFactory"); 
		}
		bundle.bundleLoaderFactory = factoryInstance as BundleLoaderFactory;
		bundle.init(id, basename, localized, ignoreCountry);
		
		var tg:TaskGroup = new SequentialTaskGroup();
		tg.data = bundle;
		bundle.addLoaders(resourceManager.currentLocale, tg);
		tg.addEventListener(TaskEvent.COMPLETE, loaderComplete);
		tg.addEventListener(ErrorEvent.ERROR, loaderError);
		tg.start();
	}
	
	
	private function loaderComplete (event:Event) : void {
		var bundle:ResourceBundleSpi = event.target.data as ResourceBundleSpi;
		bundle.applyNewMessages();
		resourceManager.addBundle(bundle);
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function loaderError (event:Event) : void {
		dispatchEvent(event.clone());
	}
	
	public function process (config:Configuration) : void {
		var builder:ObjectDefinitionBuilder = config.builders.forClass(ResourceBundleTag);
		builder.lifecycle().instantiator(new TagInstantiator(this));
		builder.asSingleton().id(id).order(int.MIN_VALUE).register();
	}
	
	
}
}

import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ObjectInstantiator;
import org.spicefactory.parsley.flash.resources.tag.ResourceBundleTag;

class TagInstantiator implements ObjectInstantiator {
	private var tag:ResourceBundleTag;
	function TagInstantiator (tag:ResourceBundleTag) {
		this.tag = tag;
	}
	public function instantiate (target:ManagedObject):Object {
		return tag;
	}
}
