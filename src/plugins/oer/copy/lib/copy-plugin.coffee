define ['aloha', 'aloha/plugin', 'jquery', 'ui/ui', 'ui/button'], (Aloha, Plugin, jQuery, UI, Button) ->
   
  buffer = ''
 
  Plugin.create 'copy',

    buffer: (content) ->
      buffer = content
      buffer = buffer.replace /id="[^"]+"/, ''
      jQuery('.action.paste').fadeIn('fast')

    init: ->
      console.log 'loaded'
      # Add a listener
      UI.adopt "paste", Button,
        click: ->
          range = Aloha.Selection.getRangeObject()
          GENTICS.Utils.Dom.insertIntoDOM jQuery(buffer), range, Aloha.activeEditable.obj

          #jQuery('.action.paste').fadeOut('fast')
