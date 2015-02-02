/*!
 * SAP UI development toolkit for HTML5 (SAPUI5/OpenUI5)
 * (c) Copyright 2009-2015 SAP SE or an SAP affiliate company.
 * Licensed under the Apache License, Version 2.0 - see LICENSE.txt.
 */
sap.ui.define(['jquery.sap.global','./SliderRenderer','sap/ui/core/Renderer'],function(q,S,R){"use strict";var a=R.extend(S);a.renderGrip=function(r,s){var b=r;b.write('<DIV');b.writeAttribute('id',s.getId()+'-grip');if(s.getEnabled()){b.writeAttribute('tabIndex','0')}else{b.writeAttribute('tabIndex','-1')}b.writeAttribute('class','sapUiSliGrip');b.writeAttribute('title',s.getValue());b.writeAccessibilityState(s,{role:'slider',controls:s.getId()+'-grip2',orientation:'horizontal',valuemin:s.getMin(),valuemax:s.getValue2(),live:'assertive',disabled:!s.getEditable()||!s.getEnabled(),describedby:s.getTooltip_AsString()?(s.getId()+'-Descr '+s.getAriaDescribedBy().join(" ")):undefined});b.write('>&#9650;</DIV>');b.write('<DIV');b.writeAttribute('id',s.getId()+'-grip2');if(s.getEnabled()){b.writeAttribute('tabIndex','0')}else{b.writeAttribute('tabIndex','-1')}b.writeAttribute('class','sapUiSliGrip');b.writeAttribute('title',s.getValue2());b.writeAccessibilityState(s,{role:'slider',controls:s.getId()+'-grip',orientation:'horizontal',valuemin:s.getValue(),valuemax:s.getMax(),live:'assertive',disabled:!s.getEditable()||!s.getEnabled(),describedby:s.getTooltip_AsString()?(s.getId()+'-Descr '+s.getAriaDescribedBy().join(" ")):undefined});b.write('>&#9650;</DIV>')};a.controlAdditionalCode=function(r,s){r.addClass('sapUiRSli')};return a},true);
