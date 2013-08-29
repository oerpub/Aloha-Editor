define ['aloha', 'aloha/plugin', 'jquery', 'ui/ui', 'ui/button', 'PubSub'], (Aloha, Plugin, jQuery, UI, Button, PubSub) ->
   
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

      # Custom effects for enable/disable. Attach to the body and delegate,
      # because the toolbar itself might get replaced  or reloaded and our
      # handlers will be lost.
      jQuery('body').on 'enable-action', '.action.paste,.action.copy', (e) ->
        e.preventDefault()
        jQuery(@).fadeIn('fast')
      .on 'disable-action', '.action.paste,.action.copy', (e) ->
        e.preventDefault()
        jQuery(@).fadeOut('fast')

      # Copy becomes available when context is a heading
      focusHeading = null
      PubSub.sub 'aloha.selection.context-change', (m) =>
        if m.range.startOffset == m.range.endOffset and jQuery(m.range.startContainer).parents('h1,h2,h3').length
          focusHeading = jQuery(m.range.startContainer).parents('h1,h2,h3').first()
          @copybutton.enable()
        else
          @copybutton.disable()
    
      # Register with ui
      @pastebutton = UI.adopt 'paste', Button,
        tooltip: 'Paste',
        click: (e) ->
          e.preventDefault()
          range = Aloha.Selection.getRangeObject()
          $elements = jQuery plugin.getBuffer()
          GENTICS.Utils.Dom.insertIntoDOM $elements, range, Aloha.activeEditable.obj

      @copybutton = UI.adopt "copy", Button,
        click: (e) ->
          e.preventDefault()
          $element = focusHeading
          selector = "h1,h2,h3".substr(0, "h1,h2,h3".indexOf($element[0].nodeName.toLowerCase())+2)
          if $element.addBack
            # Jquery >= 1.8
            $elements = $element.nextUntil(selector).addBack()
          else
            # Jquery < 1.8
            $elements = $element.nextUntil(selector).andSelf()
          html = ''
          html += jQuery(element).outerHtml() for element in $elements
          plugin.buffer html

      Aloha.bind 'aloha-editable-created', () =>
        # Disable paste button if there is no content to be pasted
        if localStorage and localStorage.alohaOerCopyBuffer
          @pastebutton.enable()
        else
          @pastebutton.disable()
