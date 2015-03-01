# Aloha Link Plugin
# * -----------------
# * This plugin provides a bubble next to a link when it is selected
#
define [
  'aloha',
  'jquery',
  'overlay/overlay-plugin',
  'ui/ui',
  'aloha/console',
  'aloha/ephemera',
  'css!assorted/css/link.css'
], (
  Aloha,
  jQuery,
  Popover,
  UI,
  console,
  Ephemera
) ->

  DIALOG_HTML = '''
    <form class="modal" id="linkModal" tabindex="-1" role="dialog" aria-labelledby="linkModalLabel" aria-hidden="true">
      <div class="modal-dialog">
      <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <h3 id="linkModalLabel">Edit link</h3>
      </div>
      <div class="modal-body">
        <div id="link-text">
          <span>Text to display</span>
          <div>
            <input id="link-contents" class="input-xlarge form-control" type="text" placeholder="Enter a phrase here" required />
          </div>
        </div>

        <hr/>

          <div class="radio">
            <label>
              <input type="radio" name="link-type" value="link-internal"/>Link to a part of this page
            </label>
          </div>
          <select class="link-internal link-input form-control collapse" name="linkinternal" id="link-internal">
            <option value="">None</option>
          </select>
          <div class="radio">
            <label>
              <input type="radio" name="link-type" value="link-external"/>Link to webpage
            </label>
          </div>
          <input class="link-input link-external form-control collapse" id="link-external" placeholder="http://"/>
          <div class="radio">
            <label>
              <input type="radio" name="link-type" value="link-resource"/>Upload a Document and link to it
            </label>
          </div>
          <div class="link-resource collapse">
            <input id="link-resource-input" class="form-control" type="file" placeholder="path/to/file"/>
            <input id="link-resource-url" class="link-input form-control hidden" placeholder="Upload a file first"/>
          </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary link-save">Submit</button>
        <button class="btn" data-dismiss="modal" aria-hidden="true">Cancel</button>
      </div>
      </div>
      </div>
    </form>'''

  # The HTML for the little popover when a link is selected
  DETAILS_HTML = '''
      <span class="link-popover-details">
        <button class="btn-link edit-link" title="Change the link's text, location, or other properties">
          <!-- <i class="fa fa-edit icon-edit"></i> -->
          <span>Edit link...</span>
        </button>
        <button class="btn-link delete-link">
          <!-- <i class="icon-delete"></i> -->
          <span title="Remove the link, leaving just the text">Unlink</span>
        </button>
        <a class="visit-link" target="_blank" title="Visit the link in a new window or tab">
          <i class=""></i>
          <span class="title"></span>
        </a>
      </span>
      <br/>
  '''

  # have ephemera remove the attribute that bootstrap inserts for tooltips
  Ephemera.attributes('data-original-title')


  getTitle = ($el, href) ->
    if $el.is('h1,h2,h3,h4,h5,h6')
      $clone = $el.clone()
      $clone.find('.aloha-ephemera').remove()
      $clone.text()
    else if $el.is('figure')
      caption = $el.find('figcaption')
      caption.text() or 'Figure'
    else if $el.is('table')
      caption = $el.find('caption')
      caption.text() or 'Table'
    else
      console.error('BUG! Trying to find title of unknown DOM element')
      href


  getIcon = (href) ->
    if /^#/.test(href)
      $el = jQuery(href)
      return 'fa fa-paragraph icon-paragraph' if $el.is('h1,h2,h3,h4,h5,h6')
      return 'fa fa-file-image-o icon-image' if $el.is('figure')
      return 'fa fa-table' if $el.is('table')
      return ''
    else
      return 'fa fa-external-link icon-external-link'

  showModalDialog = ($el) ->
      root = Aloha.activeEditable.obj
      dialog = jQuery(DIALOG_HTML)

      # not going to change the backdrop when displaying the modal dialog box
      dialog.attr 'data-backdrop', false

      a = $el.get(0)
      linkContents = dialog.find('#link-contents')
      if a.childNodes.length > 0
        linkContents.val($el.text())

      # Build the link options and then populate one of them.
      linkExternal = dialog.find('.link-external')
      linkInternal = dialog.find('.link-internal')
      linkResource = dialog.find('.link-resource')
      linkResourceInput = dialog.find('#link-resource-input')
      linkResourceUrl = dialog.find('#link-resource-url')
      linkSave     = dialog.find('.link-save')
      radios       = dialog.find('[name="link-type"]')

      # Combination of linkExternal and linkInternal
      linkInput    = dialog.find('.link-input')

      appendOption = ($el, $optGroup, text) ->
        option = jQuery('<option></option>')
        unless $el.attr('id')
          $el.attr('id', GENTICS.Utils.guid())
        href = "##{$el.attr('id')}"
        text = getTitle($el, href)
        option.attr('value', href)
        option.append(text)
        option.appendTo($optGroup)

      orgElements = root.find('h1,h2,h3,h4,h5,h6')
      figuresAndTables = root.find('figure,table')
      orgElements.filter(':not([id])').each ->
        jQuery(@).attr 'id', GENTICS.Utils.guid()


      if orgElements[0]
        $optGroup = jQuery('<optgroup label="Headings"></optgroup>')
        $optGroup.appendTo(linkInternal)

        orgElements.each ->
          item = jQuery(@)
          appendOption item, $optGroup

      if figuresAndTables[0]
        $optGroup = jQuery('<optgroup label="Figures and Tables"></optgroup>')
        $optGroup.appendTo(linkInternal)

        figuresAndTables.each ->
          item = jQuery(@)
          appendOption item, $optGroup

      linkInternal.on 'change', () ->
        linkExternal.val('')
        linkResourceUrl.val('')
        linkSave.toggleClass('disabled', !linkInternal.val())

      linkExternal.on 'change keyup', () ->
        linkInternal.val('')
        linkResourceUrl.val('')
        linkSave.toggleClass('disabled', !linkExternal.val())


      linkResourceUrl.on 'change keyup', () ->
        linkInternal.val('')
        linkExternal.val('')
        linkSave.toggleClass('disabled', !linkResourceUrl.val())


      uploadFile = (file, callback) ->
        settings = Aloha.require('assorted/assorted-plugin').settings
        xhr = new XMLHttpRequest()
        # For testing without a backend to upload to
        # unless settings.image.uploadurl
        #   return callback('/resources/1234567')
        if xhr.upload and settings.image.uploadurl

          xhr.onload = () ->
            if settings.image.parseresponse
              {status, url} = settings.image.parseresponse(xhr)
            else
              url = JSON.parse(xhr.response).url
            callback(status, url)

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

      linkResourceInput.on 'change', () ->
        files = linkResourceInput[0].files
        # Parse the file and if it's an image set the imageSource
        if files.length > 0
          uploadFile files[0], (status, url) ->
            if status is 413
              alert('The file is too large. Please upload a smaller one')
            else
              if url
                linkResourceInput.addClass('hidden')
                linkResourceUrl.val(url)
                linkResourceUrl.removeClass('hidden')
                linkResourceUrl.trigger('change')


      # Activate the current tab
      href = $el.attr('href')

      if not href or /^#/.test(href) and linkInternal.find("option[value='#{href}']").length
        linkInternal.val(href)
        radios.val(['link-internal'])
        linkInternal.addClass('in')
      else if /^\/?resources\/.+/.test(href)
        linkResourceInput.addClass('hidden')
        linkResourceUrl.removeClass('hidden')
        linkResourceUrl.val(href)
        radios.val(['link-resource'])
        linkResource.addClass('in')
      else
        linkExternal.val(href)
        radios.val(['link-external'])
        linkExternal.addClass('in')


      linkSave.toggleClass('disabled', !href)

      massageUrlInput = ($input) ->
        url = $input.val()
        if /^[^\/]*#[^\/]+/.test(url)
          # Inter-Module (page) links are OK (UUID followed by # followed by XML id)
        else if /^\/resources\/[^\/]{32}/.test(url)
          # Links to resources are OK
        else if /^http/.test(url) or /^htp/.test(url) or /^htt/.test(url)
          # not missing.  if not valid, form validation will notify
          # and do not want to add http below in this case
        else
          unless /^https?:\/\//.test(url)
            $input.val("http://#{url}")

      dialog.on 'change', '[name="link-type"]', (evt) ->
        if evt.target.value
          linkExternal.removeClass('in').val('')
          linkInternal.removeClass('in').val('')
          linkResource.removeClass('in')
          linkSave.addClass('disabled')
          switch evt.target.value
            when 'link-external' then linkExternal.addClass('in')
            when 'link-internal' then linkInternal.addClass('in')
            when 'link-resource' then linkResource.addClass('in')

      linkExternal.on 'blur', (evt) ->
        massageUrlInput(linkExternal)

      linkExternal.bind 'keydown', 'return', (evt) ->
        massageUrlInput(linkExternal)

      dialog.on 'submit', (evt) =>
        evt.preventDefault()

        if linkContents.val() and linkContents.val().trim()
          $el.contents().remove()
          $el.append(linkContents.val())

        # Set the href based on the active tab
        href = null
        dialog.find('.link-input').each (i, input) ->
          $input = jQuery(input)
          href = $input.val() if $input.val()

        if href
          $el.attr('href', href)
          dialog.modal('hide')

      dialog.modal('show')
      dialog.on 'hidden.bs.modal', () ->
        dialog.remove()
      dialog


  unlink = ($a) ->
      a = $a.get(0)

      # remove the link's popover HTML et al, before unwrapping the link/anchor
      # see popover-plugin soptOne() method:
      $a.removeData('aloha-bubble-openTimer', 0)
      $a.removeData('aloha-bubble-closeTimer', 0)
      $a.removeData('aloha-bubble-selected', false)
      $a.popover('destroy')

      # create a range based on the anchor node and select it, see GENTICS.Utils.Dom.selectDomNode
      newRange = new GENTICS.Utils.RangeObject()
      newRange.startContainer = newRange.endContainer = a.parentNode
      newRange.startOffset = GENTICS.Utils.Dom.getIndexInParent a
      newRange.endOffset = newRange.startOffset + 1
      newRange.select()

      # remove the anchor but preserve its contents
      preserveContents = true
      GENTICS.Utils.Dom.removeFromDOM a, newRange, preserveContents
      Aloha.activeEditable.smartContentChange type: 'block-change'

      # select the new, colapsed range
      newRange.startContainer = newRange.endContainer
      newRange.startOffset = newRange.endOffset
      newRange.select()
      newRange

  # Don't match links that are marked as ephemera. These are generally UI
  # elements added by other plugins that are removed when the document is
  # serialized and should never constitute a real link.
  selector = 'a:not(.aloha-ephemera)'

  # see http://stackoverflow.com/questions/10903002/shorten-url-for-display-with-beginning-and-end-preserved-firebug-net-panel-st
  shortUrl = (linkurl, l) ->
    l = (if typeof (l) isnt "undefined" then l else 50)
    chunk_l = (l / 2)
    linkurl = linkurl.replace("http://", "")
    linkurl = linkurl.replace("https://", "")
    return linkurl  if linkurl.length <= l
    start_chunk = shortString(linkurl, chunk_l, false)
    end_chunk   = shortString(linkurl, chunk_l, true)
    start_chunk + ".." + end_chunk


  shortString = (s, l, reverse) ->
    stop_chars = [" ", "/", "&"]
    acceptable_shortness = l * 0.80 # When to start looking for stop characters
    reverse = (if typeof (reverse) isnt "undefined" then reverse else false)
    s = (if reverse then s.split("").reverse().join("") else s)
    short_s = ""
    i = 0

    while i < l - 1
      short_s += s[i]
      break  if i >= acceptable_shortness and stop_chars.indexOf(s[i]) >= 0
      i++
    return short_s.split("").reverse().join("")  if reverse
    short_s


  populator = ($el) ->
      # When a click occurs, the activeEditable is cleared so squirrel it
      editable = Aloha.activeEditable
      $bubble = jQuery('<div class="link-popover"></div>')

      href = $el.attr('href')

      details = jQuery DETAILS_HTML
      $bubble.append details

      $edit = details.find '.edit-link'
      $edit.on 'click', ->
          # unsquirrel the activeEditable
          Aloha.activeEditable = editable
          dialog = showModalDialog($el)

      $remove = details.find '.delete-link'
      $remove.on 'click', ->
          # unsquirrel the activeEditable
          Aloha.activeEditable = editable
          unlink($el)

      # Fill in the link "Tooltip".
      # For external links make them open in a new window and
      # for internal links hide the "external link" icon.
      $linkTooltip = details.find('.visit-link')
      $linkTooltip.attr 'href', href

      $linkTooltip.find('i').addClass(getIcon(href))
      if /^#/.test(href)
        $linkTooltip.removeAttr('target')
        $linkTooltip.find('.title').text(getTitle(jQuery(href), href))
      else
        $linkTooltip.find('.title').text shortUrl(href,30)


      $bubble.contents()


  getContainerAnchor = (a) ->
    el = a
    while el
      return el if el.nodeName.toLowerCase() is "a"
      el = el.parentNode
    false


  UI.adopt 'insertLink', null,
    click: () ->
      editable = Aloha.activeEditable

      # if range => selection is an anchor / link
      #   do not create a new link, use existing link in call to showModalDialog()
      # else
      #   create a new link
      #   extend selection to word boundaries, range.select()
      #   get text from range/selection
      #   call showModalDialog with text and empty link
      # endif

      range = Aloha.Selection.getRangeObject()
      if range.startContainer is range.endContainer
        a = getContainerAnchor range.startContainer
        if a
          # want to prevent creating links within links so if the selection
          # is contained within a link we edit that link
          $a = jQuery a
          range.startContainer = range.endContainer = a
          range.startOffset = 0
          range.endOffset = a.childNodes.length
          dialog = showModalDialog $a
        else
          # creating a new link aka inserting a new link
          GENTICS.Utils.Dom.extendToWord range
          range.select()
          $a = jQuery '<a href="" class="aloha-new-link"></a>'
          linkText = if range.isCollapsed() then "" else range.getText()
          $a.append linkText
          dialog = showModalDialog $a
      else
        # link must be within a single container.
        # user needs to modify their selection and try again
        return

      # Wait until the dialog is closed before inserting it into the DOM
      # That way if it is cancelled nothing is inserted
      dialog.on 'hidden.bs.modal', =>

        Aloha.activeEditable = editable

        # link is now populated with dialog box values.
        # Case 1: link is an existing link and we are good to go
        # Case 2: link is a new link and needs to replace the selected text

        if $a.hasClass 'aloha-new-link'
          # this is a new link

          # If the user cancelled then don't create the link
          if not $a.attr 'href'
            return

          # Either insert a new span around the cursor and open the box
          # or just open the box
          range = Aloha.Selection.getRangeObject()

          if range.isCollapsed()
            # insert a link with text here
            GENTICS.Utils.Dom.insertIntoDOM $a,
              range,
              Aloha.activeEditable.obj
            range.startContainer = range.endContainer = $a.contents()[0]
            range.startOffset = 0
            range.endOffset = $a.text().length
          else
            GENTICS.Utils.Dom.removeRange range
            GENTICS.Utils.Dom.insertIntoDOM $a, range, Aloha.activeEditable.obj

          # addMarkup takes a template so we need to look up the inserted object
          #   and remove the marker class
          newLink = Aloha.activeEditable.obj.find '.aloha-new-link'
          newLink.removeClass 'aloha-new-link'

          # Tell Aloha that we changed something
          editable.smartContentChange type: 'block-change'


  # Prevent default on links as the bubble out of the editor. This signals
  # any other machinery (or the browser) that we handled the event already.
  Aloha.bind 'aloha-editable-created', (event, editable) ->
    editable.obj.on 'click', 'a', (e)->
      e.preventDefault()

  # Return config
  selector: selector
  populator: populator
  markerclass: 'link-popover'
