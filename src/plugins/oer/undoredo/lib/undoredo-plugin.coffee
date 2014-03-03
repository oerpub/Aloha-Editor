define [ 'aloha', 'aloha/plugin', 'jquery', 'ui/ui', 'ui/button', './diff_match_patch_uncompressed' ], (
         Aloha, Plugin, $, Ui, Button) ->
    timestamp = () ->
      new Date().getTime()

    reversePatch = (patch) ->
      reversed = (new diff_match_patch).patch_deepCopy(patch)
      for i in [0..reversed.length-1]
        for j in [0..reversed[i].diffs.length-1]
          reversed[i].diffs[j][0] = -(reversed[i].diffs[j][0])
      return reversed

    Differ = new diff_match_patch()

    Plugin.create 'undoredo',
      _text_observer: null
      _mutations: []
      _patches: []
      _ptr: 0
      _undobutton: null
      _redobutton: null
      _editable: null

      disable: () ->
        @_text_observer.disconnect()

      enable: (editable) ->
        @_text_observer.takeRecords() # Empty the queue
        @_text_observer.observe editable,
          attributes: false
          childList: false
          characterData: true
          characterDataOldValue: true
          subtree: true

      # This follows to some extent the pattern of the undoManager that will
      # eventually make it into browsers, defined here:
      # 
      transact: (callback, merge) ->
        queue = []
        host = @_editable.obj[0]
        if merge
          ptr = @_ptr-1
        else
          ptr = @_ptr

        add_undo_redo = (undoer, redoer) =>
          if not @_patches[ptr]
            @_patches[ptr] =
              type: 'transaction'
              undo: []
              redo: []
            @_ptr = @_patches.length

          @_patches[ptr].undo.push(undoer)
          @_patches[ptr].redo.push(redoer)

        @disable() # Stop watching textual changes while recording a transation
        observer = new MutationObserver (mutations) =>
          for mutation in mutations
            # Mutations can add nodes, remove nodes, and modify text. For each
            # observed mutation, build commands that will undo or redo the
            # effect
            if mutation.type == 'childList'

                # Mutator that adds the nodes
                expander = () ->
                  if @before
                    $(@before).after(@nodes)
                  else if @after
                    $(@after).before(@nodes)
                  else
                    $(@target).append(@nodes)
                  $(@target).trigger $.Event('undoredo', nodes: @nodes)

                reducer = () ->
                    $(@nodes).remove()

                if mutation.addedNodes.length
                  undo = reducer.bind
                    nodes: mutation.addedNodes
                  redo = expander.bind
                    before: mutation.previousSibling
                    after: mutation.nextSibling
                    target: mutation.target
                    nodes: mutation.addedNodes
                  add_undo_redo(undo, redo)

                if mutation.removedNodes.length
                  undo = expander.bind
                    before: mutation.previousSibling
                    after: mutation.nextSibling
                    target: mutation.target
                    nodes: mutation.removedNodes
                 redo = reducer.bind
                    nodes: mutation.removedNodes
                  add_undo_redo(undo, redo)

            else if mutation.type == 'characterData'
              currentValue = mutation.target.data
              oldValue = mutation.oldValue

              # Create mutators
              mutator = () ->
                @target.data = @value

              # Build an undoer
              undoer = mutator.bind
                target: mutation.target
                value: oldValue

              # Build a redoer
              redoer = mutator.bind
                target: mutation.target
                value: currentValue

              if not @_patches[ptr]
                @_patches[ptr] =
                  type: 'transaction'
                  undo: []
                  redo: []

              add_undo_redo(undoer, redoer)

            # Execute things pushed onto the queue. This is used among others
            # to disconnect() the observer as soon as possible, while not
            # disconnecting it so soon that mutations aren't observed at all.
            while listener = queue.shift()
              listener()

        # Observe the editable area
        observer.observe host,
          attributes: false
          childList: true
          characterData: true
          characterDataOldValue: true
          subtree: true

        # Make the changes
        if callback
          r = callback()

        # Give the mutations a chance to propagate before disconnecting.
        queue.push observer.disconnect.bind(observer)

        @enable(host)

        # return original result
        return r

      init: () ->
        plugin = @
        Aloha.bind 'aloha-editable-created', (evt, editable) ->

          # Only root editable. Make this configurable!
          return if not editable.obj.is('.aloha-root-editable')

          # squirrel editable
          plugin._editable = editable

          # Collect mutations for later processing
          prevts = 0
          prevmu = null
          plugin._text_observer = new MutationObserver (mutations) ->
            ts = timestamp()
            for mutation in mutations
              if plugin._ptr > 0 and prevmu and prevmu.target == mutation.target and ts - prevts < 1500
                # Merge change with the previous one, as it is to the same
                # target within a short time span.
                diff = Differ.patch_make(prevmu.oldValue, mutation.target.data)
                plugin._patches[plugin._ptr-1] = {
                  type: 'text'
                  target: mutation.target
                  diff: diff
                }
              else
                # Either a different target, or too much time has passed.
                diff = Differ.patch_make(mutation.oldValue, mutation.target.data)
                plugin._patches[plugin._ptr] = {
                  type: 'text'
                  target: mutation.target
                  diff: diff
                }
                plugin._ptr = plugin._patches.length
                prevmu = mutation

              prevts = ts

          plugin.enable(editable.obj[0])
          plugin.reset(editable)

        Aloha.bind 'aloha-editable-destroyed', () ->
          plugin.disable()

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

      undo: () ->
        if @_ptr > 0
          p = @_patches[@_ptr-1]
          @disable()
          try
            if p.type == 'text'
              diff = reversePatch(p.diff)
              p.target.data = Differ.patch_apply(diff, p.target.data)[0]
            else if p.type == 'transaction'
              for u in p.undo
                u()
          finally
            @enable(@_editable.obj[0])
          @_ptr--
        return @_ptr

      redo: () ->
        if @_ptr < @_patches.length
          p = @_patches[@_ptr]
          @disable()
          try
            if p.type == 'text'
              p.target.data = Differ.patch_apply(p.diff, p.target.data)[0]
            else if p.type == 'transaction'
              for r in p.redo
                r()
          finally
            @enable(@_editable.obj[0])
          @_ptr++
        return @_ptr

      reset: (editable) ->
        @_patches = []
        @_ptr = 0
