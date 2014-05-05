define [
	'aloha'
	'aloha/plugin'
	'jquery'
	'aloha/ephemera'
	'ui/ui'
	'ui/button'
    'semanticblock/semanticblock-plugin'
    'css!rule/css/rule-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) ->

    TEMPLATE = '''
        <div class="rule">
            <div class="statement"></div>
        </div>
	'''
    PROOF_TEMPLATE = '''
        <div class="proof">
        </div>
	'''
    TYPE_CONTAINER = '''
        <div class="type-container dropdown aloha-ephemera">
            <span class="type-dropdown btn-link" data-toggle="dropdown"><span class="caret"></span></span>
            <ul class="dropdown-menu">
                <li><span class="btn-link" data-label="">Rule</span></li>
                <li><span class="btn-link" data-label="homework">Homework</span></li>
                <li><span class="btn-link" data-label="problem">Problem</span></li>
                <li><span class="btn-link" data-label="question">Question</span></li>
                <li><span class="btn-link" data-label="task">Task</span></li>
                <li><span class="btn-link" data-label="Worked Example">Worked Example</span></li>
            </ul>
        </div>
    '''
    PROOF_TYPE_CONTAINER = '''
        <div class="type-container dropdown aloha-ephemera">
            <span class="type btn-link" data-toggle="dropdown"></span>
            <ul class="dropdown-menu">
                <li><span class="btn-link" data-label="answer">Proof</span></li>
            </ul>
        </div>
    '''

    activateRule = ($element) ->
      type = $element.attr('data-label') or 'rule'

      $statements = $element.children('.statement')
      $proofs = $element.children('.proof')

      $element.children().not($statement).not($proof).remove()
      $statementContainer = $statement.add($proof).wrapAll('<section class="js-statement-container aloha-ephemera-wrapper"></section>').parent()

      $typeContainer = jQuery(TYPE_CONTAINER)

      $typeContainer.find('.dropdown-menu li').each (i, li) =>
        if jQuery(li).children('span').data('type') == type
          jQuery(li).addClass('checked')

      $typeContainer.prependTo($element)

      $content = $statement.contents()
      $statement
        .empty()
        .addClass('aloha-block-dropzone')
        .attr('placeholder', "Type the text of your statement here.")
        .aloha()
        .append($content)

      jQuery('<div>')
        .addClass('proofs')
        .addClass('aloha-ephemera-wrapper')
        .appendTo($statementContainer)
        .append($statements)

      jQuery('<div>')
        .addClass('proof-controls')
        .addClass('aloha-ephemera')
        .append('<span class="add-proof btn-link">Click here to add a proof</span>')
        .append('<span class="proof-toggle">hide proof</span>')
        .appendTo($element)

      if not $statements.length
        $element.children('.proof-controls').children('.proof-toggle').hide()

    deactivateRule = ($element) ->
      return

    activateproof = ($element) ->
      type = $element.attr('data-label') or 'proof'

      $element.contents()
        .filter((i, child) -> child.nodeType is 3 && child.data.trim().length)
        .wrap('<p></p>')

      $body = ''
      $body = $element.children() if $element.text().trim().length

      $typeContainer = jQuery(PROOF_TYPE_CONTAINER)
      $typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1) )

      $typeContainer.find('.dropdown-menu li').each (i, li) =>
        if jQuery(li).children('a').text().toLowerCase() == type
          jQuery(li).addClass('checked')

      $typeContainer.prependTo($element)

      jQuery('<div>')
        .addClass('body')
        .addClass('aloha-ephemera-wrapper')
        .addClass('aloha-block-dropzone')
        .appendTo($element)
        .aloha()
        .append($body)

    deactivateProof = ($element) ->
      if $element.children('.body').children().length
        $element.children(':not(.body)').remove()
        $element.children('.body').contents().unwrap()

      $element.children('.body').remove()

      $element.contents()
        .filter((i, child) -> child.nodeType is 3 && child.data.trim().length)
        .wrap('<p></p>')

    Plugin.create('rule', {
      getLabel: ($element) ->
        if $element.is('.rule')
          return 'Rule'
        else if $element.is('.statement')
          return 'Statement'

      activate: ($element) ->
        if $element.is('.statement')
          activateRule($element)
        else if $element.is('.proof')
          activateProof($element)

      deactivate: ($element) ->
        if $element.is('.rule')
          deactivateRule($element)
        else if $element.is('.statement')
          deactivateProof($element)

      appendTo: (target) ->
        semanticBlock.appendElement(jQuery(TEMPLATE), target)


      selector: '.rule,.proof' #this plugin handles both statements and proofs
      ignore: '.statement'

      options: ($el) ->
        if $el.is('.proof')
          return buttons: ['settings']
        return buttons: ['settings', 'copy']

      init: () ->

        semanticBlock.register(this)

        UI.adopt 'insertRule', Button,
          click: -> semanticBlock.insertAtCursor(TEMPLATE)

        semanticBlock.registerEvent('click', '.rule .proof-controls .add-proof', () ->
          rule = jQuery(this).parents('.rule').first()
          controls = rule.children('.proof-controls')

          controls.children('.proof-toggle').text('hide proof').show()

          semanticBlock.appendElement(jQuery(PROOF_TEMPLATE), rule.find('.proofs'))
        )
        semanticBlock.registerEvent('click', '.rule .proof-controls .proof-toggle', () ->
          rule = jQuery(this).parents('.rule').first()
          controls = rule.children('.proof-controls')
          proofs = rule.children('.proofs')

          proofs.slideToggle ->
            if proofs.is(':visible')
              controls.children('.proof-toggle').text('hide proof')
            else
              controls.children('.proof-toggle').text('show proof')

        )
        semanticBlock.registerEvent('click', '.rule .semantic-delete', () ->
          rule = jQuery(this).parents('.rule').first()
          controls = rule.children('.proof-controls')
          controls.children('.add-proof').show()
          controls.children('.proof-toggle').hide() if rule.children('.proofs').children().length == 1
        )
        semanticBlock.registerEvent('click', '.aloha-oer-block.proof > .type-container > ul > li > *,
                                              .aloha-oer-block.rule > .type-container > ul > li > *', (e) ->
          $el = jQuery(@)
          $el.parents('.type-container').first().children('.type').text $el.text()
          $el.parents('.aloha-oer-block').first().attr 'data-label', $el.data('type')

          $el.parents('.type-container').find('.dropdown-menu li').each (i, li) =>
            jQuery(li).removeClass('checked')
          $el.parents('li').first().addClass('checked')
        )
    })
