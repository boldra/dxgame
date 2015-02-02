/*!
 * SAP UI development toolkit for HTML5 (SAPUI5/OpenUI5)
 * (c) Copyright 2009-2015 SAP SE or an SAP affiliate company.
 * Licensed under the Apache License, Version 2.0 - see LICENSE.txt.
 */
sap.ui.define(['jquery.sap.global','sap/ui/core/Control','sap/ui/core/EnabledPropagator','sap/ui/core/ResizeHandler','./library'],function(q,C,E,R,l){"use strict";var F=C.extend("sap.ui.layout.FixFlex",{metadata:{library:"sap.ui.layout",properties:{vertical:{type:"boolean",group:"Appearance",defaultValue:true},fixFirst:{type:"boolean",group:"Misc",defaultValue:true},fixContentSize:{type:"sap.ui.core.CSSSize",group:"Dimension",defaultValue:'auto'}},aggregations:{fixContent:{type:"sap.ui.core.Control",multiple:true,singularName:"fixContent"},flexContent:{type:"sap.ui.core.Control",multiple:false}}}});E.call(F.prototype);F.prototype._handlerResizeNoFlexBoxSupport=function(){var c=this.$(),f,$;if(!c.is(":visible")){return}f=this.$("Fixed");$=this.$("Flexible");if(this.getVertical()){$.height(Math.floor(c.height()-f.height()))}else{$.width(Math.floor(c.width()-f.width()));f.width(Math.floor(f.width()))}};F.prototype._deregisterControl=function(){if(this.sResizeListenerNoFlexBoxSupportId){R.deregister(this.sResizeListenerNoFlexBoxSupportId);this.sResizeListenerNoFlexBoxSupportId=null}if(this.sResizeListenerNoFlexBoxSupportFixedId){R.deregister(this.sResizeListenerNoFlexBoxSupportFixedId);this.sResizeListenerNoFlexBoxSupportFixedId=null}};F.prototype.exit=function(){this._deregisterControl()};F.prototype.onBeforeRendering=function(){this._deregisterControl()};F.prototype.onAfterRendering=function(){if(!q.support.hasFlexBoxSupport){this.sResizeListenerNoFlexBoxSupportFixedId=R.register(this.getDomRef("Fixed"),q.proxy(this._handlerResizeNoFlexBoxSupport,this));this.sResizeListenerNoFlexBoxSupportId=R.register(this.getDomRef(),q.proxy(this._handlerResizeNoFlexBoxSupport,this));this._handlerResizeNoFlexBoxSupport()}};return F},true);
