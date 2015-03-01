define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'semanticblock/semanticblock-plugin'
  'css!equation/css/equation-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

  TEMPLATE = '<div class="equation"></div>'

  Plugin.create 'equation',
    getLabel: -> 'Equation'
    selector: '.equation'
    activate: ($element) ->
      $contents = $element.contents()
      #kill whitespace
      $contents = '' if $contents.text().trim().length == 0
      
      # for some reason math only loads properly if inside a `p`
      $body = jQuery('<p></p>').attr('placeholder', 'Enter your math notation here')

      #move everything inside the paragraph
      $element.empty().append($body.append($contents))

      $element.click ->
        $body.removeClass('aloha-empty')
        # if there is no math in the element, then we need to add some on click
        if $body.html().trim().length == 0
          Aloha.require ['math/math-plugin'], (MathPlugin) ->
            MathPlugin.insertMathInto($body)
    deactivate: ($element) ->
      # pull the math out of the paragraph on save
      $contents = $element.find('math')
      $element.html($contents)
    init: () ->
      semanticBlock.register this
      # Add a listener
      UI.adopt "insert-equation", Button,
        click: (e) -> e.preventDefault(); semanticBlock.insertAtCursor(jQuery(TEMPLATE))
      UI.adopt "insertEquation", Button,
        click: (e) -> e.preventDefault(); semanticBlock.insertAtCursor(jQuery(TEMPLATE))
