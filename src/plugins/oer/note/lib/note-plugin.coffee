define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'semanticblock/semanticblock-plugin'
  'css!note/css/note-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

  TITLE_CONTAINER = jQuery('''
        <div class="type-container dropdown">
            <a class="type" data-toggle="dropdown"></a>
            <span class="title" placeholder="Add a title (optional)"></span>
            <ul class="dropdown-menu">
            </ul>
        </div>
  ''')

  # Find all classes that could mean something is "notish"
  # so they can be removed when the type is changed from the dropdown.
  notishClasses = {}

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
    init: () ->
      # Load up specific classes to listen to or use the default
      types = @settings
      jQuery.each types, (i, type) =>
        className = type.cls or throw 'BUG Invalid configuration of not plugin. cls required!'
        typeName = type.type
        hasTitle = !!type.hasTitle
        label = type.label or throw 'BUG Invalid configuration of not plugin. label required!'

        # These 2 variables allow other note-ish classes
        # to define what the element name is that is generated for the note and
        # for the title.
        #
        # Maybe they could eventually be functions so titles for inline notes generate
        # a `span` instead of a `div` for example.
        tagName = type.tagName or 'div'
        titleTagName = type.titleTagName or 'div'

        selector = ".#{className}:not([data-type])"
        selector = ".#{className}[data-type='#{typeName}']" if typeName

        notishClasses[className] = true


        newTemplate = jQuery("<#{tagName}></#{tagName}")
        newTemplate.addClass(className)
        newTemplate.attr('data-type', typeName) if typeName
        if hasTitle
          newTemplate.append("<#{titleTagName} class='title'></#{titleTagName}")

        semanticBlock.activateHandler(selector, (element) =>
          if hasTitle
            titleElement = element.children('.title')

            if titleElement.length
              title = titleElement.html()
              titleElement.remove()
            else
              title = ''

          type = element.attr('data-type') or className

          body = element.children()
          element.children().remove()

          if hasTitle
            titleContainer = TITLE_CONTAINER.clone()
            # Add dropdown elements for each possible type
            jQuery.each @settings, (i, foo) =>
              $option = jQuery('<li><a href=""></a></li>')
              $option.appendTo(titleContainer.find('.dropdown-menu'))
              $option = $option.children('a')
              $option.text(foo.label)
              $option.on 'click', =>
                # Remove the title if this type does not have one
                # The title was moved into `.type-container` for some reason
                if foo.hasTitle
                  # If there is no `.title` element then add one in and enable it as an Aloha block
                  if not element.find('> .type-container > .title')[0]
                    $newTitle = jQuery("<#{foo.titleTagName or 'span'} class='title'></#{foo.titleTagName or 'span'}")
                    element.children('.type-container').append($newTitle)
                    $newTitle.aloha()

                else
                  element.find('> .type-container > .title').remove()

                # Remove the `data-type` if this type does not have one
                if foo.type
                  element.attr('data-type', foo.type)
                else
                  element.removeAttr('data-type')

                # Remove all notish class names and then add this one in
                for key of notishClasses
                  element.removeClass key
                element.addClass(foo.cls)


            titleContainer.find('.title').text(title)
            titleContainer.find('.type').text(label)
            titleContainer.prependTo(element)
            titleContainer.children('.title').aloha()

          # Create the body and add some placeholder text
          $('<div>').addClass('body')
          .attr('placeholder', "Type the text of your #{className} here.")
          .append(body)
          .appendTo(element)
          .aloha()
        )
        semanticBlock.deactivateHandler(selector, (element) ->
          bodyElement = element.children('.body')
          body = bodyElement.children()

          if body == bodyElement.attr('placeholder')
            body = ''

          element.children('.body').remove()

          if hasTitle
            titleElement = element.children('.type-container').children('.title')
            title = titleElement.text()

            if title == titleElement.attr('placeholder')
              title = ''

            element.children('.type-container').remove()
            jQuery("<div>").addClass('title').text(title).prependTo(element)

          element.append(body)
        )
        # Add a listener
        UI.adopt "insert-#{className}#{typeName}", Button,
          click: -> semanticBlock.insertAtCursor(newTemplate.clone())

        # For legacy toolbars listen to 'insertNote'
        if 'note' == className and not typeName
          UI.adopt "insertNote", Button,
            click: -> semanticBlock.insertAtCursor(newTemplate.clone())
