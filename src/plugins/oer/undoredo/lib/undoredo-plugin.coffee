define [ 'aloha', 'aloha/plugin', 'jquery', 'aloha/ephemera', './xpath' ], (Aloha, Plugin, $, Ephemera, XPath) ->
    timestamp = () ->
      return (new Date()).getTime()

    intersection = (a, b) ->
      if b.length > a.length
        # indexOf to loop over shorter array
        t=b
        b=a
        a=t
      return Array.prototype.filter.call a, (i) ->
        Array.prototype.indexOf.call(b, i) != -1

    Plugin.create 'undoredo',
      _observer: null
      _mutations: []
      _versions: []
      _ptr: 0

      disable: () ->
        @_observer.disconnect()

      enable: (editable) ->
        @_observer.takeRecords() # Empty the queue
        @_observer.observe editable,
          attributes: false
          childList: true
          characterData: true
          characterDataOldValue: true
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
        @_ptr++

      init: () ->
        plugin = @

        Aloha.bind 'aloha-editable-created', (evt, editable) ->

          # Only root editable
          return if not editable.obj.is('.aloha-root-editable')

          # Get registered ephemera
          emap = Ephemera.ephemera().classMap
          ephemera_selector = (Object.keys(emap).map (c)->'.'+c).join(',')

          timeoutID = null

          plugin._observer = new MutationObserver (mutations) ->
            console.log('Mutations to', mutations)
 
            # Remove mutations to ephemera
            mutations = mutations.filter (m) -> not $(m.target).is(ephemera_selector)

            # Append to list of mutations
            if mutations.length
              plugin._mutations = plugin._mutations.concat(mutations)

              # Wait two seconds for more, then process
              if timeoutID
                clearTimeout(timeoutID)
              timeoutID = setTimeout(
                () ->
                  timeoutID = null

                  if plugin._mutations.length
                    # find the top-most target.
                    top = plugin._mutations[0].target
                    for mutation in plugin._mutations.slice(1)
                      while top and top != mutation.target and \
                          not $(top).has(mutation.target).length
                        top = top.parentElement

                    # Keep a copy of this element, so we can restore it later.
                    plugin.addVersion(top)

                    # Clear list of mutations
                    plugin._mutations = []
              , 2000)
          plugin.enable(editable.obj[0])

        Aloha.bind 'aloha-editable-destroyed', () ->
          @disable()

      restore: (v) ->
        # Find the node, and replace it with the old version
        node = XPath.nodeFor(v.xpath)
        if node
          @disable
          $(node).empty().append(v.fragment.firstChild.cloneNode(true).childNodes)
          @enable(Aloha.activeEditable.obj[0])

      undo: () ->
        if @_ptr > 1
          @_ptr--
          v = @_versions[@_ptr-1]
          @restore(v)
        return @_ptr

      redo: () ->
        if @_ptr < @_versions.length
          @_ptr++
          v = @_versions[@_ptr-1]
          @restore(v)
        return @_ptr

      reset: () ->
        @_ptr = 0
        @addVersion(Aloha.activeEditable.obj[0])
