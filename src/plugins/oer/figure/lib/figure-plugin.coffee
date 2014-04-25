
define [
  'aloha',
  'jquery',
  'aloha/plugin',
  'semanticblock/semanticblock-plugin',
  'css!figure/css/figure-plugin.css'
], (Aloha, jQuery, Plugin, semanticBlock) ->

  activate = (element) ->

    $(element).find('div.title').aloha()

    if $(element).find('figcaption').children().length != 1
      $(element).find('figcaption').wrapInner('<p>')

    $(element).find('figcaption > p').aloha()

  deactivate = (element) ->
    # Only call mahalo if the element is editable, thereby saving some time
    if $(element).is('.aloha-editable')
      $(element).find('div.title').mahalo()
      $(element).find('figcaption > p').mahalo()

  Plugin.create 'oer-figure',
    getLabel: -> 'Figure'
    activate: activate
    deactivate: deactivate
    selector: 'figure'
    insertPlaceholder: ->
      semanticBlock.insertPlaceholder()
    insertOverPlaceholder: ($content, $placeholder) ->
      $figure = $('<figure>')
        .append('<div class="title">')
        .append($content)
        .append('<figcaption>')
        
      semanticBlock.insertOverPlaceholder($figure, $placeholder)
    init: () ->
      plugin = @
      semanticBlock.register(plugin)

