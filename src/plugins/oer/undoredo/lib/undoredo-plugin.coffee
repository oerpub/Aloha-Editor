define [ 'aloha', 'aloha/plugin', 'jquery', 'ui/ui', 'ui/button', './xpath' ], (
         Aloha, Plugin, $, Ui, Button, XPath) ->
    Plugin.create 'undoredo',
      _observer: null
      _mutations: []
      _versions: []
      _ptr: 0
      _undobutton: null
      _redobutton: null
      _editable: null

      disable: () ->
        @_observer.disconnect()

      enable: (editable) ->
        @_observer.takeRecords() # Empty the queue
        @_observer.observe editable,
          attributes: false
          childList: true
          characterData: true
          subtree: true

      addVersion: (node) ->
        # Create a fragment to store the node
        f = document.createDocumentFragment()
        f.appendChild node.cloneNode(true)

        # Truncate the versions stack at our present working point, thereby
        # creating a new timeline if a new version is added after an undo.
        @_versions.length = @_ptr
        @_versions.push
          xpath: XPath.xpathFor(node)
          fragment: f

        # If timeline is too long, chop off the head. Limit to keeping ten
        # fragments to conserve memory use. Worst case scenario, we might have
        # up to ten copies of the whole document stored here.
        if @_versions.length > 10
          @_versions.shift()

        # Store new location in timeline
        @_ptr = @_versions.length

      init: () ->
        plugin = @

        Aloha.bind 'aloha-editable-created', (evt, editable) ->

          # Only root editable. Make this configurable!
          return if not editable.obj.is('.aloha-root-editable')

          # Turn on the undoManager on the editable. This has no effect
          # on browsers that don't support it.
          editable.obj[0].undoScope = true

          # squirrel editable
          plugin._editable = editable

          ## Collect mutations for later processing
          #plugin._observer = new MutationObserver (mutations) ->
          #  # Append to list of mutations
          #  if mutations.length
          #    plugin._mutations = plugin._mutations.concat(mutations)

          #plugin.enable(editable.obj[0])
          #plugin.reset(editable)

        # Once editor or plugin signals a change, process the mutations
        #Aloha.bind 'aloha-smart-content-changed', (e, data) -> plugin.process(data)

        #Aloha.bind 'aloha-editable-destroyed', () ->
        #  plugin.disable()

        # Register buttons
        @_undobutton = Ui.adopt "undo", Button,
          tooltip: "Undo",
          icon: "aloha-icon aloha-icon-undo",
          scope: 'Aloha.continuoustext',
          click: () => @undo()

        @_redobutton = Ui.adopt "redo", Button,
          tooltip: "Redo",
          icon: "aloha-icon aloha-icon-redo",
          scope: 'Aloha.continuoustext',
          click: () => @redo()

      process: (data) ->
        # Only root editable. Make this configurable!
        editable = data.editable
        return if not editable.obj.is('.aloha-root-editable')

        console.log(data.triggerType, data.keyCode, data.keyIdentifier)
        # Ignore mutations disconnected from this editable
        mutations = @_mutations.filter (m) ->
          editable.obj.is(m.target) or editable.obj.has(m.target).length

        if mutations.length
          # find the top-most target.
          top = mutations[0].target
          for mutation in mutations.slice(1)
            while top.parentElement and top != mutation.target and \
                not $(top).has(mutation.target).length
              top = top.parentElement

          # Keep a copy of this element, so we can restore it later.
          @addVersion(top)

          # Clear list of mutations
          @_mutations = []

      restore: (v) ->
        # Find the node, and replace it with the old version
        node = XPath.nodeFor(v.xpath)
        if node
          @disable
          $(node).empty().append(v.fragment.firstChild.cloneNode(true).childNodes)
          $(node).focus()
          @enable(@_editable.obj[0])

      undo: () ->
        @_editable.obj[0].undoManager.undo()
        #@process(editable: @_editable)
        #if @_ptr > 1
        #  @_ptr--
        #  v = @_versions[@_ptr-1]
        #  @restore(v)
        #return @_ptr

      redo: () ->
        @_editable.obj[0].undoManager.redo()
        #@process(editable: @_editable)
        #if @_ptr < @_versions.length
        #  @_ptr++
        #  v = @_versions[@_ptr-1]
        #  @restore(v)
        #return @_ptr

      reset: (editable) ->
        @_ptr = 0
        @addVersion(editable?.obj[0] or @_editable.obj[0])
