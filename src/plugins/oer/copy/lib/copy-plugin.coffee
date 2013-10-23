define ['aloha', 'aloha/plugin', 'jquery', 'ui/ui', 'ui/button', 'PubSub', './path', 'css!copy/css/copy.css'], (Aloha, Plugin, jQuery, UI, Button, PubSub, Path) ->
   
  buffer = ''
  srcpath = null
  content_type = null

  getSection = ($el) ->
    headings = ['h1', 'h2', 'h3']
    level = headings.indexOf $el[0].nodeName.toLowerCase()
    # Pick up all elements until the next heading of the same level or higher
    selector = headings.slice(0, level+1).join(',')

    if $el.addBack
      # Jquery >= 1.8
      $el = $el.nextUntil(selector).addBack()
    else
      # Jquery < 1.8
      $el = $el.nextUntil(selector).andSelf()
    html = ''
    html += jQuery(e).outerHtml() for e in $el
    return html

  Plugin.create 'copy',
    getCurrentPath: ->
      # When copy/pasting html, the images contained therein might have
      # paths relative to that document. Precisely how the path is represented
      # will differ between implementations, so this plugin simply assumes that
      # no path translation needs to be done, unless an alternative is
      # configured.
      if @settings.path
        return @settings.path()
      return null

    getBuffer: ->
      if localStorage
        return localStorage.alohaOerCopyBuffer
      else
        return buffer

    getSrcPath: ->
      if localStorage
        return localStorage.alohaOerCopySrcPath
      else
        return srcpath

    getContentType: ->
      if localStorage
        return localStorage.alohaOerCopyContentType
      else
        return content_type

    buffer: (content, type, path) ->
      buffer = content
      buffer = buffer.replace /id="[^"]+"/, ''
      content_type = type or 'text/html'
      srcpath = path or @getCurrentPath()

      localStorage.alohaOerCopyBuffer = buffer if localStorage
      localStorage.alohaOerCopySrcPath = srcpath if localStorage
      localStorage.alohaOerCopyContentType = content_type if localStorage

      # Disable copy button, it will re-enable when you move the cursor. This
      # gives visual feedback and prevents you from copying the same thing
      # twice.  Enable the paste button explicitly.
      @copybutton.disable()
      @pastebutton.enable()
      @pastebutton.flash?()

    copySection: ($el) ->
      content = getSection($el)

      # Fire a copy event, allow something more suitable to handle this.
      evt = $.Event('copy')
      evt.oerContent = content
      evt.clipboardData =
        setData: (t, c) => @buffer c, t
      Aloha.activeEditable.obj.trigger(evt)
      if not evt.isDefaultPrevented()
        @buffer content

    init: ->
      plugin = @

      # Custom effects for enable/disable. Attach to the body and delegate,
      # because the toolbar itself might get replaced  or reloaded and our
      # handlers will be lost.
      jQuery('body').on 'enable-action', '.action.paste,.action.copy', (e) ->
        e.preventDefault()
        jQuery(@).prop('disabled', false)
      .on 'disable-action', '.action.paste,.action.copy', (e) ->
        e.preventDefault()
        jQuery(@).prop('disabled', true)

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

          # Fire a paste event, allow something else to handle this, if that
          # something deems itself more suitable.
          evt = $.Event('paste')
          evt.clipboardData =
            getData: (t) ->
              if t == plugin.getContentType()
                return plugin.getBuffer()
              return null
          Aloha.activeEditable.obj.trigger(evt)
          return if evt.isDefaultPrevented()

          # Default paste behaviour follows
          $elements = jQuery plugin.getBuffer()
          
          # Remove any classes associated with previewing what element you were copying
          $elements.removeClass('copy-preview focused')

          dstpath = plugin.getCurrentPath()
          if dstpath != null
            dstpath = Path.dirname dstpath
            srcpath = Path.dirname plugin.getSrcPath()

            if srcpath != dstpath
              console.log "Rewriting images, src=#{srcpath}, dst=#{dstpath}"
              $elements.find('img').each (idx, ob) ->
                imgpath = jQuery(ob).attr('data-src')
                if not Path.isabs imgpath
                  uri = Path.normpath srcpath + '/' + imgpath
                  newuri = Path.relpath(uri, dstpath)
                  console.log "Rewriting #{imgpath}"
                  console.log "Absolute location is #{uri}"
                  console.log "Rewritten relative to #{dstpath} = #{newuri}"
                  jQuery(ob).attr('data-src', newuri)
                else
                  console.log "Image path already absolute: #{imgpath}"

          range = Aloha.Selection.getRangeObject()
          GENTICS.Utils.Dom.insertIntoDOM $elements, range, Aloha.activeEditable.obj

      @copybutton = UI.adopt "copy", Button,
        click: (e) ->
          e.preventDefault()
          plugin.copySection focusHeading

      addCopyUi = ($ob) ->
        $ob = $ob.filter () -> not jQuery(this).has('.copy-section-controls').length
        $ob.prepend('''
          <div class="aloha-ephemera copy-section-controls"
               contenteditable="false">
            <span href="#" title="Copy section" class="copy-section"><i class="icon-copy"></i> Copy section</span>
          </div>
        ''')


      Aloha.bind 'aloha-editable-created', (evt, editable) =>
        # Disable paste button if there is no content to be pasted
        if localStorage and localStorage.alohaOerCopyBuffer
          @pastebutton.enable()
        else
          @pastebutton.disable()

        # Scan editor for sections, add discoverability ui
        addCopyUi editable.obj.find('h1,h2,h3')
        editable.obj.on 'change-heading', (e) -> addCopyUi(jQuery(e.target))

        # When one of these buttons are clicked, copy that section.
        editable.obj.on 'click', '.copy-section-controls .copy-section', (e) ->
          plugin.copySection jQuery(e.target).parent().parent()
