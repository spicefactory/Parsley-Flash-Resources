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
 
package org.spicefactory.parsley.flash.resources.impl {

import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.task.SequentialTaskGroup;
import org.spicefactory.lib.task.TaskGroup;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.flash.resources.Locale;
import org.spicefactory.parsley.flash.resources.ResourceBundle;
import org.spicefactory.parsley.flash.resources.adapter.FlashResourceBindingAdapter;
import org.spicefactory.parsley.flash.resources.events.LocaleSwitchEvent;
import org.spicefactory.parsley.flash.resources.spi.ResourceBundleSpi;
import org.spicefactory.parsley.flash.resources.spi.ResourceManagerSpi;
import org.spicefactory.parsley.resources.processor.ResourceBindingProcessor;

import flash.events.ErrorEvent;
import flash.events.EventDispatcher;
import flash.net.SharedObject;
import flash.system.Capabilities;

/**
 * Default implementation of the <code>LocaleManagerSpi</code> interface.
 * 
 * @author Jens Halm
 */
public class DefaultResourceManager extends EventDispatcher implements ResourceManagerSpi {
	
	
	ResourceBindingProcessor.adapterClass = FlashResourceBindingAdapter;

	
	private var _initialized:Boolean;
	private var _switching:Boolean;
	private var _persistent:Boolean;
	private var _cacheable:Boolean;
	
	private var _defaultLocale:Locale;
	private var _currentLocale:Locale;
	private var _nextLocale:Locale;
	private var _supportedLocales:Object;
	
	private var _defaultBundle:ResourceBundleSpi;
	private var _bundles:Object;
	
	
	private static const _logger:Logger = LogContext.getLogger(DefaultResourceManager);
	
	
	/**
	 * Creates a new instance.
	 */
	function DefaultResourceManager () {
		_initialized = false;
		_switching = false;
		_supportedLocales = new Object();
		_defaultBundle = new DefaultResourceBundle();
		_bundles = new Object();
	}
	
	/**
	 * @inheritDoc
	 */
	public function get persistent () : Boolean {
		return _persistent;
	}
	public function set persistent (persistent:Boolean) : void {
		_persistent = persistent;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get currentLocale () : Locale {
		return _currentLocale;
	}

	public function set currentLocale (loc:Locale) : void {
		if (!_initialized) {
			var msg:String = "Attempt to set the Locale before ResourceManager was initialized";
			_logger.error(msg);
			throw new IllegalStateError(msg);
		} else if (_switching) {
			var msg2:String = "Switching locale already in progress";
			_logger.error(msg2);
			throw new IllegalStateError(msg2);
		}
		if (_currentLocale != null && _currentLocale.equals(loc)) {
			_logger.warn("Locale " + loc + " is already active");
			return;		
		} 
		if (isSupportedLocale(loc)) {
			_switching = true;
			_nextLocale = loc;
			_defaultLocale = null;
			var group : TaskGroup = new SequentialTaskGroup("TaskGroup for switching Locale");
			addBundleLoaders(_nextLocale, group);
			group.addEventListener(TaskEvent.COMPLETE, onComplete);
			group.addEventListener(ErrorEvent.ERROR, onError);
			dispatchEvent(new LocaleSwitchEvent(LocaleSwitchEvent.START, _nextLocale));
			group.start();
		} else {
			var msg3:String = "The specified Locale (" + loc + ") is not supported";
			_logger.error(msg3);
			throw new IllegalArgumentError(msg3);
		}
	}
	
	private function onComplete (event : TaskEvent) : void {
		_logger.info("MessageSource loaded completely");
		_currentLocale = _nextLocale;
		_nextLocale = null;
		_switching = false;
		dispatchEvent(new LocaleSwitchEvent(LocaleSwitchEvent.COMPLETE, _currentLocale));
		if (_persistent) {
			writeLocale(_currentLocale);
		}
	}
	
	private function onError (evt:ErrorEvent) : void {
		_logger.error("Error loading MessageSource: " + evt.text);
		_switching = false;
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, evt.text));
	}
	

	/**
	 * @inheritDoc
	 */
	public function isSupportedLocale (loc:Locale) : Boolean {
		if (loc.language == "") return true;
		return (_supportedLocales[LocaleUtil.getSuffix(loc)] != undefined);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get supportedLocales () : Array {
		var arr:Array = new Array();
		for (var each:String in _supportedLocales) {
			arr.push(_supportedLocales[each]);
		}
		return arr.concat();
	}
	
	private function readLocale () : Locale {
		var lso:SharedObject = SharedObject.getLocal("__locale__");
		var localeData:Object = lso.data.locale;
		if (localeData != null) {
			return new Locale(localeData.language, localeData.country);
		} else {
			return null;
		}
	}
	
	private function writeLocale (loc:Locale) : void {
		var localeData:Object = {language: loc.language, country: loc.country};
		var lso:SharedObject = SharedObject.getLocal("__locale__");
		lso.data.locale = localeData;
		lso.flush();
	}
	
	/**
	 * @inheritDoc
	 */
	public function get defaultLocale () : Locale {
		return _defaultLocale;
	}

	public function set defaultLocale (loc:Locale) : void {
		_defaultLocale = loc;
		addSupportedLocale(loc);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addSupportedLocale (loc:Locale) : void {
		_supportedLocales[LocaleUtil.getSuffix(loc)] = loc;
		if (loc.country != "" && loc.language != "") {
			_supportedLocales[loc.language] = new Locale(loc.language, "");
		}
	}
	
	/**
	 * @inheritDoc
	 */
	[Init]
	public function initialize (defaultLocale:Locale = null) : void {
		if (_initialized) {
			_logger.error("LocaleManager was already initialized");
			return;
		}
		_initialized = true;
		// try to use programmatically specified default
		if (defaultLocale != null) {
			if (isSupportedLocale(defaultLocale)) {
				_logger.info("Using programmatically specified locale (" + defaultLocale + ")");
				currentLocale = defaultLocale;
				return;
			} else {
				_logger.warn("The specified Locale (" + defaultLocale + ") is not supported");
			}
		}
		// check if localization is configured as persistent and if there is a supported locale found in the LSO
		if (_persistent) {
			var lastLocale:Locale = readLocale();
			if (lastLocale != null) {
				if (isSupportedLocale(lastLocale)) {
					_logger.info("Using persistent locale (" + lastLocale + ") from previous session");
					currentLocale = lastLocale;
					return;
				} else {
					_logger.warn("The persisted Locale (" + lastLocale + ") is not supported");
				}
			}
		}
		if (_defaultLocale != null) {
			// use the default locale set in the configuration files
			_logger.info("Using declaratively specified locale (" + _defaultLocale + ")");
			currentLocale = _defaultLocale;
		} else {
			// try the language of the OS and check if it is supported
			var sysLang:String = Capabilities.language;
			var lang:String = "";
			var country:String = "";
			if (sysLang.length > 2) {
				var parts:Array = sysLang.split("_");
				lang = parts[0];
				country = parts[1];
			} else {
				lang = sysLang;
			}
			var osLocale:Locale = new Locale(lang, country);
			if (isSupportedLocale(osLocale)) {
				_logger.info("Using system default locale (" + osLocale + ")");
				currentLocale = osLocale;
			} else {
				// if all fails use the empty locale as default
				_logger.warn("Using empty Locale as fallback");
				currentLocale = new Locale("", "");
			}
		}
	}	
	
	
	// old MessageSource implementation ********************************************************************************
	
	
	public function set cacheable (cacheable:Boolean) : void {
		_cacheable = cacheable;
		for each (var bundle:ResourceBundle in _bundles) {
			bundle.cacheable = cacheable;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function get cacheable () : Boolean {
		return _cacheable;
	}
	
	public function set defaultBundle (bundle:ResourceBundleSpi) : void {
		addBundle(bundle);
		_defaultBundle = bundle;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get defaultBundle () : ResourceBundleSpi {
		return _defaultBundle;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addBundle (bundle:ResourceBundleSpi) : void {
		bundle.cacheable = _cacheable;
		_bundles[bundle.id] = bundle;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getBundle (bundleId:String = null) : ResourceBundle {
		if (bundleId == null) {
			return _defaultBundle;
		} else {
			return ResourceBundle(_bundles[bundleId]);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function getMessage (messageKey:String, bundleId:String = null, params:Array = null) : String {
		params = (params == null) ? new Array() : params ;
		var bundle:ResourceBundle = getBundle(bundleId);
		return bundle.getMessage(messageKey, params);
	}
	
	/**
	 * @inheritDoc
	 */
	private function addBundleLoaders (loc:Locale, chain : TaskGroup) : void {
		for each (var bundle:ResourceBundleSpi in _bundles) {
			bundle.addLoaders(loc, chain);
		}
		/* setting priority to 1 since this listener must be processed before the
		   one that leads to the COMPLETE event of the ApplicationContextParser */
		chain.addEventListener(TaskEvent.COMPLETE, onLoad, false, 1); 
	}
	
	private function onLoad (event:TaskEvent) : void {
		for each (var bundle:ResourceBundleSpi in _bundles) {
			bundle.applyNewMessages();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	[Destroy]
	public function destroy () : void {
		for each (var bundle:ResourceBundleSpi in _bundles) {
			bundle.destroy();
		}
	}
	
}

}