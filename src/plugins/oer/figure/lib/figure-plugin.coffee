
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
    # figure is being inserted into content wrapped in div.semantic-container
    # div.semantic-container is wrapped in a p tag by Aloha which is not valid HTML
    if $('.semantic-container').parent('p').length > 0
      $('.semantic-container').unwrap()
    $(element).find('figcaption > p').aloha()

  deactivate = (element) ->

    $(element).find('div.title').mahalo()
    $(element).find('figcaption > p').mahalo()

  Plugin.create 'oer-figure',
    getLabel: -> 'Figure'
    activate: activate
    deactivate: deactivate
    selector: 'figure:not(figure figure)'
    placeholder: semanticBlock.placeholder
    insertPlaceholder: ->
      semanticBlock.insertPlaceholder()
    insertOverPlaceholder: ($content, $placeholder) ->
      $figure = $('<figure>')
        .append($content)

      if not $placeholder.parents('figure').length
        $figure.prepend('<div class="title">')
        $figure.append('<figcaption>')

        semanticBlock.insertOverPlaceholder($figure, $placeholder)
      else
        $placeholder.replaceWith($figure)
    init: () ->
      plugin = @
      semanticBlock.register(plugin)
