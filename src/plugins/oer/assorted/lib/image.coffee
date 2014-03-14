# Aloha Image Plugin
# * -----------------
# * This plugin handles when the insertImage button is clicked and provides a bubble next to an image when it is selected
#
define [
  'aloha',
  'jquery',
  'aloha/plugin',
  'image/image-plugin',
  'ui/ui',
  'figure/figure-plugin',
  'css!assorted/css/image.css'],
(
  Aloha,
  jQuery,
  AlohaPlugin,
  Image,
  UI,
  Figure
) ->

  # This will be prefixed with Aloha.settings.baseUrl
  WARNING_IMAGE_PATH = '/../plugins/oer/image/img/warning.png'

  DIALOG_HTML_CONTAINER = '''
      <form class="plugin image modal hide fade form-horizontal" id="linkModal" tabindex="-1" role="dialog" aria-labelledby="linkModalLabel" aria-hidden="true" data-backdrop="false" />'''

  DIALOG_HTML = '''
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3>Insert image</h3>
      </div>
      <div class="modal-body">
        <div class="image-options">
            <div class="image-selection">
              <div class="dia-alternative">
                <span class="upload-image-link btn-link">Choose an image to upload</span>
                <input type="file" class="upload-image-input">
              </div>
              <div class="dia-alternative">
                OR
              </div>
              <div class="dia-alternative">
                <span class="upload-url-link btn-link">get image from the Web</span>
                <input type="url" class="upload-url-input" placeholder="Enter URL of image ...">
              </div>
            </div>
            <div class="placeholder preview hide">
              <img class="preview-image"/>
            </div>
        </div>
        <div class="image-alt">
          <div class="forminfo">
            <i class="icon-warning"></i><strong>Describe the image for someone who cannot see it.</strong> This description can be read aloud, making it possible for visually impaired learners to understand the content.</strong>
          </div>
          <div>
            <textarea name="alt" placeholder="Enter description ..." rows="3"></textarea>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn action cancel">Cancel</button>
        <button type="submit" disabled="true" class="btn btn-primary action insert">Next</button>
      </div>'''

  DIALOG_HTML2 = '''
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3>Insert image</h3>
      </div>
      <div class="modal-body">
        <div>
          <strong>Source for this image (Required)</strong>
        </div>
        <div class="source-selection">
          <ul style="list-style-type: none; padding: 0; margin: 0;">
            <li id="listitem-i-own-this">
              <label class="radio">
                <input type="radio" name="image-source-selection" value="i-own-this">I own it (no citation needed) 
              </label>
            </li>
            <li id="listitem-i-got-permission">
              <label class="radio">
                <input type="radio" name="image-source-selection" value="i-got-permission">I am allowed to reuse it: 
              </label>
              <div class="source-selection-allowed">
                <fieldset>
                  <label>Who is the original author of this image?</label>
                  <input type="text" disabled="disabled" id="reuse-author">

                  <label>What organization owns this image?</label>
                  <input type="text" disabled="disabled" id="reuse-org">

                  <label>What is the original URL of this image?</label>
                  <input type="text" disabled="disabled" id="reuse-url" placeholder="http://">

                  <label>Permission to reuse</label>
                  <select id="reuse-license" disabled="disabled">
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
                </fieldset>
              </div>
            </li>
            <li id="listitem-i-dont-know">
              <label class="radio">
                <input type="radio" name="image-source-selection" value="i-dont-know">I don't know (skip citation for now)
              </label>
            </li>
          </ul>
        </div>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-primary action insert">Save</button>
        <button class="btn action cancel">Cancel</button>
      </div>'''

  showEditDialog = ($el) ->
    dialog = jQuery(DIALOG_HTML_CONTAINER)
    dialog.append(jQuery(DIALOG_HTML))

    dialog.find('.image-options').remove()
    dialog.find('.btn.action.attribution').show()

    dialog.find('[name=alt]').val($el.attr('alt'))
    dialog.find('.btn.action.insert')
      .text('Save')
      .removeAttr('disabled')

    deferred = $.Deferred()

    dialog.find('.btn.action.attribution').click ->
      deferred.done ->
        showModalDialog2($el)

    dialog.on 'submit', (evt) =>
      evt.preventDefault() # Don't submit the form

      setEditText($el)
      setThankYou($el) if dialog.find('[name=alt]').val() && not $el.attr('alt')

      $el.attr 'alt', dialog.find('[name=alt]').val()

      dialog.modal('hide')
      deferred.resolve($el)

    dialog.on 'shown', () =>
      dialog.find('input,textarea,select').filter(':visible').first().focus()
      
    dialog.on 'click', '.btn.action.cancel', (evt) =>
      evt.preventDefault() # Don't submit the form
      deferred.reject()
      dialog.modal('hide')

    dialog.modal {show: true}

    return deferred.promise()

  showCreateDialog = ->
    settings = Aloha.require('assorted/assorted-plugin').settings
    dialog = jQuery(DIALOG_HTML_CONTAINER)
    dialog.append(jQuery(DIALOG_HTML))

    $submit = dialog.find('.action.insert')

    # Find the dynamic modal elements and bind events to the buttons
    $imageselect = dialog.find('.image-selection')
    $placeholder = dialog.find('.placeholder.preview')
    $uploadImage = dialog.find('.upload-image-input').hide()
    $uploadUrl =   dialog.find('.upload-url-input').hide()
    $submit = dialog.find('.action.insert')

    imageSource = null

    # Set onerror of preview image
    ((img, baseurl) ->
      img.onerror = ->
        errimg = baseurl + WARNING_IMAGE_PATH
        img.src = errimg unless img.src is errimg
    ) dialog.find('.placeholder.preview img')[0], Aloha.settings.baseUrl

    setImageSource = (href) ->
      imageSource = href
      $submit.removeAttr('disabled')

    # Uses the File API to render a preview of the image
    # and updates the modal's imageSource
    loadLocalFile = (file, $img, callback) ->
      reader = new FileReader()
      reader.onloadend = () ->
        $img.attr('src', reader.result) if $img
        # If we get an image then update the modal's imageSource
        setImageSource(reader.result)
        callback(reader.result) if callback
      reader.readAsDataURL(file)

    # Add click handlers
    dialog.find('.upload-image-link').on 'click', () ->
      $placeholder.hide()
      $uploadUrl.hide()
      $uploadImage.click()

    dialog.find('.upload-url-link').on 'click', () ->
      $placeholder.hide()
      $uploadImage.hide()
      $uploadUrl.show().focus()

    $uploadImage.on 'change', () ->
      files = $uploadImage[0].files
      # Parse the file and if it's an image set the imageSource
      if files.length > 0
        if settings.image.preview
          $previewImg = $placeholder.find('img')
          loadLocalFile files[0], $previewImg
          $placeholder.show()
          $imageselect.hide()
        else
          loadLocalFile files[0]

    # When the url input changes, or if the user presses enter, update the
    # image and preview it if configured to do so.
    showRemoteImage = () ->
      $previewImg = $placeholder.find('img')
      url = $uploadUrl.val()
      setImageSource(url)
      if settings.image.preview
        $previewImg.attr 'src', url
        $placeholder.show()
        $imageselect.hide()

    $uploadUrl.on 'change', showRemoteImage
    $uploadUrl.on 'keydown', null, 'return', (e) ->
      e.preventDefault()
      showRemoteImage()

    # On save update the actual img tag. Use the submit event because this
    # allows the use of html5 validation.
    deferred = $.Deferred()
    dialog.on 'submit', (evt) =>
      evt.preventDefault() # Don't submit the form

      $el = $('<img>')
      $el.attr 'src', imageSource
      $el.attr 'alt', dialog.find('[name=alt]').val()

      dialog.modal('hide')
      deferred.resolve($el)

    dialog.on 'shown', () =>
      dialog.find('input,textarea,select').filter(':visible').first().focus()
      
    dialog.on 'click', '.btn.action.cancel', (evt) =>
      evt.preventDefault() # Don't submit the form
      deferred.reject()
      dialog.modal('hide')

    dialog.modal {show: true}

    return deferred.promise()

  showModalDialog2 = ($img) ->
    $dialog = jQuery(DIALOG_HTML_CONTAINER)
    $dialog.append(jQuery(DIALOG_HTML2))

    src = $img.attr('src')
    if src and /^http/.test(src)
      $dialog.find('input#reuse-url').val src

    creator    = $img.attr 'data-lrmi-creator'
    if creator
      $dialog.find('input#reuse-author').val creator
    publisher  = $img.attr 'data-lrmi-publisher'
    if publisher
      $dialog.find('input#reuse-org').val publisher
    basedOnURL = $img.attr 'data-lrmi-isBasedOnURL'
    if basedOnURL
      $dialog.find('input#reuse-url').val basedOnURL
    rightsUrl  = $img.attr 'data-lrmi-useRightsURL'
    if rightsUrl
      $option = $dialog.find('select#reuse-license option[value="' + rightsUrl + '"]')
      if $option
        $option.prop 'selected', true
    if creator or publisher or rightsUrl
      $dialog.find('input[value="i-got-permission"]').prop 'checked', true

    $dialog.find('input[type=radio]').click()

    $dialog.find('input[name="image-source-selection"]').click (evt) ->
      inputs = jQuery('.source-selection-allowed').find('input,select')

      if jQuery(@).val() == 'i-got-permission'
        inputs.removeAttr('disabled')
      else
        inputs.attr('disabled', 'disabled')

      evt.stopPropagation()
      return

    $dialog.find('li#listitem-i-own-this, li#listitem-i-got-permission, li#listitem-i-dont-know').click (evt)=>
      $current_target = jQuery(evt.currentTarget)
      $cb = $current_target.find 'input[name="image-source-selection"]'
      $cb.click() if $cb
      return

    deferred = $.Deferred()
    $dialog.off('submit').on 'submit', (evt) =>
      evt.preventDefault() # Don't submit the form

      buildAttribution = (creator, publisher, basedOnURL, rightsName) =>
        attribution = ""
        if creator and creator.length > 0
          attribution += "Image by " + creator + "."
        if publisher and publisher.length > 0
          attribution += "Published by " + publisher + "."
        if basedOnURL and basedOnURL.length > 0
          baseOn = '<link src="' + basedOnURL + '">Original source</link>.'
          baseOnEscaped = jQuery('<div />').text(baseOn).html()
          attribution += baseOn
        if rightsName and rightsName.length > 0
          attribution += 'License: ' + rightsName + "."
        return attribution

      if $dialog.find('input[value="i-got-permission"]').prop 'checked'
        creator = $dialog.find('input#reuse-author').val()
        if creator and creator.length > 0
          $img.attr 'data-lrmi-creator', creator
        else
          $img.removeAttr 'data-lrmi-creator'

        publisher = $dialog.find('input#reuse-org').val()
        if publisher and publisher.length > 0
          $img.attr 'data-lrmi-publisher', publisher
        else
          $img.removeAttr 'data-lrmi-publisher'

        basedOnURL = $dialog.find('input#reuse-url').val()
        if basedOnURL and basedOnURL.length > 0
          $img.attr 'data-lrmi-isBasedOnURL', basedOnURL
        else
          $img.removeAttr 'data-lrmi-isBasedOnURL'

        $option = $dialog.find('select#reuse-license :selected')
        rightsUrl = $option.attr 'value'
        rightsName = $.trim $option.text()
        if rightsUrl and rightsUrl.length > 0
          $img.attr 'data-lrmi-useRightsURL', rightsUrl
        else
          $img.removeAttr 'data-lrmi-useRightsURL'

        attribution = buildAttribution(creator, publisher, basedOnURL, rightsName)
        if attribution and attribution.length > 0
          $img.attr 'data-tbook-permissionText', attribution
        else
          $img.removeAttr 'data-tbook-permissionText'
      else
        $img.removeAttr 'data-lrmi-creator'
        $img.removeAttr 'data-lrmi-publisher'
        $img.removeAttr 'data-lrmi-isBasedOnURL'
        $img.removeAttr 'data-lrmi-useRightsURL'
        $img.removeAttr 'data-tbook-permissionText'

      editableId = $img.parents('.aloha-editable').last().attr('id')
      Aloha.getEditableById(editableId).smartContentChange({type: 'block-change'})
      deferred.resolve($img)
      $dialog.modal('hide')

    $dialog.off('click').on 'click', '.btn.action.cancel', (evt) =>
      evt.preventDefault() # Don't submit the form
      deferred.reject($img)
      $dialog.modal('hide')

    $dialog.modal {show: true}

    return deferred.promise()

  insertImage = () ->
    Figure.insertPlaceholder()

    showCreateDialog().then (image) ->
      Figure.insertOverPlaceholder(image)
      showModalDialog2(image)

  $('body').bind 'aloha-image-resize', ->
    Aloha.activeEditable.smartContentChange({type: 'block-change'})

  setThankYou = ($img) ->
    wrapper = $img.parents('.image-wrapper').first()
    return if not wrapper.length
    editDiv = wrapper.children('.image-edit')
    editDiv.html('<i class="icon-edit"></i> Thank You!').removeClass('passive')
    editDiv.addClass('thank-you')
    editDiv.animate({opacity: 0}, 2000, 'swing', -> setEditText $img)

  setEditText = ($img) ->
    wrapper = $img.parents('.image-wrapper').first()
    return if not wrapper.length
    alt = wrapper.children('img').attr('alt')
    editDiv = wrapper.children('.image-edit').removeClass('thank-you').css('opacity', 1)

    if alt
        editDiv.html('<i class="icon-edit"></i>').addClass('passive')
    else
        editDiv.html('<i class="icon-warning"></i><span class="warning-text">Description missing</span>').removeClass('passive')
        editDiv.off('mouseenter').on 'mouseenter', (e) ->
          editDiv.find('.warning-text').text('Image is missing a description for the visually impaired. Click to provide one.')
        editDiv.off('mouseleave').on 'mouseleave', (e) ->
          editDiv.find('.warning-text').text('Description missing')

  initialize = ($img) ->
    wrapper = $('<div class="image-wrapper aloha-ephemera-wrapper">')
    edit = $('<div class="image-edit aloha-ephemera">')
    $img.wrap(wrapper).parent().prepend(edit)
    setEditText $img

  # Return config
  AlohaPlugin.create('oer-image', {
    init: () ->
      plugin = @
      UI.adopt 'insertImage-oer', null,
        click: (e) -> insertImage.bind(plugin)(e)

      $(document).on 'mouseover', 'img', ->
        if !$(this).parent().is('.image-wrapper') && $(this).parents('.aloha-root-editable').length
          initialize($(this))
      
      $(document).on 'click', 'figure.aloha-oer-block .image-edit', ->
        $img = $(this).siblings('img')
        showEditDialog($img)

    uploadImage: (file, el, callback) ->
      plugin = @
      settings = Aloha.require('assorted/assorted-plugin').settings
      xhr = new XMLHttpRequest()
      if xhr.upload and settings.image.uploadurl

        xhr.onload = () ->
          if settings.image.parseresponse
            url = parseresponse(xhr)
          else
            url = JSON.parse(xhr.response).url
          callback(url)

        xhr.open("POST", settings.image.uploadurl, true)
        xhr.setRequestHeader("Cache-Control", "no-cache")
        if settings.image.uploadSinglepart
          xhr.setRequestHeader "Content-Type", ""
          xhr.setRequestHeader "X-File-Name", file.name
          xhr.send file
        else
          f = new FormData()
          f.append settings.image.uploadfield or 'upload', file, file.name
          xhr.send f
  })
