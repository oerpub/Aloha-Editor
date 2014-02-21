define ['aloha', 'block/block', 'block/blockmanager', 'aloha/plugin', 'aloha/pluginmanager', 'jquery', 'aloha/ephemera', 'ui/ui', 'ui/button', 'copy/copy-plugin', 'css!semanticblock/css/semanticblock-plugin.css'], (Aloha, Block, BlockManager, Plugin, pluginManager, jQuery, Ephemera, UI, Button, Copy) ->

  # hack to accomodate multiple executions
  return pluginManager.plugins.semanticblock  if pluginManager.plugins.semanticblock

  semanticBlock = Block.AbstractBlock.extend
    shouldDestroy: -> false # this stops aloha from destroying our blocks all willy nilly

  BlockManager.registerBlockType 'semanticBlock', semanticBlock

  DIALOG_HTML = '''
    <div class="semantic-settings modal hide" id="linkModal" tabindex="-1" role="dialog" aria-hidden="true" data-backdrop="false">
      <div class="modal-header">
        <h3></h3>
      </div>
      <div class="modal-body">
        <div style="margin: 20px 10px 20px 10px; padding: 10px; border: 1px solid grey;">
            <strong>Custom class</strong>
            <p>
                Give this element a custom "class". Nothing obvious will change in your document.
                This is for advanced book styling and requires support from the publishing system.
            </p> 
            <input type="text" placeholder="custom element class" name="custom_class">
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary action submit">Save changes</button>
        <button class="btn action cancel">Cancel</button>
      </div>
    </div>'''

  blockTemplate = jQuery('<div class="semantic-container aloha-ephemera-wrapper"></div>')
  topControls = jQuery('''
    <div class="semantic-controls-top aloha-ephemera">
      <a class="copy" title="Copy this element"><i class="icon-copy"></i> Copy element</button>
    </div>
  ''')
  blockControls = jQuery('''
    <div class="semantic-controls aloha-ephemera">
      <button class="semantic-delete" title="Remove this element"><i class="icon-remove"></i></button>
      <button class="semantic-settings" title="Advanced options for this element"><i class="icon-cog"></i></button>
    </div>''')
  blockDragHelper = jQuery('''
    <div class="semantic-drag-helper aloha-ephemera">
        <div class="title"></div>
        <div class="body">Drag me to the desired location in the document</div>
    </div>''')
  registeredTypes = []
  copyBuffer = null
  pluginEvents = [
    name: 'mouseenter'
    selector: '.aloha-block-draghandle'
    callback: ->
      jQuery(this).parent('.semantic-container').addClass 'drag-active'
  ,
    name: 'mouseleave'
    selector: '.aloha-block-draghandle'
    callback: ->
      jQuery(this).parent('.semantic-container')
        .removeClass 'drag-active'  unless jQuery(this).parent('.semantic-container').is('.ui-sortable-helper')
  ,
    name: 'mouseenter'
    selector: '.semantic-delete'
    callback: ->
      jQuery(this).parents('.semantic-container').first().addClass 'delete-hover'
  ,
    name: 'mouseleave'
    selector: '.semantic-delete'
    callback: ->
      jQuery(this).parents('.semantic-container').removeClass 'delete-hover'
  ,
    name: 'click'
    selector: '.semantic-container .semantic-delete'
    callback: () ->
      editable = jQuery(@).closest('.aloha-root-editable')
      editable[0].undoManager.transact
        executeAutomatic: () =>
          jQuery(@).parents('.semantic-container').first().remove()
        false
      Aloha.activeEditable.smartContentChange({type: 'block-change'})
  ,
    name: 'click'
    selector: '.semantic-container .semantic-controls-top .copy'
    callback: (e) ->
      # grab the content of the block that was just clicked
      $element = jQuery(this).parents('.semantic-container').first()
      Copy.buffer $element.outerHtml()
  ,
    name: 'mouseover'
    selector: '.semantic-container .semantic-controls-top .copy'
    callback: (e) ->
      # grab the content of the block that was just clicked
      $elements = jQuery(this).parents('.semantic-container')
      $elements.removeClass('copy-preview').first().addClass('copy-preview')
  ,
    name: 'mouseout'
    selector: '.semantic-container .semantic-controls-top .copy'
    callback: (e) ->
      jQuery(this).parents('.semantic-container').removeClass('copy-preview')
  ,
    name: 'click'
    selector: '.semantic-container .semantic-settings'
    callback: (e) ->

      if jQuery('.semantic-settings.modal:visible').length
        return

      dialog = jQuery(DIALOG_HTML)
      dialog.modal 'show'

      # put the dialog in the middle of the window
      dialog.css({'margin-top':(jQuery(window).height()-dialog.height())/2,'top':'0'})

      $element = jQuery(this).parents('.semantic-controls').siblings('.aloha-oer-block')
      elementName = getLabel($element)
      dialog.find('h3').text('Edit options for this ' + elementName)
      dialog.find('[name=custom_class]').val $element.attr('data-class')
      dialog.data 'element', $element
  ,
    name: 'click'
    selector: '.modal.semantic-settings .action.cancel'
    callback: (e) ->
      $dialog = jQuery(this).parents('.modal')
      $dialog.modal 'hide'
  ,
    name: 'click'
    selector: '.modal.semantic-settings .action.submit'
    callback: (e) ->
      $dialog = jQuery(this).parents('.modal')
      $dialog.modal 'hide'
      $element = $dialog.data('element')
      $element.attr 'data-class', $dialog.find('[name=custom_class]').val()
      $element.removeAttr('data-class') if $element.attr('data-class') is ''
  ,
    name: 'mouseover'
    selector: '.semantic-container'
    callback: ->
      jQuery(this).parents('.semantic-container').removeClass('focused')
      jQuery(this).addClass('focused') unless jQuery(this).find('.focused').length
      wrapped = jQuery(this).find('.aloha-oer-block').first()
      label = wrapped.length and blockIdentifier(wrapped)
      jQuery(this).find('.aloha-block-handle').first().attr('title', "Drag this #{label} to another location")
  ,
    name: 'mouseout'
    selector: '.semantic-container'
    callback: ->
      jQuery(this).removeClass('focused')
  ,
    # Toggle a class on elements so if they are empty and have placeholder text
    # the text shows up.
    # See the CSS file more info.
    name: 'blur'
    selector: '[placeholder],[hover-placeholder]'
    callback: ->
      $el = jQuery @
      # If the element does not contain any text (just empty paragraphs)
      # Clear the contents so `:empty` is true
      $el.empty() if not $el.text().trim() and not $el.find('.aloha-oer-block').length
  ]
  insertElement = (element) ->
  
  getType = ($element) ->
    $element = $element.find('.aloha-oer-block').first() if $element.is('.semantic-container')

    for type in registeredTypes
      if $element.is(type.selector)
        return type

  getLabel = ($element) ->
    getType($element)?.getLabel($element)

  blockIdentifier = ($element) ->
    label = getLabel($element)
    if label
      elementName = label.toLowerCase()
    else
      # Show the classes involved, filter out the aloha ones
      classes = (c for c in $element.attr('class').split(/\s+/) when not /^aloha/.test(c))
      elementName = classes.length and "element (class='#{classes.join(' ')}')" or 'element'
	
  activate = ($element) ->
    unless $element.is('.semantic-container') or ($element.is('.alternates') and $element.parents('figure').length)
      $element.addClass 'aloha-oer-block'

      if $element.parent().is('.aloha-editable')
        #add some paragraphs on either side so content can be added there easily
        jQuery('<p class="aloha-oer-ephemera-if-empty"></p>').insertBefore($element)
        jQuery('<p class="aloha-oer-ephemera-if-empty"></p>').insertAfter($element)

      # What kind of block is being activated
      type = getType($element)

      controls = blockControls.clone()
      top = topControls.clone()
      label = blockIdentifier($element)
      controls.find('.semantic-delete').attr('title', "Remove this #{label}")
      controls.find('.semantic-settings').attr('title', "Advanced options for this #{label}")
      top.find('.copy').attr('title', "Copy this #{label}")
      top.find('.copy').contents().last().replaceWith(" Copy #{label}")
      if not type
        $element.wrap(blockTemplate).parent().append(controls).prepend(top).alohaBlock({'aloha-block-type': 'semanticBlock'})
      else
        # Ask `type` plugin about the controls it wants
        if type.options
          if typeof type.options == 'function'
            options = type.options($element)
          else
            options = type.options

          if options.buttons
            # We deliberately don't allow people to drop the delete button. At
            # least until we know whether that is even needed!
            controls.find('button.semantic-settings').remove() if 'settings' not in options.buttons
            top.find('a.copy').remove() if 'copy' not in options.buttons

        $element.wrap(blockTemplate).parent().append(controls).prepend(top).alohaBlock({'aloha-block-type': 'semanticBlock'})

        type.activate $element
        return
 
      # if we make it this far none of the activators have run
      # just make it editable

      # this might could be more efficient
      $element.children('[placeholder],[hover-placeholder]').andSelf().filter('[placeholder],[hover-placeholder]').each ->
        jQuery(@).empty() if not jQuery(@).text().trim()

      # if there is a title, give it a placeholder and make it editable
      $title = $element.children('.title').first()
      $title.attr('hover-placeholder', 'Add a title')
      $title.aloha()

      $body = $element.contents().not($title)

      jQuery('<div>')
        .addClass('body aloha-block-dropzone')
        .appendTo($element)
        .aloha()
        .append($body)

  deactivate = ($element) ->
    $element.removeClass 'aloha-oer-block ui-draggable'
    $element.removeAttr 'style'

    type = getType($element)

    if type
      type.deactivate $element
      return

    # if we make it this far none of the deactivators have run
    $title = $element.children('.title').first()
      .mahalo()
      .removeClass('aloha-editable aloha-block-blocklevel-sortable ui-sortable')
      .removeAttr('hover-placeholder')
      .removeAttr('id') # titles arent special enough to keep their ids

    content = $element.children('.body')
    if content.is(':empty')
      content.remove()
    else
      $element.children('.body').contents().unwrap()
    $element.attr('data-unknown', 'true')

  bindEvents = (element) ->
    return  if element.data('oerBlocksInitialized')
    element.data 'oerBlocksInitialized', true
    event = undefined
    i = undefined
    i = 0
    while i < pluginEvents.length
      event = pluginEvents[i]
      element.on event.name, event.selector, event.callback
      i++

  cleanIds = (content) ->
    elements = content.find('[id]')
    ids = {}

    for i in [0..elements.length]
      element = jQuery(elements[i])
      id = element.attr('id')
      if ids[id]
        element.attr('id', '')
      else
        ids[id] = element

  cleanWhitespace = (content) ->
    content.find('.aloha-oer-ephemera-if-empty').each ->
      $el = jQuery(@)
      if $el.text().trim().length
        $el.removeClass 'aloha-oer-ephemera-if-empty'
      else
        $el.remove()

  Aloha.ready ->
    bindEvents jQuery(document)

  Plugin.create 'semanticblock',

    defaults: {
      defaultSelector: 'div:not(.title,.aloha-oer-block,.aloha-editable,.aloha-block,.aloha-ephemera-wrapper,.aloha-ephemera)'
    }
    makeClean: (content) ->

      content.find('.semantic-container').each ->
        if jQuery(this).children().not('.semantic-controls').length == 0
          jQuery(this).remove()

      content.find(".aloha-oer-block").each ->
        deactivate jQuery(this)

      cleanIds(content)
      cleanWhitespace(content)

    init: ->

      Ephemera.ephemera().pruneFns.push (node) ->
        jQuery(node)
          .removeClass('aloha-block-dropzone aloha-editable-active aloha-editable aloha-block-blocklevel-sortable ui-sortable')
          .removeAttr('contenteditable placeholder')
          .get(0)

      Aloha.bind 'aloha-editable-created', (e, editable) =>
        $root = editable.obj

        classes = []
        classes.push type.selector for type in registeredTypes

        selector = @settings.defaultSelector + ',' + classes.join()

        # theres no really good way to do this. editables get made into sortables
        # on `aloha-editable-created` and there is no event following that, so we 
        # just have to wait
        sortableInterval = setInterval ->
          if $root.data 'sortable'
            clearInterval(sortableInterval)

            if $root.data('disableDropTarget')
              $root.removeClass('aloha-block-blocklevel-sortable aloha-block-dropzone')

            $root.sortable 'option', 'helper', 'clone'

            # FIXME - this binding is gh-book specific
            $root.sortable 'option', 'appendTo', jQuery('#content').parent()

            $root.sortable 'option', 'change', (e, ui) ->
              ui.item.data("disableDrop", ui.placeholder.parent().data('disableDropTarget'))

            $root.sortable 'option', 'stop', (e, ui) ->
              if ui.item.data('disableDrop')
                jQuery(this).sortable("cancel")
                return

              $element = jQuery(ui.item)
              activate $element if $element.is(selector)
              getType($element)?.onDrop?($element)
              $element.removeClass('drag-active')
              editable.smartContentChange({type: 'block-change'})


            $root.sortable 'option', 'placeholder', 'aloha-oer-block-placeholder aloha-ephemera',
          100

        if $root.is('.aloha-root-editable')

          $root.find(selector).each ->
            activate jQuery(@) if not jQuery(@).parents('.semantic-drag-source').length

          # setting up these drag sources may break if there is more than one top level editable on the page
          jQuery('.semantic-drag-source').children().each ->
            element = jQuery(this)
            elementLabel = (element.data('type') or element.attr('class')).split(' ')[0]
            element.draggable
              connectToSortable: $root
              appendTo: jQuery('#content')
              revert: 'invalid'
              helper: ->
                helper = jQuery(blockDragHelper).clone()
                helper.find('.title').text elementLabel
                helper
         
              start: (e, ui) ->
                $root.addClass 'aloha-block-dropzone'
                jQuery(ui.helper).addClass 'dragging'
         
              refreshPositions: true


    insertAtCursor: (template) ->
      $element = jQuery(template)
      range = Aloha.Selection.getRangeObject()
      $element.addClass 'semantic-temp'
      GENTICS.Utils.Dom.insertIntoDOM $element, range, Aloha.activeEditable.obj
      $element = Aloha.jQuery('.semantic-temp').removeClass('semantic-temp')
      activate $element
      Aloha.activeEditable.smartContentChange({type: 'block-change'})

    appendElement: ($element, target) ->
      $element.addClass 'semantic-temp'
      target.append $element
      $element = Aloha.jQuery('.semantic-temp').removeClass('semantic-temp')
      activate $element

    register: (plugin) ->
      registeredTypes.push(plugin)
      @settings.defaultSelector += ':not('+plugin.ignore+')' if plugin.ignore

    registerEvent: (name, selector, callback) ->
      pluginEvents.push
        name: name
        selector: selector
        callback: callback
