package org.spicefactory.parsley.flash.resources.model {

/**
 * @author Jens Halm
 */
public class AnnotatedResourceBinding {
	
	
	[Bindable]
	[ResourceBinding(bundle="test", key="bind")]
	public var boundValue:String;
	
	
}
}
