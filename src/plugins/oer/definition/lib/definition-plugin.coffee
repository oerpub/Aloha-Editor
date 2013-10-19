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
      term = $element.children('dt').contents()
      $definition = $element.children('dd').contents()

      jQuery('<div>')
        .append(term)
        .addClass('term')
        .attr('placeholder', 'Enter the term to be defined here')
        .appendTo($element)
        .wrap('<div class="term-wrapper"></div>')
        .aloha()
      
      jQuery('<div>')
        .addClass('body')
        .addClass('aloha-block-dropzone')
        .attr('placeholder', "Type the definition here.")
        .appendTo($element)
        .aloha()
        .append($definition)

      # these elements need to stick around in case deactivate runs 
      # during the activation, but now we can remove them
      $element.find('dt,dd').remove()
     
    deactivate: ($element) ->
      term = $element.find('.term').text()
      $definition = $element.children('.body').contents()

      # if the body is empty check for a 'dd', we might
      # not be done activating
      if not $definition.length
        $definition = $element.children('dd').contents()

      $element.empty()

      jQuery('<dt>')
        .text(term)
        .appendTo($element)
      
      jQuery('<dd>')
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
