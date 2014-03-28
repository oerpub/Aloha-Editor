define ['aloha', 'jquery', 'aloha/plugin', 'ui/ui', 'ui/button',
    'css!workarea/css/workarea.css'], (Aloha, $, Plugin, Ui, Button) ->

  GENTICS = window.GENTICS;
  Plugin.create 'workarea',
    init: () ->
      @_button = Ui.adopt 'insertWorkArea', Button,
        tooltip: 'Insert Work Area'
        icon: 'aloha-icon-workarea'
        scope: 'Aloha.continuoustext'
        click: () ->
          range = Aloha.Selection.getRangeObject()
          if Aloha.activeEditable
            el = $('<div class="workarea">')
            GENTICS.Utils.Dom.insertIntoDOM(el, range,
                $(Aloha.activeEditable.obj), true)
            range.select()
