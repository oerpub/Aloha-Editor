define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'semanticblock/semanticblock-plugin'
  'css!note/css/note-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

  TYPE_CONTAINER = jQuery '''
      <span class="type-container dropdown aloha-ephemera">
          <span class="type btn-link" data-toggle="dropdown"></span>
          <ul class="dropdown-menu">
          </ul>
      </span>
  '''

  # Find all classes that could mean something is "notish"
  # so they can be removed when the type is changed from the dropdown.
  notishClasses = {}
  types = []

  Plugin.create 'note',
    # Default Settings
    # -------
    # The plugin can listen to various classes that should "behave" like a note.
    # For each notish element provide a:
    # - `label`: **Required** Shows up in dropdown
    # - `cls` :  **Required** The classname to enable this plugin on
    # - `hasTitle`: **Required** `true` if the element allows optional titles
    # - `type`: value in the `data-type` attribute.
    # - `tagName`: Default: `div`. The HTML element name to use when creating a new note
    # - `titleTagName`: Default: `div`. The HTML element name to use when creating a new title
    #
    # For example, a Warning could look like this:
    #
    #     { label:'Warning', cls:'note', hasTitle:false, type:'warning'}
    #
    # Then, when the user selects "Warning" from the dropdown the element's
    # class and type will be changed and its `> .title` will be removed.
    defaults: [
      { label: 'Note', cls: 'note', hasTitle: true }
    ]
    getLabel: ($element) ->
      for type in types
        if $element.is(type.selector)
          return type.label
      
    activate: ($element) ->
      $element.attr('data-format-whitelist', '["p"]')
      Ephemera.markAttr($element, 'data-format-whitelist')

      $title = $element.children('.title')
      $title.attr('hover-placeholder', 'Add a title (optional)')
      $title.aloha()

      label = 'Note'

      $body = $element.contents().not($title)

      jQuery.each types, (i, type) =>
        if $element.is(type.selector)
       
          label = type.label
       
          typeContainer = TYPE_CONTAINER.clone()
          # Add dropdown elements for each possible type
          if types.length > 1
            jQuery.each types, (i, dropType) =>
              $option = jQuery('<li><span class="btn-link"></span></li>')
              $option.appendTo(typeContainer.find('.dropdown-menu'))
              $option = $option.children('span')
              $option.text(dropType.label)
              typeContainer.find('.type').on 'click', =>
                jQuery.each types, (i, dropType) =>
                  if $element.attr('data-type') == dropType.type
                    typeContainer.find('.dropdown-menu li').each (i, li) =>
                      jQuery(li).removeClass('checked')
                      if jQuery(li).children('span').text() == dropType.label
                        jQuery(li).addClass('checked')

              $option.on 'click', () =>
                # Remove the title if this type does not have one
                if dropType.hasTitle
                  # If there is no `.title` element then add one in and enable it as an Aloha block
                  if not $element.children('.title')[0]
                    $newTitle = jQuery("<#{dropType.titleTagName or 'span'} class='title'></#{dropType.titleTagName or 'span'}")
                    $element.append($newTitle)
                    $newTitle.aloha()

                else
                  $element.children('.title').remove()

                # Remove the `data-type` if this type does not have one
                if dropType.type
                  $element.attr('data-type', dropType.type)
                else
                  $element.removeAttr('data-type')

                typeContainer.find('.type').text(dropType.label)

                # Remove all notish class names and then add this one in
                for key of notishClasses
                  $element.removeClass key
                $element.addClass(dropType.cls)
          else
            typeContainer.find('.dropdown-menu').remove()
            typeContainer.find('.type').removeAttr('data-toggle')
       
          typeContainer.find('.type').text(type.label)
          typeContainer.prependTo($element)
 
      # Create the body and add some placeholder text
      $body = jQuery('<div>')
        .addClass('body')
        .addClass('aloha-block-dropzone')
        .attr('placeholder', "Type the text of your #{label.toLowerCase()} here.")
        .appendTo($element)
        .aloha()
        .append($body)
     
    deactivate: ($element) ->
      $body = $element.children('.body')
      # The body div could just contain text children.
      # If so, we need to wrap them in a `p` element
      for element in $body.contents()
        if element.nodeName == '#text'
          if element.data.trim().length
            jQuery(element).wrap('<p></p>')
          else
            element.remove()
      $body = $body.contents()

      $element.children('.body').remove()
      
      # this is kind of awkward. we want to process the title if our current
      # type is configured to have a title, OR if the current type is not 
      # recognized we process the title if its there
      hasTitle = undefined
      titleTag = 'span'

      jQuery.each types, (i, type) =>
        if $element.is(type.selector)
          hasTitle = type.hasTitle || false
          titleTag = type.titleTagName || titleTag

      if hasTitle or hasTitle == undefined
        $titleElement = $element.children('.title')
        $title = jQuery("<#{titleTag} class=\"title\"></#{titleTag}>")
       
        if $titleElement.length
          $title.append($titleElement.contents())
          $titleElement.remove()
       
        $title.prependTo($element)

      $element.append($body)

    selector: '.note'
    init: () ->
      # Load up specific classes to listen to or use the default
      types = @settings
      jQuery.each types, (i, type) =>
        className = type.cls or throw 'BUG Invalid configuration of note plugin. cls required!'
        typeName = type.type
        hasTitle = !!type.hasTitle
        label = type.label or throw 'BUG Invalid configuration of note plugin. label required!'

        # These 2 variables allow other note-ish classes
        # to define what the element name is that is generated for the note and
        # for the title.
        #
        # Maybe they could eventually be functions so titles for inline notes generate
        # a `span` instead of a `div` for example.
        tagName = type.tagName or 'div'
        titleTagName = type.titleTagName or 'div'

        if typeName
          type.selector = ".#{className}[data-type='#{typeName}']"
        else
          type.selector = ".#{className}:not([data-type])"

        notishClasses[className] = true

        newTemplate = jQuery("<#{tagName}></#{tagName}")
        newTemplate.addClass(className)
        newTemplate.attr('data-type', typeName) if typeName
        if hasTitle
          newTemplate.append("<#{titleTagName} class='title'></#{titleTagName}")

        # Add a listener
        UI.adopt "insert-#{className}#{typeName}", Button,
          click: -> semanticBlock.insertAtCursor(newTemplate.clone())

        # For legacy toolbars listen to 'insertNote'
        if 'note' == className and not typeName
          UI.adopt "insertNote", Button,
            click: -> semanticBlock.insertAtCursor(newTemplate.clone())

      semanticBlock.register(this)
