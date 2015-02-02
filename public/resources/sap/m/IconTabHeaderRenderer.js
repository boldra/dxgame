/*!
 * SAP UI development toolkit for HTML5 (SAPUI5/OpenUI5)
 * (c) Copyright 2009-2015 SAP SE or an SAP affiliate company.
 * Licensed under the Apache License, Version 2.0 - see LICENSE.txt.
 */
sap.ui.define(['jquery.sap.global','sap/ui/core/IconPool'],function(q,I){"use strict";var a={};a._aAllIconColors=['sapMITBFilterCritical','sapMITBFilterPositive','sapMITBFilterNegative','sapMITBFilterDefault'];a.render=function(r,c){if(!c.getVisible()){return}var i=c.getItems(),t=c._checkTextOnly(i),n=c._checkNoText(i);r.write("<div ");r.addClass("sapMITH");if(c._scrollable){r.addClass("sapMITBScrollable");if(c._bPreviousScrollForward){r.addClass("sapMITBScrollForward")}else{r.addClass("sapMITBNoScrollForward")}if(c._bPreviousScrollBack){r.addClass("sapMITBScrollBack")}else{r.addClass("sapMITBNoScrollBack")}}else{r.addClass("sapMITBNotScrollable")}if(c.getParent().getUpperCase()){r.addClass("sapMITBTextUpperCase")}r.writeControlData(c);r.writeClasses();r.write(">");r.renderControl(c._getScrollingArrow("left"));if(c._bDoScroll){r.write("<div id='"+c.getId()+"-scrollContainer' class='sapMITBScrollContainer'>")}r.write("<div id='"+c.getId()+"-head'");r.addClass("sapMITBHead");if(t){r.addClass("sapMITBTextOnly")}if(n){r.addClass("sapMITBNoText")}r.writeClasses();r.write(">");q.each(i,function(b,o){if(!(o instanceof sap.m.IconTabSeparator)&&!o.getVisible()){return}r.write("<div ");r.writeElementData(o);r.addClass("sapMITBItem");if(o instanceof sap.m.IconTabFilter){if(o.getDesign()===sap.m.IconTabFilterDesign.Vertical){r.addClass("sapMITBVertical")}else if(o.getDesign()===sap.m.IconTabFilterDesign.Horizontal){r.addClass("sapMITBHorizontal")}if(o.getShowAll()){r.addClass("sapMITBAll")}else{r.addClass("sapMITBFilter");r.addClass("sapMITBFilter"+o.getIconColor())}if(!o.getEnabled()){r.addClass("sapMITBDisabled")}var T=o.getTooltip_AsString();if(T){r.writeAttributeEscaped("title",T)}r.writeClasses();r.write(">");r.write("<div id='"+o.getId()+"-tab' class='sapMITBTab'>");if(!o.getShowAll()||!o.getIcon()){r.renderControl(o._getImageControl(['sapMITBFilterIcon','sapMITBFilter'+o.getIconColor()],c,a._aAllIconColors))}if(!o.getShowAll()&&!o.getIcon()&&!t){r.write("<span class='sapMITBFilterNoIcon'> </span>")}if(o.getDesign()===sap.m.IconTabFilterDesign.Horizontal){r.write("</div>");r.write("<div class='sapMITBHorizontalWrapper'>")}r.write("<span ");r.addClass("sapMITBCount");r.writeClasses();r.write(">");if((o.getCount()==="")&&(o.getDesign()===sap.m.IconTabFilterDesign.Horizontal)){r.write("&nbsp;")}else{r.writeEscaped(o.getCount())}r.write("</span>");if(o.getDesign()===sap.m.IconTabFilterDesign.Vertical){r.write("</div>")}if(o.getText().length){r.write("<div id='"+o.getId()+"-text' ");r.addClass("sapMITBText");if(o.getParent().getParent().getUpperCase()){r.addClass("sapMITBTextUpperCase")}r.writeClasses();r.write(">");r.writeEscaped(o.getText());r.write("</div>")}if(o.getDesign()===sap.m.IconTabFilterDesign.Horizontal){r.write("</div>")}r.write("<div class='sapMITBContentArrow'></div>")}else{r.addClass("sapMITBSep");if(!o.getIcon()){r.addClass("sapMITBSepLine")}r.writeClasses();r.write(">");if(o.getIcon()){r.renderControl(o._getImageControl(['sapMITBSepIcon'],c))}}r.write("</div>")});r.write("</div>");if(c._bDoScroll){r.write("</div>")}r.renderControl(c._getScrollingArrow("right"));r.write("</div>")};return a},true);