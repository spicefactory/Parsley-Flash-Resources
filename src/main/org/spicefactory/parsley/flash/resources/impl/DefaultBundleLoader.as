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
	import org.spicefactory.lib.task.util.XmlLoaderTask;
	import org.spicefactory.parsley.flash.resources.impl.LocaleUtil;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.task.Task;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.flash.resources.Locale;
import org.spicefactory.parsley.flash.resources.ResourceBundle;

import flash.events.ErrorEvent;

/**
 * The default bundle loader which loads localized messages from XML files.
 * 
 * @author Jens Halm
 */
public class DefaultBundleLoader extends Task {

	
	public static var PARSLEY_BUNDLE_URI:String = "http://www.spicefactory.org/parsley/flash/resource-bundle";
	
	
	private var _filename:String;
	private var _bundle:ResourceBundle;
	private var _locale:Locale;
	
	private var _xmlLoader:XmlLoaderTask;
	
	private static var _logger:Logger;
	
	/**
	 * Creates a new instance.
	 * 
	 * @param bundle the message bundle to load messages into
	 * @param loc the Locale to add messages for
	 * @param basename the basename of files containing localized messages for that bundle
	 */
	public function DefaultBundleLoader (bundle:ResourceBundle, loc:Locale, basename:String) {
		if (_logger == null) {
			_logger = LogContext.getLogger("org.spicefactory.parsley.localization.impl.DefaultBundleLoader");
		}
		_filename = LocaleUtil.getFilename(basename, loc);
		_bundle = bundle;
		_locale = loc;
		setSuspendable(false);
		setSkippable(false);
		setName("Loader for bundle " + _bundle.id + " and locale " + loc);
	}
	
	/**
	 * @private
	 */
	protected override function doStart () : void {
		_xmlLoader = new XmlLoaderTask(_filename);
		_xmlLoader.addEventListener(TaskEvent.COMPLETE, onComplete);
		_xmlLoader.addEventListener(ErrorEvent.ERROR, onErrorEvent);
		_xmlLoader.start();
	}
	
	/**
	 * @private
	 */
	protected override function doCancel () : void {
		_xmlLoader.cancel();
	}
	
	private function onComplete (event:TaskEvent) : void {
		var xml:XML = _xmlLoader.xml;
		if (!checkName(xml, "resource-bundle") && !checkName(xml, "message-bundle")) {
			// message-bundle just for backwards-compatibility
			return;
		}
		var nodes:XMLList = xml.children();
		var messages:Object = new Object();
		for each (var node:XML in nodes) {
			if (!checkName(node, "resource") && !checkName(node, "message")) {
				// message just for backwards-compatibility
				return;
			}
			var msgKey:String = node.@key;
			if (msgKey == null) {
				onError("Missing key attribute in node: " + node.toXMLString());
			}
			var message:String = node.text()[0];
			messages[msgKey] = message;
		}		
		_bundle.addMessages(_locale, messages);
		complete();
	}	
	
	private function checkName (xml:XML, name:String) : Boolean {
		var qname:QName = xml.name() as QName;
		if (qname.localName != name) {
			onError("Unexpected node name: " + qname.localName);
			return false;
		} else if (qname.uri != PARSLEY_BUNDLE_URI) {
			onError("Expected Namespace: " + PARSLEY_BUNDLE_URI);
			return false;
		}
		return true;
	}
	
	private function onErrorEvent (e:ErrorEvent) : void {
		var msg:String = "Error loading MessageBundle: " + e.text;
		onError(msg);
	}
	
	private function onError (msg:String) : void {
		_logger.error(msg);
		error(msg);
	}	
	
}

}