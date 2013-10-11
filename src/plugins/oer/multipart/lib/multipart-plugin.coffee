define [
	'aloha'
	'aloha/plugin'
	'jquery'
	'aloha/ephemera'
	'ui/ui'
	'ui/button'
    'exercise/exercise-plugin'
    'semanticblock/semanticblock-plugin'
    'css!multipart/css/multipart-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, Exercise, semanticBlock) ->

    TEMPLATE = '''
        <div class="multipart">
            <div class="body"></div>
        </div>
	'''
    TYPE_CONTAINER = '''
        <div class="type-container dropdown aloha-ephemera">
            <span class="type btn-link" data-toggle="dropdown"></span>
            <ul class="dropdown-menu">
                <li><span class="btn-link" data-type="Worked Example">Worked Example</span></li>
                <li><span class="btn-link" data-type="homework">Homework</span></li>
                <li><span class="btn-link" data-type="exercise">Exercise</span></li>
            </ul>
        </div>
    '''

    activate = ($element) ->
      type = $element.attr('data-type') or 'Worked Example'

      $typeContainer = jQuery(TYPE_CONTAINER)
      $typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1) )

      $typeContainer.find('.dropdown-menu li').each (i, li) =>
        if jQuery(li).children('span').data('type') == type
          jQuery(li).addClass('checked')


      $header = $element.children('.header')

      $content = $header.contents()
      $header
        .empty()
        .addClass('aloha-block-dropzone')
        .attr('placeholder', "Type the text of your header here.")
        .aloha()
        .append($content)
      
      $typeContainer.prependTo($element)

      jQuery('<div>')
        .addClass('exercise-controls')
        .addClass('aloha-ephemera')
        .append('<span class="add-exercise btn-link">Click here to add a part</span>')
        .appendTo($element)

    deactivate = ($element) ->
      return

    Plugin.create('multipart', {
      getLabel: ($element) ->
        return 'multipart'

      activate: activate
      deactivate: deactivate
      selector: '.multipart,.problemset'
      ignore: '.multipart > .header,.problemset > .header'
      init: () ->
        multipart = @

        semanticBlock.register(this)
 
        UI.adopt 'insertMultipart', Button,
          click: -> semanticBlock.insertAtCursor(TEMPLATE)

        semanticBlock.registerEvent('click', '.multipart .exercise-controls .add-exercise,
                                              .problemset .exercise-controls .add-exercise', ->

          parent = jQuery(@).parents(multipart.selector).first()
          console.log(multipart.selector, parent)
          Exercise.appendTo(parent)
          jQuery(this).parents('.exercise-controls').appendTo(parent)
        )
        semanticBlock.registerEvent('click', '.multipart > .type-container > ul > li > *,
                                              .problemset > .type-container > ul > li > *', (e) ->
          $el = jQuery(@)
          $el.parents('.type-container').first().children('.type').text $el.text()
          $el.parents('.aloha-oer-block').first().attr 'data-type', $el.data('type')
        
          $el.parents('aloha-oer-block').first().children('.exercise').each ->
            jQuery(@).attr 'data-type', $el.data('type')

          $el.parents('.type-container').find('.dropdown-menu li').each (i, li) =>
            jQuery(li).removeClass('checked')
          $el.parents('li').first().addClass('checked')
        )
    })
