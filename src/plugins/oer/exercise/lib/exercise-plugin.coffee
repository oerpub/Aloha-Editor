define [
	'aloha'
	'aloha/plugin'
	'jquery'
	'aloha/ephemera'
	'ui/ui'
	'ui/button'
    'semanticblock/semanticblock-plugin'
    'css!exercise/css/exercise-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

    TEMPLATE = '''
        <div class="exercise">
            <div class="problem"></div>
        </div>
	'''
    SOLUTION_TEMPLATE = '''
        <div class="solution">
        </div>
	'''
    TYPE_CONTAINER = '''
        <div class="type-container dropdown aloha-ephemera">
            <span class="type btn-link" data-toggle="dropdown"></span>
            <ul class="dropdown-menu">
                <li><span class="btn-link" data-type="">Exercise</span></li>
                <li><span class="btn-link" data-type="homework">Homework</span></li>
                <li><span class="btn-link" data-type="problem">Problem</span></li>
                <li><span class="btn-link" data-type="question">Question</span></li>
                <li><span class="btn-link" data-type="task">Task</span></li>
                <li><span class="btn-link" data-type="Worked Example">Worked Example</span></li>
            </ul>
        </div>
    '''
    SOLUTION_TYPE_CONTAINER = '''
        <div class="type-container dropdown aloha-ephemera">
            <span class="type btn-link" data-toggle="dropdown"></span>
            <ul class="dropdown-menu">
                <li><span class="btn-link" data-type="answer">Answer</span></li>
                <li><span class="btn-link" data-type="solution">Solution</span></li>
            </ul>
        </div>
    '''

    activateExercise = ($element) ->
      type = $element.attr('data-type') or 'exercise'

      $problem = $element.children('.problem')
      $solutions = $element.children('.solution')

      $element.children().not($problem).remove()

      $typeContainer = jQuery(TYPE_CONTAINER)
      $typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1) )

      $typeContainer.find('.dropdown-menu li').each (i, li) =>
        if jQuery(li).children('span').data('type') == type
          jQuery(li).addClass('checked')

      $typeContainer.prependTo($element)

      $content = $problem.contents()
      $problem
        .empty()
        .addClass('aloha-block-dropzone')
        .attr('placeholder', "Type the text of your problem here.")
        .aloha()
        .append($content)

      jQuery('<div>')
        .addClass('solutions')
        .addClass('aloha-ephemera-wrapper')
        .appendTo($element)
        .append($solutions)

      jQuery('<div>')
        .addClass('solution-controls')
        .addClass('aloha-ephemera')
        .append('<span class="add-solution btn-link">Click here to add an answer/solution</span>')
        .append('<span class="solution-toggle">hide solution</span>')
        .appendTo($element)

      if not $solutions.length
        $element.children('.solution-controls').children('.solution-toggle').hide()

    deactivateExercise = ($element) ->
      return

    activateSolution = ($element) ->
      type = $element.attr('data-type') or 'solution'

      $element.contents()
        .filter((i, child) -> child.nodeType is 3 && child.data.trim().length)
        .wrap('<p></p>')

      $body = ''
      $body = $element.children() if $element.text().trim().length
      
      $element.children().remove()

      $typeContainer = jQuery(SOLUTION_TYPE_CONTAINER)
      $typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1) )

      $typeContainer.find('.dropdown-menu li').each (i, li) =>
        if jQuery(li).children('a').text().toLowerCase() == type
          jQuery(li).addClass('checked')

      $typeContainer.prependTo($element)

      jQuery('<div>')
        .addClass('body')
        .addClass('aloha-block-dropzone')
        .appendTo($element)
        .aloha()
        .append($body)

    deactivateSolution = ($element) ->
      $element.children(':not(.body)').remove()
      $element.children('.body').contents().unwrap()
      $element.children('.body').remove()

      $element.contents()
        .filter((i, child) -> child.nodeType is 3 && child.data.trim().length)
        .wrap('<p></p>')

    Plugin.create('exercise', {
      getLabel: ($element) ->
        if $element.is('.exercise')
          return 'Exercise'
        else if $element.is('.solution')
          return 'Solution'

      activate: ($element) ->
        if $element.is('.exercise')
          activateExercise($element)
        else if $element.is('.solution')
          activateSolution($element)

      deactivate: ($element) ->
        if $element.is('.exercise')
          deactivateExercise($element)
        else if $element.is('.solution')
          deactivateSolution($element)
    
      appendTo: (target) ->
        semanticBlock.appendElement(jQuery(TEMPLATE), target)
        

      selector: '.exercise,.solution' #this plugin handles both exercises and solutions
      ignore: '.problem'

      options: ($el) ->
        if $el.is('.solution')
          return buttons: ['settings']
        return buttons: ['settings', 'copy']

      init: () ->

        semanticBlock.register(this)
 
        UI.adopt 'insertExercise', Button,
          click: -> semanticBlock.insertAtCursor(TEMPLATE)

        semanticBlock.registerEvent('click', '.exercise .solution-controls .add-solution', () ->
          exercise = jQuery(this).parents('.exercise').first()
          controls = exercise.children('.solution-controls')

          controls.children('.solution-toggle').text('hide solution').show()

          semanticBlock.appendElement(jQuery(SOLUTION_TEMPLATE), exercise.children('.solutions'))
        )
        semanticBlock.registerEvent('click', '.exercise .solution-controls .solution-toggle', () ->
          exercise = jQuery(this).parents('.exercise').first()
          controls = exercise.children('.solution-controls')
          solutions = exercise.children('.solutions')

          solutions.slideToggle ->
            if solutions.is(':visible')
              controls.children('.solution-toggle').text('hide solution')
            else
              controls.children('.solution-toggle').text('show solution')

        )
        semanticBlock.registerEvent('click', '.exercise .semantic-delete', () ->
          exercise = jQuery(this).parents('.exercise').first()
          controls = exercise.children('.solution-controls')
          controls.children('.add-solution').show()
          controls.children('.solution-toggle').hide() if exercise.children('.solutions').children().length == 1
        )
        semanticBlock.registerEvent('click', '.aloha-oer-block.solution > .type-container > ul > li > *,
                                              .aloha-oer-block.exercise > .type-container > ul > li > *', (e) ->
          $el = jQuery(@)
          $el.parents('.type-container').first().children('.type').text $el.text()
          $el.parents('.aloha-oer-block').first().attr 'data-type', $el.data('type')

          $el.parents('.type-container').find('.dropdown-menu li').each (i, li) =>
            jQuery(li).removeClass('checked')
          $el.parents('li').first().addClass('checked')
        )
    })
