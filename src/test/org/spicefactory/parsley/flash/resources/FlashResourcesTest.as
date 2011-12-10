package org.spicefactory.parsley.flash.resources {

import org.spicefactory.parsley.dsl.context.ContextBuilderSetup;
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.hamcrest.object.equalTo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.flash.resources.events.LocaleSwitchEvent;
import org.spicefactory.parsley.flash.resources.model.AnnotatedResourceBinding;
import org.spicefactory.parsley.flash.resources.model.SecondResourceBinding;
import org.spicefactory.parsley.flash.resources.spi.ResourceManagerSpi;
import org.spicefactory.parsley.flash.resources.tag.FlashResourceXmlSupport;
import org.spicefactory.parsley.xml.XmlConfig;

import flash.net.SharedObject;

public class FlashResourcesTest {
	
	
	FlashResourceXmlSupport.initialize();
	
	
	private var binding:AnnotatedResourceBinding;
	private var binding2:SecondResourceBinding;

	
	[BeforeClass]
	public static function clearLsoLocale () : void {
		var lso:SharedObject = SharedObject.getLocal("__locale__");
		delete lso.data.locale;
	}
	
	private function prepareContext (xml:XML, callback:Function, parent:Context = null) : void {
		var setup: ContextBuilderSetup = ContextBuilder.newSetup();
		if (parent) setup.parent(parent);
		var context:Context = setup.newBuilder().config(XmlConfig.forInstance(xml)).build();
    	var f:Function = Async.asyncHandler(this, callback, 3000);		
		context.addEventListener(ContextEvent.INITIALIZED, f);
	}
	
	private function getResourceManager (context:Context) : ResourceManager {
		return context.getObjectByType(ResourceManagerSpi) as ResourceManager;
	}
	
	[Test(async)]
	public function getMessageIgnoreCountry () : void {
		var xml:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
            <res:resource-manager id="rm">
	            <res:locale language="en" country="US"/>
	            <res:locale language="de" country="DE"/>
	            <res:locale language="fr" country="FR"/>
	        </res:resource-manager>
	        <res:resource-bundle id="test" basename="testBundle" localized="true" ignore-country="true"/>
    	</objects>;  
    	prepareContext(xml, onTestGetMessageIgnoreCountry);		
	}
	
	private function onTestGetMessageIgnoreCountry (event:ContextEvent, data:Object = null) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = getResourceManager(context);
		assertThat(rm.getMessage("test", "test", [2,2,4]), equalTo("2 + 2 = 4"));
	}
	
	[Test(async)]
	public function getLocalizedMessage () : void {
		var xml:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
            <res:resource-manager id="rm">
	            <res:locale language="en" country="US"/>
	            <res:locale language="de" country="DE"/>
	            <res:locale language="fr" country="FR"/>
	        </res:resource-manager>
	        <res:resource-bundle id="test" basename="testBundle" localized="true"/>
    	</objects>;  
    	prepareContext(xml, onTestGetLocalizedMessage);		
	}
	
	private function onTestGetLocalizedMessage (event:ContextEvent, data:Object = null) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = getResourceManager(context);
		assertThat(rm.getMessage("us", "test"), equalTo("USA"));
	}
	
	[Test(async)]
	public function resourceBinding () : void {
		var xml:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
            <res:resource-manager id="rm">
	            <res:locale language="en" country="US"/>
	            <res:locale language="de" country="DE"/>
	            <res:locale language="fr" country="FR"/>
	        </res:resource-manager>
	        <res:resource-bundle id="test" basename="testBundle" localized="true" ignore-country="true"/>
	        <object id="binding" type="org.spicefactory.parsley.flash.resources.model.AnnotatedResourceBinding"/>
	        <object id="binding2" type="org.spicefactory.parsley.flash.resources.model.SecondResourceBinding"/>
    	</objects>;  
    	prepareContext(xml, onTestResourceBinding);	
	}
	
	private function onTestResourceBinding (event:ContextEvent, data:Object = null) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = getResourceManager(context);
		binding = context.getObject("binding") as AnnotatedResourceBinding;
		binding2 = context.getObject("binding2") as SecondResourceBinding;
		assertThat(binding.boundValue, equalTo("English"));
		assertThat(binding2.boundValue, equalTo("English 2"));
		rm.addEventListener(LocaleSwitchEvent.COMPLETE, Async.asyncHandler(this, onSwitchLocale, 3000));
    	rm.currentLocale = new Locale("de", "DE");
	}
	
	private function onSwitchLocale (event:LocaleSwitchEvent, data:Object = null) : void {
		assertThat(binding.boundValue, equalTo("Deutsch"));
		assertThat(binding2.boundValue, equalTo("Deutsch 2"));
	}
	
	[Test(async)]
	public function twoBundles () : void {
		var xml1:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
            <res:resource-manager id="rm">
	            <res:locale language="de" country="DE"/>
	        </res:resource-manager>
	        <res:resource-bundle id="a_text" basename="textA" localized="false" ignore-country="true"/>
    	</objects>;  
		var xml2:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
	        <res:resource-bundle id="b_text" basename="textB" localized="false" ignore-country="true"/>
    	</objects>;  
		var context:Context = ContextBuilder.newBuilder()
			.config(XmlConfig.forInstance(xml1))
			.config(XmlConfig.forInstance(xml2))
			.build();
    	var f:Function = Async.asyncHandler(this, onTestTwoBundles, 3000);		
		context.addEventListener(ContextEvent.INITIALIZED, f);
	}
	
	private function onTestTwoBundles (event:ContextEvent, data:Object = null) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = context.getObjectByType(ResourceManager) as ResourceManager;
		assertThat(rm.getMessage("a", "a_text"), equalTo("Text A"));
		assertThat(rm.getMessage("b", "b_text"), equalTo("Text B"));
	}
	
	[Test(async)]
	public function bundleInChildContext () : void {
		var xmlParent:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
            <res:resource-manager id="rm">
	            <res:locale language="de" country="DE"/>
	        </res:resource-manager>
	        <res:resource-bundle id="a_text" basename="textA" localized="false" ignore-country="true"/>
    	</objects>;  
		prepareContext(xmlParent, onTestBundleInChildContext1);
	}
	
	private function onTestBundleInChildContext1 (event:ContextEvent, data:Object = null) : void {
		var xmlChild:XML = <objects xmlns="http://www.spicefactory.org/parsley" 
			xmlns:res="http://www.spicefactory.org/parsley/flash/resources"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd">
			
	        <res:resource-bundle id="b_text" basename="textB" localized="false" ignore-country="true"/>
    	</objects>;
		var parent:Context = event.target as Context;
		prepareContext(xmlChild, onTestBundleInChildContext2, parent);
	}
	
	private function onTestBundleInChildContext2 (event:ContextEvent, data:Object = null) : void {
		var context:Context = event.target as Context;
		var rm:ResourceManager = getResourceManager(context);
		assertThat(rm.getMessage("a", "a_text"), equalTo("Text A"));
		assertThat(rm.getMessage("b", "b_text"), equalTo("Text B"));
	}

		
}

}