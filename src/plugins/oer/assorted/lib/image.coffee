# Aloha Image Plugin
# * -----------------
# * This plugin handles when the insertImage button is clicked and provides a bubble next to an image when it is selected
#
define ['aloha', 'jquery', 'aloha/plugin', 'image/image-plugin', 'ui/ui', 'semanticblock/semanticblock-plugin', 'css!assorted/css/image.css'], (Aloha, jQuery, AlohaPlugin, Image, UI, semanticBlock) ->

  # This will be prefixed with Aloha.settings.baseUrl
  WARNING_IMAGE_PATH = '/../plugins/oer/image/img/warning.png'

  DIALOG_HTML_CONTAINER = '''
      <form class="plugin image modal hide fade" id="linkModal" tabindex="-1" role="dialog" aria-labelledby="linkModalLabel" aria-hidden="true" data-backdrop="false" />'''

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
              </div>
              <div class="dia-alternative">
                OR
              </div>
              <div class="dia-alternative">
                <span class="upload-url-link btn-link">get image from the Web</span>
              </div>
            </div>
            <div class="placeholder preview hide">
              <img class="preview-image"/>
            </div>
        </div>
        <input type="file" class="upload-image-input" />
        <input type="url" class="upload-url-input" placeholder="Enter URL of image ..."/>
        <div>
          <strong>Image title:</strong><input class="image-title" type="text" placeholder="Shows up above image"></textarea>
        </div>
        <div>
          <strong>Image caption:</strong><input class="image-caption" type="text" placeholder="Shows up below image"></textarea>
        </div>
        <div class="image-alt">
          <div class="forminfo">
            <i class="icon-warning"></i><strong>Describe the image for someone who cannot see it.</strong> This description can be read aloud, making it possible for visually impaired learners to understand the content.
          </div>
          <div>
            <textarea name="alt" type="text" placeholder="Enter description ..."></textarea>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="submit" disabled="true" class="btn btn-primary action insert">Next</button>
        <button class="btn action cancel">Cancel</button>
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
          <ul style="list-style-type: none; padding: 0; margin-left: 0;">
            <li>
            <input type="radio" name=image-source-selection" value="i-own-this" checked="checked">
              <span>I own it (no citation needed)</span><br/>
            </li>
            <li>
            <input type="radio" name=image-source-selection" value="i-got-permission">
              <span>I am allowed to reuse it:</span><br/>
            </li>
            <li>
            <input type="radio" name=image-source-selection" value="i-dont-know">
              <span>I don't know (skip citation for now)</span><br/>
            </li>
          </ul>
        </div>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-primary action insert">Save</button>
        <button class="btn action cancel">Cancel</button>
      </div>'''

  showModalDialog = ($el) ->
      settings = Aloha.require('assorted/assorted-plugin').settings
      root = Aloha.activeEditable.obj
      dialog = jQuery(DIALOG_HTML_CONTAINER)
      dialog.append(jQuery(DIALOG_HTML))

      # Find the dynamic modal elements and bind events to the buttons
      $imageselect = dialog.find('.image-selection')
      $placeholder = dialog.find('.placeholder.preview')
      $uploadImage = dialog.find('.upload-image-input').hide()
      $uploadUrl =   dialog.find('.upload-url-input').hide()
      $submit = dialog.find('.action.insert')

      # If we're editing an image pull in the src.
      # It will be undefined if this is a new image.
      #
      # This variable is updated when one of the following occurs:
      # * selects an image from the filesystem
      # * enters a URL (TODO: Verify it's an image)
      # * drops an image into the drop div

      # On submit $el.attr('src') will point to what is set in this variable
      # preserve the alt text if editing an image
      $img = $el
      imageSource  = $img.attr('src')
      imageAltText = $img.attr('alt')
      $figure  = jQuery( $img.parents('figure')[0] )
      $title   = $figure.find('div.title')
      $caption = $figure.find('figcaption')

      if imageSource
        dialog.find('.action.insert').removeAttr('disabled')

      editing = Boolean(imageSource)

      dialog.find('[name=alt]').val(imageAltText)

      if editing
        dialog.find('.image-options').hide()
        dialog.find('.btn-primary').text('Save')

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
        $uploadImage.show()

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

      $uploadUrl.on 'change', () ->
        $previewImg = $placeholder.find('img')
        url = $uploadUrl.val()
        setImageSource(url)
        if settings.image.preview
          $previewImg.attr 'src', url
          $placeholder.show()
          $imageselect.hide()

      # On save update the actual img tag. Use the submit event because this
      # allows the use of html5 validation.
      deferred = $.Deferred()
      dialog.on 'submit', (evt) =>
        evt.preventDefault() # Don't submit the form

        altAdded = (not $el.attr 'alt') and dialog.find('[name=alt]').val()

        $el.attr 'src', imageSource
        $el.attr 'alt', dialog.find('[name=alt]').val()
        
        if dialog.find('input.image-title').val()
          $title.html dialog.find('input.image-title').val()
        # else probably should remove the $title element
        
        if dialog.find('input.image-caption').val()
          $caption.html dialog.find('input.image-caption').val()
        # else probably should remove the $caption element

        if altAdded
          setThankYou $el.parent()
        else
          setEditText $el.parent()

        deferred.resolve({target: $el[0], files: $uploadImage[0].files})

      dialog.on 'click', '.btn.action.cancel', (evt) =>
        evt.preventDefault() # Don't submit the form
        $el.parents('.semantic-container').remove() unless editing
        deferred.reject(target: $el[0])
        dialog.modal('hide')

      dialog.on 'hidden', (event) ->
        # If hidden without being confirmed/cancelled, reject
        if deferred.state()=='pending'
          deferred.reject(target: $el[0])
        # Clean up after dialog was hidden
        dialog.remove()

      # Return promise, with an added show method
      promise = jQuery.extend true, deferred.promise(),
            show: (title) ->
              if title
                dialog.find('.modal-header h3').text(title)
              dialog.modal 'show'
      return {
          dialog: dialog,
          figure: $figure,
          img: $img,
          promise: promise}

  showModalDialog2 = ($figure, $img, $dialog) ->
      $dialog.children().remove()
      $dialog.append(jQuery(DIALOG_HTML2))

      deferred = $.Deferred()
      $dialog.off('submit').on 'submit', (evt) =>
        evt.preventDefault() # Don't submit the form
        deferred.resolve({target: $img[0]})
        $figure.removeClass('aloha-ephemera')

      $dialog.off('click').on 'click', '.btn.action.cancel', (evt) =>
        evt.preventDefault() # Don't submit the form
        $img.parents('.semantic-container').remove()
        deferred.reject(target: $img[0])
        $dialog.modal('hide')

      return deferred.promise()
            
  insertImage = () ->
    template = $('<figure class="figure aloha-ephemera"><div class="title" /><img /><figcaption /></figuren>')
    semanticBlock.insertAtCursor(template)
    newEl = template.find('img')
    blob = showModalDialog(newEl)
    promise = blob.promise
    $figure = blob.figure
    $img    = blob.img
    $dialog = blob.dialog
    # show the dialog
    promise.show()
    
    source_this_image_dialog = ()=>
      next_promise = showModalDialog2($figure, $img, $dialog)
      return next_promise

    promise.then( (data)=>
      # upload image, if a local file was chosen
      if data.files.length
        newEl.addClass('aloha-image-uploading')
        @uploadImage data.files[0], newEl, (url) ->
          if url
            jQuery(data.target).attr('src', url)
          newEl.removeClass('aloha-image-uploading')
      # once we start using jQuery 1.8+ promise.then() will return a new promise
      # and we can rewrite this as 
      # when(promise).then(...).then(source_this_image_dialog).then(...)
      promise2 = source_this_image_dialog()
      promise2.then( ()=>
        # hide the dialog on the way out
        $dialog.modal 'hide'
        return
      )
    )
    return

  $('body').bind 'aloha-image-resize', ->
    setWidth Image.imageObj

  setWidth = (image) ->
    wrapper = image.parents('.image-wrapper')
    if wrapper.length
      wrapper.css('width', image.css('width'))

  setThankYou = (wrapper) ->
    editDiv = wrapper.children('.image-edit')
    editDiv.html('<i class="icon-edit"></i> Thank You!').removeClass('passive')
    editDiv.css('background', 'lightgreen')
    editDiv.animate({backgroundColor: 'white', opacity: 0}, 2000, 'swing', -> setEditText wrapper)

  setEditText = (wrapper) ->
    alt = wrapper.children('img').attr('alt')
    editDiv = wrapper.children('.image-edit').css('opacity', 1)
    if alt
        editDiv.html('<i class="icon-edit"></i>').addClass('passive')
    else
        editDiv.html('<i class="icon-warning"></i><span class="warning-text">Description missing</span>').removeClass('passive')
        editDiv.off('mouseenter').on 'mouseenter', (e) ->
          editDiv.find('.warning-text').text('Image is missing a description for the visually impaired. Click to provide one.')
        editDiv.off('mouseleave').on 'mouseleave', (e) ->
          editDiv.find('.warning-text').text('Description missing')

  activate = (element) ->
    wrapper = $('<div class="image-wrapper aloha-ephemera-wrapper">').css('width', element.css('width'))
    edit = $('<div class="image-edit aloha-ephemera">')

    $title   = element.find('.title')
    $img     = element.find('img')
    $caption = element.find('figcaption')

    element.children().remove()

    $title.appendTo(element)
    $img.appendTo(element).wrap(wrapper)
    $caption.appendTo(element)

    setEditText element.children('.image-wrapper').prepend(edit)
    element.find('img').load ->
      setWidth $(this)

  deactivate = (element) ->
    # removeClass('figure')
    $figure = element
    $title = $figure.find('div.title')
    $img = $figure.find('img')
    $caption = $figure.find('figcaption')
    $figure.children().remove()
    $figure.append($title)
    $figure.append($img)
    $figure.append($caption)
    return

  # Return config
  AlohaPlugin.create('oer-image', {
    getLabel: -> 'Image'
    activate: activate
    deactivate: deactivate
    selector: '.figure'
    init: () ->
      plugin = @
      UI.adopt 'insertImage-oer', null,
        click: (e) -> insertImage.bind(plugin)(e)

      semanticBlock.register(this)
      semanticBlock.registerEvent 'click', '.aloha-oer-block .image-edit', ->
        img = $(this).siblings('img')
        promise = showModalDialog(img)
        promise.show('Edit image')
        $.when(promise).then(  (data)=>
          data.dialog.modal 'hide'
        )
        return
      return

    uploadImage: (file, el, callback) ->
      plugin = @
      settings = Aloha.require('assorted/assorted-plugin').settings
      xhr = new XMLHttpRequest()
      if xhr.upload
        if not settings.image.uploadurl
          throw new Error("uploadurl not defined")

        xhr.onload = () ->
          if settings.image.parseresponse
            url = parseresponse(xhr)
          else
            url = JSON.parse(xhr.response).url
          callback(url)

        xhr.open("POST", settings.image.uploadurl, true)
        xhr.setRequestHeader("Cache-Control", "no-cache")
        f = new FormData()
        f.append(settings.image.uploadfield or 'upload', file, file.name)
        xhr.send(f)
  })
