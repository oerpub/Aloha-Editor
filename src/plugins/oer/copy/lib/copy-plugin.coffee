define ['aloha', 'aloha/plugin', 'jquery', 'ui/ui', 'ui/button'], (Aloha, Plugin, jQuery, UI, Button) ->
   
  buffer = ''
 
  Plugin.create 'copy',
    getBuffer: ->
      if localStorage
        return localStorage.alohaOerCopyBuffer
      else
        return buffer

    buffer: (content) ->
      buffer = content
      buffer = buffer.replace /id="[^"]+"/, ''

      localStorage.alohaOerCopyBuffer = buffer if localStorage

      jQuery('.action.paste').fadeIn('fast')

    init: ->
      plugin = @
    
      jQuery('.action.paste').fadeIn('fast') if localStorage and localStorage.alohaOerCopyBuffer

      # Add a listener
      UI.adopt "paste", Button,
        click: ->
          range = Aloha.Selection.getRangeObject()
          GENTICS.Utils.Dom.insertIntoDOM jQuery(plugin.getBuffer()), range, Aloha.activeEditable.obj
