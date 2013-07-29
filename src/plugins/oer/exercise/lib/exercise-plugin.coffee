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
            <a class="type" data-toggle="dropdown"></a>
            <ul class="dropdown-menu">
                <li><a href="">Exercise</a></li>
                <li><a href="">Homework</a></li>
                <li><a href="">Problem</a></li>
                <li><a href="">Question</a></li>
                <li><a href="">Task</a></li>
            </ul>
        </div>
    '''
    SOLUTION_TYPE_CONTAINER = '''
        <div class="type-container dropdown aloha-ephemera">
            <a class="type" data-toggle="dropdown"></a>
            <ul class="dropdown-menu">
                <li><a href="">Answer</a></li>
                <li><a href="">Solution</a></li>
            </ul>
        </div>
    '''

    activateExercise = ($element) ->
      type = $element.attr('data-type') or 'exercise'

      $problem = $element.children('.problem')
      $solutions = $element.children('.solution')

      $element.children().remove()

      $typeContainer = jQuery(TYPE_CONTAINER)
      $typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1) )

      $typeContainer.find('.dropdown-menu li').each (i, li) =>
        if jQuery(li).children('a').text().toLowerCase() == type
          jQuery(li).addClass('checked')

      $typeContainer.prependTo($element)

      $problem
        .attr('placeholder', "Type the text of your problem here.")
        .appendTo($element)
        .addClass('aloha-block-dropzone')
        .aloha()

      jQuery('<div>')
        .addClass('solutions')
        .addClass('aloha-ephemera-wrapper')
        .appendTo($element)
        .append($solutions)

      jQuery('<div>')
        .addClass('solution-controls')
        .addClass('aloha-ephemera')
        .append('<a class="add-solution">Click here to add an answer/solution</a>')
        .append('<a class="solution-toggle">show solution</a>')
        .appendTo($element)

      if not $solutions.length
        $element.children('.solution-controls').children('.solution-toggle').hide()

    deactivateExercise = ($element) ->
      $problem = $element.children('.problem')
      $solutions = $element.children('.solution')
      
      if $problem.html() == '' or $problem.html() == '<p></p>'
        $problem.html('&nbsp;')

      $element.children().remove()

      jQuery("<div>").addClass('problem').html(
        jQuery('<p>').append($problem.html())
      ).appendTo($element)

      $element.append($solutions)

    activateSolution = ($element) ->
      type = $element.attr('data-type') or 'solution'

      $body = $element.children()
      $element.children().remove()

      $typeContainer = jQuery(SOLUTION_TYPE_CONTAINER)
      $typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1) )

      $typeContainer.find('.dropdown-menu li').each (i, li) =>
        if jQuery(li).children('a').text().toLowerCase() == type
          jQuery(li).addClass('checked')

      $typeContainer.prependTo($element)

      jQuery('<div>')
        .addClass('body')
        .appendTo($element)
        .aloha()
        .append($body)
        .addClass('aloha-block-dropzone')

    deactivateSolution = ($element) ->
      content = $element.children('.body').html()
      $element.children().remove()
      jQuery('<p>').append(content).appendTo($element)
    

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

      selector: '.exercise,.solution' #this plugin handles both exercises and solutions
      init: () ->

        semanticBlock.register(this)
 
        UI.adopt 'insertExercise', Button,
          click: -> semanticBlock.insertAtCursor(TEMPLATE)

        semanticBlock.registerEvent('click', '.exercise .solution-controls a.add-solution', () ->
          exercise = $(this).parents('.exercise').first()
          controls = exercise.children('.solution-controls')

          controls.children('.solution-toggle').text('hide solution').show()

          semanticBlock.appendElement($(SOLUTION_TEMPLATE), exercise.children('.solutions'))
        )
        semanticBlock.registerEvent('click', '.exercise .solution-controls a.solution-toggle', () ->
          exercise = $(this).parents('.exercise').first()
          controls = exercise.children('.solution-controls')
          solutions = exercise.children('.solutions')

          solutions.slideToggle ->
            if solutions.is(':visible')
              controls.children('.solution-toggle').text('hide solution')
            else
              controls.children('.solution-toggle').text('show solution')
          
        )
        semanticBlock.registerEvent('click', '.exercise .semantic-delete', () ->
          exercise = $(this).parents('.exercise').first()
          controls = exercise.children('.solution-controls')
          controls.children('.add-solution').show()
          controls.children('.solution-toggle').hide() if exercise.children('.solutions').children().length == 1
        )
        semanticBlock.registerEvent('click', '.aloha-oer-block.solution > .type-container > ul > li > a,
                                              .aloha-oer-block.exercise > .type-container > ul > li > a', (e) ->
          e.preventDefault()
          jQuery(this).parents('.type-container').first().children('.type').text jQuery(this).text()
          jQuery(this).parents('.aloha-oer-block').first().attr 'data-type', jQuery(this).text().toLowerCase()

          jQuery(this).parents('.type-container').find('.dropdown-menu li').each (i, li) =>
            jQuery(li).removeClass('checked')
            if jQuery(li).children('a').text() == jQuery(this).text()
              jQuery(li).addClass('checked')
        )
    })
