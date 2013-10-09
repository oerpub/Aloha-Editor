define [ 'jquery', 'aloha', 'aloha/plugin', 'PubSub', 'ui/button' ], (
    jQuery, Aloha, Plugin, PubSub, Button) ->

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
        btn = $ROOT.find(".action.#{slot}")

        # Fire an enable event on btn, allow enable/disable to be customised
        evt = $.Event(bool and 'enable-action' or 'disable-action')
        btn.trigger(evt)
        if evt.isDefaultPrevented()
          return

        # If it is a button, set the disabled attribute, otherwise find the
        # parent list item and set disabled on that.
        if btn.is('.btn')
          if bool
            btn.removeAttr('disabled')
          else
            btn.attr('disabled', 'disabled')
        else
          if bool
            btn.parent().removeClass('disabled')
          else
            btn.parent().addClass('disabled')
      disable: () -> @enable(false)
      setActiveButton: (a, b) ->
        console && console.log "#{slot} TODO:SETACTIVEBUTTON:", a, b
      focus: (a) ->
        console && console.log "#{slot} TODO:FOCUS:", a
      foreground: (a) ->
        console && console.log "#{slot} TODO:FOREGROUND:", a
      flash: () ->
        # Allows a plugin to flash a button, thereby grabbing the user's
        # attention.
        el = $ROOT.find(".action.#{slot}")

        # Fire a flash event on el, allow flashing to be customised
        evt = $.Event('flash-action')
        el.trigger(evt)
        if evt.isDefaultPrevented()
          return

        for i in [1..6] by 1
          setTimeout (() -> el.toggleClass('ui-flash')), 200*i
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
        'p':   'Normal Text'
        'h1':  'Heading'
        'h2':  'Subheading'
        'h3':  'SubSubHeading'
        'pre': 'Code'
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

        # Generate an event, so others can act on heading changes
        e2 = $.Event()
        e2.type = 'change-heading'
        e2.target = $newEl[0]
        $newEl.trigger(e2)
        
        # $newEl.attr('id', $oldEl.attr('id))
        # Setting the id is commented because otherwise collaboration wouldn't register a change in the document

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
