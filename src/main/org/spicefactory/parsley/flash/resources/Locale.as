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
	
/**
 * Represents a geographical or political region.
 * 
 * @author Jens Halm
 */
public class Locale {
	
	private var _language:String = "";
	private var _country:String = "";
	
	/**
	 * The default <code>Locale</code> with empty <code>language</code> 
	 * and <code>country</code> properties.
	 */
	public static var DEFAULT:Locale = new Locale();
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param language the language code for this locale
	 * @param country the country/region code for this locale
	 */
	public function Locale (language:String = "", country:String = "") {
		_language = language;
		_country = country;
	}
	
	/**
	 * The language code for this locale, usually either the empty string 
	 * or a lowercase ISO 639 code.
	 */
	public function get language () : String {
		return _language;
	}
	
	/**
	 * The country/region code for this locale, usually either the empty string 
	 * or an uppercase ISO 3166 2-letter code
	 */
	public function get country () : String {
		return _country;
	}
	
	/**
	 * Compares this instance with the specified <code>Locale</code>.
	 * 
	 * @param loc the Locale to compare with this one
	 * @return true if the specified Locale is equal to this one (has the same language and country code)
	 */
	public function equals (loc:Locale) : Boolean {
		if (loc == this) return true;
		if (loc == null) return false;
		return (loc.language == _language && loc.country == _country);
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "language: " + _language + " - country: " + _country;
	}	

	
}
	
}