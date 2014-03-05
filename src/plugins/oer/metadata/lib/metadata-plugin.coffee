define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'semanticblock/semanticblock-plugin'
  './languages'
  'css!metadata/css/metadata-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, SemanticBlock, languages) ->

  METADATA_MODAL = '''
<div id="module-metadata-modal" class="modal fade" tabindex="-1" role="dialog" style="width: 660px;">
  <div class="modal-header">
    <button type="button" class="close" data-cancel aria-hidden="true">×</button>
    <h3>Edit the authors and other metadata on this module</h3>
  </div>
  <div class="modal-body" style="max-height: 435px;">

    <form>
      <h4 style="display:inline-block;">Title (required):</h4>
      <h4 style="display:inline-block;" class="toc-color" data-edit-toggle>
        <span data-title>title title title</span>
        <small><em>click to edit</em></small>
      </h4>
      <input
        type="text"
        name="title"
        style="display: none;"
        class="input-xlarge">
    </form>

    <ul class="nav nav-tabs">
      <li class="active"><a href="#module-metadata-about" data-toggle="tab">About</a></li>
      <li><a href="#module-metadata-authors" data-toggle="tab">Authors</a></li>
      <li><a href="#module-metadata-summary" data-toggle="tab">Summary</a></li>
    </ul>

    <form class="form-horizontal">
      <div class="tab-content">
        <div class="tab-pane active" id="module-metadata-about" style="width: 560px;">
          <div class="control-group">
            <label class="control-label"> Subject </label>
            <div class="controls">
              <input
                type="text"
                name="subject"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
          <div class="control-group">
            <label class="control-label"> Language </label>
            <div class="controls">
              <select name="language">
              </select>
            </div>
          </div>
          <div class="control-group">
            <label class="control-label"> Keywords </label>
            <div class="controls">
              <input
                type="text"
                name="keywords"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
          <div class="control-group">
            <label class="control-label"> Licence </label>
            <div class="controls">
              <select name="rights">
                <option value="">Choose a license</option>
                <option value="http://creativecommons.org/licenses/by/3.0/">
                  Creative Commons Attribution - CC-BY</option>
                <option value="http://creativecommons.org/licenses/by-nd/3.0/">
                  Creative Commons Attribution-NoDerivs - CC BY-ND</option>
                <option value="http://creativecommons.org/licenses/by-sa/3.0/">
                  Creative Commons Attribution-ShareAlike - CC BY-SA</option>
                <option value="http://creativecommons.org/licenses/by-nc/3.0/">
                  Creative Commons Attribution-NonCommercial - CC BY-NC</option>
                <option value="http://creativecommons.org/licenses/by-nc-sa/3.0/">
                  Creative Commons Attribution-NonCommercial-ShareAlike - CC BY-NC-SA</option>
                <option value="http://creativecommons.org/licenses/by-nc-nd/3.0/">
                  Creative Commons Attribution-NonCommercial-NoDerivs - CC BY-NC-ND</option>
                <option value="http://creativecommons.org/publicdomain/">
                  Public domain</option>
                <option>other</option>
              </select>
            </div>
          </div>
        </div>
        <div class="tab-pane" id="module-metadata-authors">
          <div class="control-group">
            <label class="control-label">Authors</label>
            <div class="controls">
              <input
                type="text"
                name="authors"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
          <div class="control-group">
            <label class="control-label">Copyright Holders</label>
            <div class="controls">
              <input
                type="text"
                name="rights-holders"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
          <div class="control-group">
            <label class="control-label">Publisher (optional)</label>
            <div class="controls">
              <input
                type="text"
                name="publishers"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
          <div class="control-group">
            <label class="control-label">Editors (optional)</label>
            <div class="controls">
              <input
                type="text"
                name="editors"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
          <div class="control-group">
            <label class="control-label">Translators (optional)</label>
            <div class="controls">
              <input
                type="text"
                name="translators"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
          <div class="control-group">
            <label class="control-label">Illustrator (optional)</label>
            <div class="controls">
              <input
                type="text"
                name="illustrators"
                data-role="tagsinput"
                placeholder="Use comma, or tab to separate   "
              >
            </div>
          </div>
        </div>
        <div class="tab-pane" id="module-metadata-summary">
          <div class="control-group">
            <label class="control-label">Summary</label>
            <div class="controls">
              <textarea name="description" rows="10" class="span5"></textarea>
            </div>
          </div>
        </div>
      </div>
    </form>
  </div>
  <div class="modal-footer">
    <button class="btn" data-cancel>Close without saving</button>
    <button class="btn" data-save>Close and save</button>
    <button class="btn" data-tab-next>Next</button>
  </div>
</div>
'''

  TITLE_TEMPLATE = '''
<h1 data-type="title" itemprop="name"></h1>'''

  # contributor templates
  AUTHORS_TEMPLATE = '''
<div class="authors">
  By:
  <span itemscope="itemscope" itemtype="http://schema.org/Person" data-type="author" itemprop="author"></span>
</div>'''

  EDITORS_TEMPLATE = '''
<div class="editors">
  Edited by:
  <span data-type="editor" itemprop="editor"></span>
</div>'''

  ILLUSTRATORS_TEMPLATE = '''
<div class="illustrators">
  Illustrated by:
  <span data-type="illustrator" itemprop="illustrator"></span>
</div>'''

  TRANSLATORS_TEMPLATE = '''
<div class="translators">
  Translated by: 
  <span data-type="translator" itemprop="contributor"></span>
</div>'''

  # publishers don't get to be contributors 
  PUBLISHERS_TEMPLATE = '''
<div class="publishers">
  Published by: 
  <span data-type="publisher" itemprop="publisher"></span>
</div>'''

  # permissions (copyright) 
  COPYRIGHT_TEMPLATE = '''
<div class="copyright">
  Copyright: 
  <span data-type="copyright-holder" itemprop="copyrightHolder"></span>
</div>'''

  LICENCE_TEMPLATE = '''
<div class="license">
  Licensed:
  <a data-type="license" rel="license" href=""></a>
</div>'''

  # other random metadata
  KEYWORDS_TEMPLATE = '''
<div class="keywords">
  Keywords:
  <span data-type="keyword" itemprop="keywords"></span>
</div>'''

  SUBJECTS_TEMPLATE = '''
<div class="subject">
  Subject:
  <span data-type="subject" itemprop="about"></span>
</div>'''

  DESCRIPTION_TEMPLATE = '''
<div data-type="description" itemprop="description" class="description">
  <p class="summary"></p>
</div>'''
  
  LANGUAGE_TEMPLATE = '''
<meta data-type="language" itemprop="inLanguage" content="" />'''

  METADATA_TEMPLATE = '''
<div
  data-type="metadata"
  itemscope="itemscope"
  itemtype="http://schema.org/CreativeWork">
</div>
'''

  elements =
    title:         {selector: 'h1[data-type="title"]',  hasMany: false}
    authors:       {selector: '.authors span',          hasMany: true}
    editors:       {selector: '.editors span',          hasMany: true}
    illustrators:  {selector: '.illustrators span',     hasMany: true}
    translators:   {selector: '.translators span',      hasMany: true}
    publishers:    {selector: '.publishers span',       hasMany: true}
    rightsHolders: {selector: '.copyright span',        hasMany: true}
    rightsUrl:     {selector: '.license a',             hasMany: false, prop: 'href'}
    language:      {selector: '[data-type="language"]', hasMany: false, prop: 'content'}
    keywords:      {selector: '.keywords span',         hasMany: true}
    subjects:      {selector: '.subject span',          hasMany: true}
    description:   {selector: '.description p',         hasMany: false}

  plugin = Plugin.create 'metadata', {

    _selector: '[data-type="metadata"]'
    $_editable: null
    $_element: null

    _showModal: ->
      $modal = $('#module-metadata-modal')
      $modal = $(METADATA_MODAL) if not $modal.length

      $languageSelect = $modal.find('select[name="language"]')

      for key, label of languages
        $('<option></option>')
          .attr('value', key)
          .text(label)
          .appendTo($languageSelect)

      # populate book data in the form
      metadata = @_readMetadata()

      $modal.find('[name="title"]').val(metadata.title)
      $modal.find('[name="language"]').val(metadata.language)
      $modal.find('[name="description"]').val(metadata.description)
      $modal.find('[name="language"]').val(metadata.language || 'en')
      $modal.find('[name="rights"]').val(metadata.rightsUrl)

      $modal.find('[data-role="tagsinput"]').each ->
        $(@).tagsinput({
          confirmKeys: [13, 188, 9]
        }) unless $(@).data('tagsinput')
        $(@).tagsinput('removeAll')

      _.each metadata.subjects, (subject) -> $modal.find('[name="subject"]').tagsinput('add', subject)
      _.each metadata.keywords, (keyword) -> $modal.find('[name="keywords"]').tagsinput('add', keyword)
      _.each metadata.rightsHolders, (rightsHolder) -> $modal.find('[name="rights-holders"]').tagsinput('add', rightsHolder)
      _.each metadata.authors, (author) -> $modal.find('[name="authors"]').tagsinput('add', author)
      _.each metadata.publishers, (publisher) -> $modal.find('[name="publishers"]').tagsinput('add', publisher)
      _.each metadata.editors, (editor) -> $modal.find('[name="editors"]').tagsinput('add', editor)
      _.each metadata.translators, (translator) -> $modal.find('[name="translators"]').tagsinput('add', translator)
      _.each metadata.illustrators, (illustrator) -> $modal.find('[name="illustrators"]').tagsinput('add', illustrator)

      $modal.find('.nav.nav-tabs li:first a').click()

      $modal.find('[data-edit-toggle]').off('click').click ->
        $(this).hide().siblings('input').show().focus()
      .siblings('input').off('blur').blur ->
        $(this).hide().siblings('[data-edit-toggle]').show().find('[data-title]').text($(this).val())
      .trigger('blur')

      $modal.find('a[data-toggle="tab"]').off('shown').on('shown', (e) ->
        if $(e.target).parents('li').next().length
          $modal.find('[data-tab-next]').show()
        else
          $modal.find('[data-tab-next]').hide()
      )

      $modal.find('[data-cancel]').off('click').click ->
        if confirm('Are you sure you want to close without saving? The title, authors, and other information about this book will retain their previous values.')
          $modal.modal('hide')

      $modal.find('[data-tab-next]').off('click').click ->
        next = $modal.find('.nav li.active').next()
        next.find('a').click() if next.length

      $modal.modal {show:true}

      $modal.find('[data-save]').off('click').click =>
        rightsUrl = $modal.find('[name="rights"]').val()

        if rightsUrl.length
          rights = $modal.find('[name="rights"] option[value="' + rightsUrl + '"]').text().trim()
        else
          rights = ''

        now = new Date()

        @_setMetadata
          title: $modal.find('[name="title"]').val()
          description: $modal.find('[name="description"]').val()
          language: $modal.find('[name="language"]').val()
          rights: rights
          rightsUrl: rightsUrl
          dateModified: "#{now.getFullYear()}-#{now.getMonth()+1}-#{now.getDate()}"
          subjects: $modal.find('[name="subject"]').val().split(',').filter (i) -> i
          keywords: $modal.find('[name="keywords"]').val().split(',').filter (i) -> i
          rightsHolders: $modal.find('[name="rights-holders"]').val().split(',').filter (i) -> i
          authors: $modal.find('[name="authors"]').val().split(',').filter (i) -> i
          publishers: $modal.find('[name="publishers"]').val().split(',').filter (i) -> i
          editors: $modal.find('[name="editors"]').val().split(',').filter (i) -> i
          translators: $modal.find('[name="translators"]').val().split(',').filter (i) -> i
          illustrators: $modal.find('[name="illustrators"]').val().split(',').filter (i) -> i

        $modal.modal('hide')

    _readMetadata: ->
      return @metadata if @metadata
      metadata = {}

      for key, entry of elements
        selector = entry.selector
        hasMany  = entry.hasMany
        getValue = (element) ->
          if entry.prop
            return element.attr(entry.prop)
          else
            return element.text()

        if hasMany
          metadata[key] = []
          @$_element.find(selector).each ->
            metadata[key].push(getValue($(this)))
        else
          metadata[key] = getValue(@$_element.find(selector))

      @metadata = metadata

    _setMetadata: (metadata) ->
      # copy this so filters aren't applied to it
      @metadata = JSON.parse(JSON.stringify(metadata))
      @$_element.empty()

      @settings.setMetadata?(metadata)
      @settings.filterMetadata?(metadata)

      $(TITLE_TEMPLATE)
        .text(metadata.title)
        .appendTo(@$_element) if metadata.title

      $(LANGUAGE_TEMPLATE)
        .attr('content', metadata.language)
        .appendTo(@$_element) if metadata.language

      @_setContributors(metadata)
    
      if metadata.publishers.length
        @_handleGroup(@$_element, PUBLISHERS_TEMPLATE, metadata.publishers)

      @_setPermissions(metadata)
    
      if metadata.keywords.length
        @_handleGroup(@$_element, KEYWORDS_TEMPLATE, metadata.keywords)
    
      if metadata.subjects.length
        @_handleGroup(@$_element, SUBJECTS_TEMPLATE, metadata.subjects)

      if metadata.description
        $description = $(DESCRIPTION_TEMPLATE)
        $description.find('.summary').text(metadata.description)
        $description.appendTo(@$_element)

    _setContributors: (contributors) ->
      $wrapper = $('<div>').addClass('contributors')
      
      if contributors.authors.length
        @_handleGroup($wrapper, AUTHORS_TEMPLATE, contributors.authors)
      if contributors.editors.length
        @_handleGroup($wrapper, EDITORS_TEMPLATE, contributors.publishers)
      if contributors.illustrators.length
        @_handleGroup($wrapper, ILLUSTRATORS_TEMPLATE, contributors.illustrators)
      if contributors.translators.length
        @_handleGroup($wrapper, TRANSLATORS_TEMPLATE, contributors.translators)
      
      $wrapper.appendTo(@$_element) if not $wrapper.is(':empty')
 
    _setPermissions: (permissions) ->
      $wrapper = $('<div>').addClass('permissions')

      if permissions.rightsHolders.length
        @_handleGroup($wrapper, COPYRIGHT_TEMPLATE, permissions.rightsHolders)

      if permissions.rightsUrl && permissions.rights
        $rights = $(LICENCE_TEMPLATE)
        $rights.find('[data-type="license"]').text(permissions.rights)
        $rights.find('[data-type="license"]').attr('href', permissions.rightsUrl)
        $rights.appendTo($wrapper)

      $wrapper.appendTo(@$_element) if not $wrapper.is(':empty')

    _handleGroup: ($container, template, values) ->
      $groupTemplate = $(template)
      $item = $groupTemplate.find('span').clone()
      $groupTemplate.find('span').remove()
 
      for value, i in values
        $item
          .clone()
          .text(value)
          .appendTo($groupTemplate)

        if values.length > 1 && i != values.length-1
          $groupTemplate.append(', ')

      $container.append($groupTemplate)

    _init: (element) ->
      @$_editable = element

      if not @$_editable.find(@_selector).length
        @$_editable.prepend($(METADATA_TEMPLATE))

      @$_element = @$_editable.find(@_selector)
      @$_element.attr('contenteditable', false)

      @$_element.append(@settings.supplement)

      if not @$_element.find(elements.title.selector).length
        $(TITLE_TEMPLATE).prependTo(@$_element)

      if @$_element.find('title').length
        title = @$_element.find('title').remove().text()
        @$_element.find(elements.title.selector).text(title)

      @$_element.click =>
        @_showModal()

    extendMetadata: (newMetadata) ->

      metadata = plugin._readMetadata()
      
      for key, value of newMetadata
        console.log 'meta', key, value
        metadata[key] = value
       
      plugin._setMetadata(metadata)
 
    init: () ->

      SemanticBlock.ignore('[data-type="metadata"],[data-type="metadata"] *')

      @settings.extendMetadata = @extendMetadata

      Aloha.bind 'aloha-editable-created', (e, params) =>
        @_init(params.obj) if params.obj.is('.aloha-root-editable')
  }











