define [ 'aloha', 'aloha/plugin', 'jquery', ], (Aloha, Plugin, $) ->
  Aloha.bind 'aloha-editable-created', (evt, editable) ->
    editable.obj.on 'paste', (e) ->
      clipboard = e.clipboardData or e.originalEvent.clipboardData

      # Check for our own internal type, and if it exists, leave it alone,
      # someone else will handle.
      return if clipboard.getData('text/oerpub-content')

      # If html content, fetch it and clean it.
      content = clipboard.getData('text/html')
      if content
        e.preventDefault()

        # This will cause it to run through the contenthandler plugins
        # which will clean it up
        Aloha.execCommand('insertHTML', false, content);
