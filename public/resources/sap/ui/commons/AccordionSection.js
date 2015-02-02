/*!
 * SAP UI development toolkit for HTML5 (SAPUI5/OpenUI5)
 * (c) Copyright 2009-2015 SAP SE or an SAP affiliate company.
 * Licensed under the Apache License, Version 2.0 - see LICENSE.txt.
 */
sap.ui.define(['jquery.sap.global','./library','sap/ui/core/Element'],function(q,l,E){"use strict";var A=E.extend("sap.ui.commons.AccordionSection",{metadata:{library:"sap.ui.commons",properties:{maxHeight:{type:"sap.ui.core.CSSSize",group:"Dimension",defaultValue:null},enabled:{type:"boolean",group:"Behavior",defaultValue:true},collapsed:{type:"boolean",group:"Behavior",defaultValue:false},title:{type:"string",group:"Misc",defaultValue:null}},defaultAggregation:"content",aggregations:{content:{type:"sap.ui.core.Control",multiple:true,singularName:"content"}},events:{scroll:{parameters:{left:{type:"int"},top:{type:"int"}}}}}});A.prototype.init=function(){this.bIgnoreScrollEvent=true;this.oScrollDomRef=null;this.data("sap-ui-fastnavgroup","true",true)};A.prototype.focusFirstControl=function(){var c=this.getContent();if(c[0]){c[0].focus()}};A.prototype.focus=function(){var h=this.getDomRef("hdr");h.focus()};A.prototype.onThemeChanged=function(){var h=this.getDomRef("hdrL");if(h){h.style.width="auto";var t=this;setTimeout(function(){t.onAfterRendering()},0)}};A.prototype.onAfterRendering=function(){this.oScrollDomRef=this.getDomRef("cont");var c=this.oScrollDomRef;var r=this.getDomRef();var a=this.getParent().getDomRef();if(!A._isSizeSet(this.getParent().getWidth())&&A._isSizeSet(this.getMaxHeight())){if(c){var b=c.offsetTop;var t=(r.offsetHeight-b);c.style.height=t+"px";var d=c.offsetHeight;if(d>t){c.style.height=t-(d-t)+"px"}}}var e=q(a).css("border-left-width");var f=q(a).css("border-right-width");var g=parseFloat(e.substring(0,e.indexOf("px")))+parseFloat(f.substring(0,f.indexOf("px")));var D=this.getDomRef("lbl");r.style.width=a.offsetWidth-g+"px";D.style.width=a.offsetWidth-30+"px";var s=this.__scrollproxy__;if(!s){s=this.__scrollproxy__=q.proxy(this.onscroll,this)}this.$("cont").bind("scroll",s)};A.prototype.onBeforeRendering=function(){var s=this.__scrollproxy__;if(s){this.$("cont").unbind("scroll",s)}};A.prototype.setEnabled=function(e){this.setProperty("enabled",e,true);var r=this.getDomRef();if(r){if(e){q(r).removeClass("sapUiAcdSectionDis")}else{q(r).addClass("sapUiAcdSectionDis")}}return this};A.prototype._setCollapsed=function(c){this.setProperty("collapsed",c,true);this._setCollapsedState(c)};A.prototype.setCollapsed=function(c){if(this.getParent()){if(!c){this.getParent().openSection(this.getId())}else{this.getParent().closeSection(this.getId())}}else{this._setCollapsed(c)}return this};A.prototype._setCollapsedState=function(c){if(this.getDomRef()){if(c){var a=sap.ui.getCore().getConfiguration().getAccessibility();if(!this.getParent().getWidth()){this.getDomRef().style.width=this.getDomRef().offsetWidth+"px"}q(this.getDomRef()).addClass("sapUiAcdSectionColl");var t=this.getDomRef("tb");if(t){t.style.display="none"}var b=this.getDomRef("cont");b.style.display="none";if(a){b.setAttribute("aria-expanded","false");b.setAttribute("aria-hidden","true")}this.invalidate()}else{if(!this.getDomRef("cont")){this.invalidate()}else{q(this.getDomRef()).removeClass("sapUiAcdSectionColl");var t=this.getDomRef("tb");if(t){t.style.display="block"}var b=this.getDomRef("cont");b.style.display="block";if(a){b.setAttribute("aria-expanded","true")}if(this.getMaxHeight()){this.getDomRef().style.height=this.getMaxHeight()}}}}};A._isSizeSet=function(c){return(c&&!(c=="auto")&&!(c=="inherit"))};A.prototype._handleTrigger=function(e){if((e.target.id===this.getId()+"-minL")||(e.target.id===this.getId()+"-minR")){var c=!this.getProperty("collapsed");this._setCollapsed(c);e.preventDefault();e.stopPropagation()}};A.prototype.onscroll=function(e){};return A},true);