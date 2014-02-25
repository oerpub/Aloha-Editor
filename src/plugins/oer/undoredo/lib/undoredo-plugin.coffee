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
          diff = reversePatch(p.diff)
          @disable()
          p.target.data = Differ.patch_apply(diff, p.target.data)[0]
          @enable(@_editable.obj[0])
          @_ptr--
        return @_ptr

      redo: () ->
        if @_ptr < @_patches.length
          p = @_patches[@_ptr]
          @disable()
          p.target.data = Differ.patch_apply(p.diff, p.target.data)[0]
          @enable(@_editable.obj[0])
          @_ptr++
        return @_ptr

      reset: (editable) ->
        @_patches = []
        @_ptr = 0
