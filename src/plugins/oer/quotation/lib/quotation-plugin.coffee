define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'semanticblock/semanticblock-plugin'
  'css!quotation/css/quotation-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

  TEMPLATE = '<blockquote class="quote"></blockquote>'

  Plugin.create 'quotation',
    selector: '.quote'
    getLabel: -> 'Quotation'
    activate: ($element) ->
      $element.attr('data-format-whitelist', '["p"]')
      Ephemera.markAttr($element, 'data-format-whitelist')

      $element.attr('placeholder', 'Type the text of you quotation here.')
      $element.aloha()
      $element.addClass('aloha-block-dropzone')
    deactivate: ($element) ->
      $element.mahalo()
      $element.attr('class', 'quote')
    init: () ->
      semanticBlock.register this

      # Add a listener
      UI.adopt "insert-quotation", Button,
        click: (e) -> e.preventDefault(); semanticBlock.insertAtCursor(jQuery(TEMPLATE))

      # For legacy toolbars
      UI.adopt "insertQuotation", Button,
        click: (e) -> e.preventDefault(); semanticBlock.insertAtCursor(jQuery(TEMPLATE))
