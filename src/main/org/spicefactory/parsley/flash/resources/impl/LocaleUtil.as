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
	
import org.spicefactory.parsley.flash.resources.Locale;
	
/**
 * Utility methods used by the default bundle loading mechanism.
 * 
 * @author Jens Halm
 */
public class LocaleUtil	{
	
	/**
	 * Returns the file suffix for the specified <code>Locale</code>.
	 * 
	 * @param loc the Locale to retrieve the file suffix for
	 * @param ignoreCountry whether the country code should be ignored
	 * @return the file suffix for the specified Locale
	 */
	public static function getSuffix (loc:Locale, ignoreCountry:Boolean = false) : String {
		if (loc.language == "") return "";
		var suffix:String = "_" + loc.language;
		return (ignoreCountry || loc.country == "") ? suffix : suffix + "_" + loc.country;		
	}
	
	/**
	 * Returns the filename for the specified basename and <code>Locale</code>.
	 * 
	 * @param basename the base name for files of a message bundle
	 * @param loc the Locale to obtain a filename for
	 * @return the filename for the specified basename and Locale
	 */
	public static function getFilename (basename:String, loc:Locale) : String {
		return basename + getSuffix(loc) + ".xml";
	}	
	
}

}