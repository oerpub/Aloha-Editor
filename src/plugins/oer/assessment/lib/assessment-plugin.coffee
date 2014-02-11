define [
	'aloha'
	'aloha/plugin'
	'jquery'
	'ui/ui'
	'ui/button'
	'aloha/ephemera'
  'semanticblock/semanticblock-plugin'
  'css!assessment/css/assessment-plugin.css'], (Aloha, Plugin, $, UI, Button, Ephemera, semanticBlock) ->

  TEMPLATE = '''<div class="assessment"></div>'''

  DIALOG_TEMPLATE = '''
<div class="modal fade assessment-modal" tabindex="-1" role="dialog">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal">&times;</button>
      <h3>Insert an assessment</h3>
    </div>
    <div class="modal-body">
      <label style="display: inline-block">
        Assessment Url: 
        <input type="text" name="assessmentUrl">
      </label>
      <button class="btn" data-embed-this>Embed</button>

      <label style="display: inline-block">
        Search: 
        <input type="text" name="search">
      </label>
      <button class="btn" data-search>Search</button>

      <div class="search-results">

        <div class="template search-result">
          <h4 class="title"></h4>
          <p class="description"></p>
          <a href="" class="select">select</p>
        </div>

      </div>
    </div>
    <div class="modal-footer">
      <button class="btn action cancel" data-dismiss="modal">Cancel</button>
    </div>
</div>
'''
  CONFIRM_DIALOG_TEMPLATE = '''
<div class="modal fade assessment-confirm-modal" tabindex="-1" role="dialog">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal">&times;</button>
      <h3>Insert an assessment</h3>
    </div>
    <div class="modal-body">
    </div>
    <div class="modal-footer">
      <button class="btn action cancel">Back</button>
      <button class="btn action submit">Go!</button>
    </div>
</div>
'''

  PLACEHOLDER = '''<span class="aloha-ephemera"></span>'''

  _buildAssessmentUrl = (id) ->
    return plugin.settings.assessmentUrl + id

  _fetchAssessment = (url) ->
    $.get(plugin.settings.oembedUrl, {url: url})

  _querySearch = (query) ->
    $.get(plugin.settings.searchUrl, {q: query})

  _triggerModal = (e) ->
    e.preventDefault()

    $placeholder = $(PLACEHOLDER)
    range = Aloha.Selection.getRangeObject()
    GENTICS.Utils.Dom.insertIntoDOM $placeholder, range, Aloha.activeEditable.obj

    $dialog = $(DIALOG_TEMPLATE)

    $dialog.on 'change', '[name="assessmentUrl"]', () ->
      $dialog.find('button[data-embed-this]').attr('data-embed-this', $(this).val())

    $dialog.on 'click', 'button[data-search]', ->
      $searchResultsContainer = $dialog.find('.search-results')

      _querySearch($dialog.find('[name="search"]').val()).success (data) ->

        $template = $searchResultsContainer.find('.template')
        $searchResultsContainer.children().not($template).remove()
        $searchResultsContainer.hide()

        for result in data.assessments
          result = result.assessments

          $searchResultsContainer.show()

          $element = $template.clone().removeClass('template')
          $element.find('.title').text(result.title)
          $element.find('.description').text(result.description)
          $element.find('.select').attr('data-embed-this', _buildAssessmentUrl(result.id))
          $element.appendTo($searchResultsContainer)

    $dialog.on 'click', '[data-embed-this]', (e)->
      e.preventDefault()

      url = $(this).attr('data-embed-this')

      _fetchAssessment(url).success (data) ->
        $dialog.modal 'hide'
        $confirmDialog = $(CONFIRM_DIALOG_TEMPLATE)
        $confirmDialog.css('width', data.width)
        $confirmDialog.find('.modal-body').html(data.html)
        $confirmDialog.modal show: true

        $confirmDialog.on 'click', '.cancel', ->
          $confirmDialog.modal 'hide'
          $dialog.modal 'show'
        $confirmDialog.on 'click', '.submit', ->
          $confirmDialog.modal 'hide'

          $element = $(TEMPLATE).html(data.html)
          semanticBlock.insertOver($element, $placeholder)

    $dialog.modal show: true
  

  plugin = Plugin.create('assessment', {
    defaults: {
      oembedUrl: 'http://www.openassessments.org/oembed.json'
      searchUrl: 'http://www.openassessments.org/api/assessments.json'
      assessmentUrl: 'http://www.openassessments.com/users/u/assessments/'
    }

    getLabel: -> 'Assessment'
  
    appendTo: (target) ->
      semanticBlock.appendElement(jQuery(TEMPLATE), target)

    selector: '.assessment' #this plugin handles both exercises and solutions

    options: ($el) -> buttons: ['copy']

    init: () ->

      semanticBlock.register(this)

      UI.adopt 'insertAssessment', Button,
        click: _triggerModal
  })
