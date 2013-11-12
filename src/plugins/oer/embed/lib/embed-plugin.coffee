define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'semanticblock/semanticblock-plugin'
  'css!embed/css/embed-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

  TEMPLATE = '<div class="embedded"></div>'
  EMPTY = '<div class="empty-state"><a href="">add a thing</a></div>'

  Plugin.create 'embed',
    getLabel: -> 'Embeded'
    selector: '.embedded'
    activate: ($element) ->
      if not $element.contents().length
        $element.append(jQuery(EMPTY))

      $element.on 'click', '.empty-state a', ->
        embedCode = prompt 'code please'
        $element.empty().append(embedCode)

    deactivate: ($element) ->
      $element.siblings('.empty-state').remove()

    init: () ->
      semanticBlock.register this
