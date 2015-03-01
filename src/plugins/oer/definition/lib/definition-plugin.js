// Generated by CoffeeScript 1.6.3
(function() {
  define(['aloha', 'aloha/plugin', 'jquery', 'aloha/ephemera', 'ui/ui', 'ui/button', 'semanticblock/semanticblock-plugin', 'css!definition/css/definition-plugin.css'], function(Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) {
    var TEMPLATE;
    TEMPLATE = '<dl class="definition"><dt></dt><dd></dd></dl>';
    return Plugin.create('definition', {
      getLabel: function($element) {
        return 'Definition';
      },
      activate: function($element) {
        var $definition, term;
        term = $element.children('dt').contents();
        $definition = $element.children('dd').contents();
        jQuery('<div>').append(term).addClass('term').attr('placeholder', 'Enter the term to be defined here').appendTo($element).wrap('<div class="term-wrapper"></div>').aloha();
        jQuery('<div>').addClass('body').addClass('aloha-block-dropzone').attr('placeholder', "Type the definition here.").appendTo($element).aloha().append($definition);
        return $element.find('dt,dd').remove();
      },
      deactivate: function($element) {
        var $definition, term;
        term = $element.find('.term').text();
        $definition = $element.children('.body').contents();
        if (!$definition.length) {
          $definition = $element.children('dd').contents();
        }
        $element.empty();
        jQuery('<dt>').text(term).appendTo($element);
        return jQuery('<dd>').html($definition).appendTo($element);
      },
      selector: 'dl.definition',
      init: function() {
        UI.adopt("insert-definition", Button, {
          click: function() {
            return semanticBlock.insertAtCursor(jQuery(TEMPLATE));
          }
        });
        UI.adopt("insertDefinition", Button, {
          click: function() {
            return semanticBlock.insertAtCursor(jQuery(TEMPLATE));
          }
        });
        return semanticBlock.register(this);
      }
    });
  });

}).call(this);
