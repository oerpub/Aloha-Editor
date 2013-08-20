define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'semanticblock/semanticblock-plugin'
  'css!definition/css/definition-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

  TEMPLATE = '<dl class="definition"><dt></dt><dd></dd></dl>'

  Plugin.create 'definition',
    getLabel: ($element) ->
      return 'Definition'
      
    activate: ($element) ->
      term = $element.children('dt').text()
      $definition = $element.children('dd').contents()

      $element.empty()

      $('<div>')
        .text(term)
        .addClass('term')
        .attr('placeholder', 'Enter the term to be defined here')
        .appendTo($element)
        .wrap('<div class="term-wrapper"></div>')
        .aloha()
      
      $('<div>')
        .addClass('body')
        .html($definition)
        .attr('placeholder', "Type the definition here.")
        .appendTo($element)
        .aloha()
     
    deactivate: ($element) ->
      term = $element.children('.term').text()
      $definition = $element.children('.body').contents()

      $element.empty()

      $('<dt>')
        .text(term)
        .appendTo($element)
      
      $('<dd>')
        .html($definition)
        .appendTo($element)

    selector: 'dl.definition'
    init: () ->
      # Add a listener
      UI.adopt "insert-definition", Button,
        click: -> semanticBlock.insertAtCursor(jQuery(TEMPLATE))
      UI.adopt "insertDefinition", Button,
        click: -> semanticBlock.insertAtCursor(jQuery(TEMPLATE))

      semanticBlock.register(this)
