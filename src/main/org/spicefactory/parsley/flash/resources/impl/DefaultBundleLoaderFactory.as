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
	import org.spicefactory.parsley.flash.resources.impl.DefaultBundleLoader;
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.flash.resources.Locale;
import org.spicefactory.parsley.flash.resources.spi.BundleLoaderFactory;
import org.spicefactory.parsley.flash.resources.spi.ResourceBundleSpi;

/**
 * Default implementation of the <code>BundleLoaderFactory</code> interface.
 * This implementation uses the <code>DefaultBundleLoader</code> class which loads
 * localized message from XML files.
 * 
 * @author Jens Halm
 */
public class DefaultBundleLoaderFactory implements BundleLoaderFactory	{

	/**
	 * @inheritDoc
	 */
	public function createLoaderTask (bundle : ResourceBundleSpi, loc : Locale, basename : String) : Task {
		return new DefaultBundleLoader(bundle, loc, basename);
	}
	
}

}