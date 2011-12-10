package org.spicefactory.parsley.flash.resources.model {

/**
 * @author Jens Halm
 */
public class SecondResourceBinding {
	
	
	[Bindable]
	[ResourceBinding(bundle="test", key="bind2")]
	public var boundValue:String;
	
	
}
}
