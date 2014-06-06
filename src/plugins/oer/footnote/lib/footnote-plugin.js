define([
	'aloha',
	'jquery',
	'aloha/plugin',
	'ui/ui',
//	'ui/toggleButton',
	'ui/button',
        'css!footnote/css/footnote.css'
//	'ui/scopes',
//	'ui/port-helper-attribute-field',
//	'i18n!abbr/nls/i18n',
//	'i18n!aloha/nls/i18n'
], function (
	Aloha,
	jQuery,
	Plugin,
	Ui,
//	ToggleButton,
	Button
//	Scopes,
//	AttributeField,
//	i18n,
//	i18nCore
){
    'use strict';
    var GENTICS = window.GENTICS; 
    return Plugin.create('footnote', {
        init: function () {
            // Executed on plugin initialization
            Ui.adopt("insertFootnote", Button, {
                click: function() {
                    //
                    // All the footnote insertion code here.
                    //
                   var range = Aloha.Selection.getRangeObject();
                   var footnotedata = prompt("Enter your footnote");
                   var element = $(" <span class='footnote-marker'><span class='footnote-data'>" + footnotedata + " </span></span> ");
                   console.log(element);
                   GENTICS.Utils.Dom.insertIntoDOM(element , range, Aloha.activeEditable.obj)
                }
            });


        },
           
    });

});
