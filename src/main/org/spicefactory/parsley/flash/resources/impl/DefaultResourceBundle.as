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
	import org.spicefactory.parsley.flash.resources.impl.LocaleUtil;
import org.spicefactory.lib.task.TaskGroup;	
import org.spicefactory.parsley.flash.resources.spi.ResourceBundleSpi;
import org.spicefactory.parsley.flash.resources.spi.BundleLoaderFactory;
import org.spicefactory.parsley.flash.resources.Locale;
	
/**
 * Default implementation of the <code>MessageBundleSpi</code> interface.
 * 
 * @author Jens Halm
 */
public class DefaultResourceBundle implements ResourceBundleSpi {

	private var _loaderFactory:BundleLoaderFactory;
	
	private var _id:String;
	private var _basename:String;
	private var _localized:Boolean;
	private var _ignoreCountry:Boolean;
	
	private var _cacheable:Boolean;
	private var _locale:Locale;
	
	private var _messages:Object;
	private var _newMessages:Object;
	
	/**
	 * @inheritDoc
	 */
	public function init (id:String, basename:String, localized:Boolean, ignoreCountry:Boolean) : void {
		_id = id;
		_basename = basename;
		_localized = localized;
		_ignoreCountry = ignoreCountry;
		_messages = new Object();
		_newMessages = new Object();
	}
	
	/**
	 * @inheritDoc
	 */
	public function get id () : String {
		return _id;
	}
	
	public function set bundleLoaderFactory (factory:BundleLoaderFactory) : void {
		_loaderFactory = factory;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get bundleLoaderFactory () : BundleLoaderFactory {
		return _loaderFactory;
	}
	
	public function set cacheable (cacheable:Boolean) : void {
		_cacheable = cacheable;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get cacheable () : Boolean {
		return _cacheable;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addMessages (loc:Locale, messages:Object) : void {
		var suffix:String = LocaleUtil.getSuffix(loc);
		if (suffix == "") suffix = "__base";
		_newMessages[suffix] = messages;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addLoaders (newLocale:Locale, chain : TaskGroup) : void {
		if (_locale != null && _locale.equals(newLocale)) return;
		if (!_cacheable) {
			_newMessages = new Object();
			// always keep the base messages
			_newMessages.__base = _messages.__base;
			if (_localized && _locale != null && _locale.language == newLocale.language) {
				// we are switching to a different country but keep the same language
				_newMessages["_" + _locale.language] = _messages["_" + _locale.language];
			}
		} else {
			_newMessages = _messages;
		}
		_locale = newLocale;
		
		if (_newMessages.__base == undefined) {
			chain.addTask(_loaderFactory.createLoaderTask(this, Locale.DEFAULT, _basename));
		}
		var language:String = _locale.language;
		if (_localized && language != "") {
			var lang:Locale = new Locale(language);
			if (_newMessages[getBundleKey(lang, false)] == undefined) {
				chain.addTask(_loaderFactory.createLoaderTask(this, lang, _basename));
			}
			var country:String = _locale.country;
			if (!_ignoreCountry && country != "" && _newMessages[LocaleUtil.getSuffix(_locale)] == undefined) {
				chain.addTask(_loaderFactory.createLoaderTask(this, _locale, _basename));
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function applyNewMessages () : void {
		_messages = _newMessages;
		_newMessages = new Object();
	}
	
	/**
	 * @inheritDoc
	 */
	public function getMessage (messageKey:String, params:Array) : String {
		var msg:String; 
		
		if (_localized) {
			if (!_ignoreCountry && _locale.country != "") {
				msg = _messages[getBundleKey(_locale, false)][messageKey];
			}
			if (msg == null) {
				msg = _messages[getBundleKey(_locale, true)][messageKey];
			}
		}
		if (msg == null) {
			msg = _messages.__base[messageKey];
		}
		
		if (msg != null && params != null && params.length > 0) {
			msg = applyParams(msg, params);
		}
		return msg;
	}
	
	private function getBundleKey (locale:Locale, ignoreCountry:Boolean) : String {
		var bundleKey:String = LocaleUtil.getSuffix(_locale, ignoreCountry);
		return (bundleKey == "") ? "__base" : bundleKey;
	}
	 
	private function applyParams (msg:String, params:Array) : String {
		var parts:Array = msg.split("{");
		var result:String = parts[0];
		for (var i:Number = 1; i < parts.length; i++) {
			var part:String = parts[i];
			var sub:Array = part.split("}");
			var index:uint = uint(sub[0]);
			if (isNaN(index) || params[index] == undefined) {
				result += "{" + index + "?}";
			} else {
				result += params[index];
			}
			result += sub[1];
		}
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function destroy () : void {
		_messages = new Object();
		_newMessages = new Object();
	}

}

}