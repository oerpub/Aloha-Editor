define [ 'jquery', 'aloha', 'aloha/plugin', 'PubSub' ], (
    jQuery, Aloha, Plugin, PubSub, Copy) ->

  squirreledEditable = null
  $ROOT = jQuery('body') # Could also be configured to some other div

  makeItemRelay = (slot) ->
    # This class adapts button functions Aloha expects to functions the toolbar
    # uses
    class ItemRelay
      constructor: () ->
      show: () -> $ROOT.find(".action.#{slot}").removeClass('hidden')
      hide: () -> #$ROOT.find(".action.#{slot}").addClass('hidden')
      setActive: (bool) ->
        $ROOT.find(".action.#{slot}").removeClass('active') if not bool
        $ROOT.find(".action.#{slot}").addClass('active') if bool
      setState: (bool) -> @setActive bool
      enable: (bool=true) ->
        # If it is a button, set the disabled attribute, otherwise find the
        # parent list item and set disabled on that.
        if $ROOT.find(".action.#{slot}").is('.btn')
          $ROOT.find(".action.#{slot}").attr('disabled', 'disabled') if !bool
          $ROOT.find(".action.#{slot}").removeAttr('disabled') if bool
        else
          $ROOT.find(".action.#{slot}").parent().addClass('disabled') if !bool
          $ROOT.find(".action.#{slot}").parent().removeClass('disabled') if bool
      disable: () -> @enable(false)
      setActiveButton: (a, b) ->
        console && console.log "#{slot} TODO:SETACTIVEBUTTON:", a, b
      focus: (a) ->
        console && console.log "#{slot} TODO:FOCUS:", a
      foreground: (a) ->
        console && console.log "#{slot} TODO:FOREGROUND:", a
    return new ItemRelay()


  # Store `{ actionName: action() }` object so we can bind all the clicks when we init the plugin
  adoptedActions = {}

  # Delegate toolbar actions once all the plugins have initialized and called `UI.adopt`
  Aloha.bind 'aloha-ready', (event, editable) ->
    jQuery.each adoptedActions, (slot, settings) ->

      selector = ".action.#{slot}"
      $ROOT.on 'click', selector, (evt) ->
        evt.preventDefault()
        Aloha.activeEditable = Aloha.activeEditable or squirreledEditable
        # The Table plugin requires this.element to work so it can pop open a
        # window that selects the number of rows and columns
        # Also, that's the reason for the bind(@)
        $target = jQuery(evt.target)
        if not ($target.is(':disabled') or $target.parent().is('.disabled'))
          @element = @
          settings.click.bind(@)(evt)
      if settings.preview
        $ROOT.on 'mouseenter', selector, (evt) ->
          $target = jQuery(evt.target)
          if not ($target.is(':disabled') or $target.parent().is('.disabled'))
            settings.preview.bind(@)(evt)
      if settings.unpreview
        $ROOT.on 'mouseleave', selector, (evt) ->
          $target = jQuery(evt.target)
          if not ($target.is(':disabled') or $target.parent().is('.disabled'))
            settings.unpreview.bind(@)(evt)

  formats = {}

  buildMenu = (options, selected) ->
    $container = $ROOT.find('.headings ul')
    $container.empty()
    for tag, label of options
      $container.append("<li><a href=\"#\" class=\"action changeHeading\" data-tagname=\"#{tag}\">#{label}</a></li>")
    $ROOT.find('.headings .currentHeading').text(formats[selected])

  ###
   register the plugin with unique name
  ###
  Plugin.create "toolbar",
    defaults: {
      defaultFormat: 'p'
      formats:
        'p':  'Normal Text'
        'h1': 'Heading'
        'h2': 'Subheading'
        'h3': 'SubSubHeading'
    }
    init: ->
      toolbar = @
      formats = @settings.formats
      jQuery.extend(toolbar.settings, @defaults)

      changeHeading = (evt) ->
        evt.preventDefault()
        $el = jQuery(@)
        hTag = $el.attr('data-tagname')
        rangeObject = Aloha.Selection.getRangeObject()
        GENTICS.Utils.Dom.extendToWord rangeObject  if rangeObject.isCollapsed()

        Aloha.Selection.changeMarkupOnSelection Aloha.jQuery("<#{hTag}></#{hTag}>")
        # Change the label for the Heading button to match the newly selected formatting
        jQuery('.currentHeading')[0].innerHTML = $el[0].innerHTML
        # Attach the id and classes back onto the new element
        $oldEl = Aloha.jQuery(rangeObject.getCommonAncestorContainer())
        $newEl = Aloha.jQuery(Aloha.Selection.getRangeObject().getCommonAncestorContainer())
        $newEl.addClass($oldEl.attr('class'))
        
        # $newEl.attr('id', $oldEl.attr('id))
        # Setting the id is commented because otherwise collaboration wouldn't register a change in the document

        #### start temporary copy paste code
        if $newEl.not('h1,h2,h3') && $newEl.children('.copy').length
          $newEl.children('.copy').remove()

      copyButton = '<i class="icon-file copy btn aloha-ephemera" style="float: right; padding: 2px; margin: 0 5px 0 0;" title="copy" contenteditable="false"></i>'

      Aloha.bind 'aloha-editable-created', (e, params) =>

        $editable = params.obj

        # this hack allows clicking on empty headings
        $editable.on 'click', 'h1,h2,h3', ->
          for child in jQuery(@).get(0).childNodes
            if child.nodeName is '#text' && not child.length
              jQuery(@).find('.copy.btn').remove()
              range = new GENTICS.Utils.RangeObject
                startContainer: child
                endContainer: child
                startOffset: 0
                endOffset: 0
              range.select()
              jQuery(@).trigger('mouseover')

        $editable.on 'mouseover', 'h1,h2,h3', ->
          jQuery(@).prepend(copyButton) if not jQuery(@).children('.copy.btn').length
        $editable.on 'mouseout', 'h1,h2,h3', (e) ->
          jQuery(@).find('.copy.btn').remove() if not jQuery(e.toElement).parents('h1,h2,h3').length

        $editable.on 'click', 'h1 > .copy,h2 > .copy,h3 > .copy', ->
          $element = jQuery(@).parent()
          selector = "h1,h2,h3".substr(0, "h1,h2,h3".indexOf($element[0].nodeName.toLowerCase())+2)
          $elements = jQuery(@).parent().nextUntil(selector).andSelf()
          html = ''
          html += jQuery(element).outerHtml() for element in $elements
          Aloha.require ['copy/copy-plugin'], (Copy) ->
            Copy.buffer html
      #### end temporary copy paste code

      $ROOT.on 'click', '.action.changeHeading', changeHeading

      # Stop mousedown events from propagating to aloha's handler, which will
      # cause the editor to deactivate.
      $ROOT.on 'mousedown', ".action", (evt) ->
        evt.stopPropagation()

      Aloha.bind 'aloha-editable-activated', (event, data) ->
        squirreledEditable = data.editable

      PubSub.sub 'aloha.selection.context-change', (data) ->
        el = data.range.commonAncestorContainer

        # Figure out if we are in any particular heading
        parents = $(el).parents().andSelf()
        currentHeading = parents.filter(Object.keys(formats).join(',')).first()
      
        blacklist = []
        parents.filter('[data-format-blacklist]').each ->
          blacklist += jQuery(@).data('formatBlacklist')

        whitelist = []
        parents.filter('[data-format-whitelist]').each ->
          whitelist += jQuery(@).data('formatWhitelist')

        allowedFormats = []
        for tag, label of formats
          if (!blacklist.length || blacklist.indexOf(tag) == -1) && (!whitelist.length || whitelist.indexOf(tag) != -1)
            allowedFormats[tag] = label

        if currentHeading.length
          currentHeading = currentHeading.get(0).tagName.toLowerCase()
        else
          currentHeading = toolbar.settings.defaultFormat

        buildMenu(allowedFormats, currentHeading)

    # Components of which we are the parent (not buttons) will call
    # these when they are activated. Change it into an event so it can
    # be implemented elsewhere.
    childVisible: (childComponent, visible) ->
        # publish an event
        evt = $.Event('aloha.toolbar.childvisible')
        evt.component = childComponent
        evt.visible = visible
        PubSub.pub(evt.type, evt)
    childFocus: (childComponent) ->
        # publish an event
        evt = $.Event('aloha.toolbar.childfocus')
        evt.component = childComponent
        PubSub.pub(evt.type, evt)
    childForeground: (childComponent) ->
        # publish an event
        evt = $.Event('aloha.toolbar.childforeground')
        evt.component = childComponent
        PubSub.pub(evt.type, evt)

    adopt: (slot, type, settings) ->
      # publish an adoption event, if item finds a home, return the
      # constructed component
      evt = $.Event('aloha.toolbar.adopt')
      $.extend(evt,
          params:
              slot: slot,
              type: type,
              settings: settings
          component: null)
      PubSub.pub(evt.type, evt)
      if evt.isDefaultPrevented()
        evt.component.adoptParent(toolbar)
        return evt.component

      adoptedActions[slot] = settings
      return makeItemRelay slot

    ###
     toString method
    ###
    toString: ->
      "toolbar"
