define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'semanticblock/semanticblock-plugin'
  'css!quotation/css/quotation-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

  TEMPLATE = "<blockquote class=\"quote\"></blockquote>"

  Plugin.create 'quotation',
    init: () ->
      semanticBlock.activateHandler '.quote', ($element) =>
        $element.aloha()
      semanticBlock.deactivateHandler '.quote', ($element) ->
        $element.mahalo()
        $element.attr('class', 'quote')

      # Add a listener
      UI.adopt "insert-quotation", Button,
        click: (e) -> e.preventDefault(); semanticBlock.insertAtCursor(jQuery(TEMPLATE))

      # For legacy toolbars
      UI.adopt "insertQuotation", Button,
        click: (e) -> e.preventDefault(); semanticBlock.insertAtCursor(jQuery(TEMPLATE))
