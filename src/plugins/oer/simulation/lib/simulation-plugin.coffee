define ['aloha', 'jquery', 'overlay/overlay-plugin', 'ui/ui'], (Aloha, jQuery, Popover, UI) ->
  
  editable = null

  DIALOG_HTML = '''
    <div class="plugin image modal fade" id="simModal" role="dialog">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h3>Simulations</h3>
          </div>

          <div class="modal-body">
            <h4>Concord iframe URL</h4>
            <div>
              <select id="experiment-url">
                <option value="http://connexions.github.io/simulations/energy-forms-and-changes/">Energy Forms &amp; Changes</option>
                <option value="http://connexions.github.io/simulations/masses-and-springs/">Masses &amp; Springs</option>
                <option value="http://connexions.github.io/simulations/moving-man/">Moving Man</option>
                <option value="http://connexions.github.io/simulations/my-solar-system/">My Solar System</option>
                <option value="http://connexions.github.io/simulations/states-of-matter/">States of Matter</option>
                <option value="http://connexions.github.io/simulations/projectile-motion/">Projectile Motion</option>
                <option value="http://connexions.github.io/simulations/vector-addition/">Vector Addition</option>
                <option value="http://connexions.github.io/simulations/wave-interference/">Wave Interference</option>
              </select>
            </div>
            <div>
              <label>Width: </label>
              <input name="width" type="number" placeholder="Width" required/>
              <label>Height: </label>
              <input name="height" type="number" placeholder="Height" required/>
            </div>
          </div>

          <div class="modal-footer">
            <a href="#" class="btn action insert">Insert</a>
            <a href="#" class="btn" data-dismiss="modal">Cancel</a>
          </div>
        </div>
      </div>
    </div>'''

  showModalDialog = ($el) ->
    editable = Aloha.activeEditable.obj
    dialog = jQuery(DIALOG_HTML)

    #dialog.find('#link-tab-internal').tab('show')
    $save = dialog.find('.link-save')
    $url = dialog.find('#experiment-url')
    $width = dialog.find('*[name=width]')
    $height = dialog.find('*[name=height]')

    # Prepopulate and then focus on it
    $url.val($el.attr('src'))
    $url.focus()


    $width.val($el.attr('width'))
    $height.val($el.attr('height'))

    # Trigger the save
    $save.on 'click', (evt) =>
      evt.preventDefault()
      dialog.trigger('submit')

    dialog.on 'submit', (evt) =>
      evt.preventDefault()

      # Set the source attribute
      $el.attr('src', $url.val())
      dialog.modal('hide')

    dialog.modal('show')
    dialog.on 'hidden', () ->
      dialog.remove()
    return dialog

  selector = 'iframe'

  populator = ($el) ->
      # When a click occurs, the activeEditable is cleared so squirrel it
      editable = Aloha.activeEditable
      $bubble = jQuery('<div class="link-popover"></div>')

      change = jQuery('<button class="btn">Change...</div>').appendTo($bubble)
      # TODO: Convert the mousedown to a click. To do that the aloha-deactivated event need to not hide the bubbles yet and instead fire a 'hide' event
      change.on 'click', =>
        # unsquirrel the activeEditable
        Aloha.activeEditable = editable
        dialog = showModalDialog($el)
      remove = jQuery('<button class="btn btn-danger">Remove</div>').appendTo($bubble)
      remove.on 'click', =>
        $el.remove()
        jQuery(@).popover('hide')
      $bubble.contents()


  UI.adopt 'insertSimulation', null,
    click: (e) ->
      newFrame = jQuery('<iframe frameborder="1" height="960" width="580" scrolling="no"></iframe>')
      dialog = showModalDialog(newFrame)

      # Wait until the dialog is closed before inserting it into the DOM
      # That way if it is cancelled nothing is inserted
      dialog.find('.action.insert').on 'click', =>
        Aloha.activateEditable(editable)
        
        newFrame.attr('src', dialog.find('#experiment-url').val())

        # Either insert a new span around the cursor and open the box or just open the box
        range = Aloha.Selection.getRangeObject()

        # Extend to the whole word 1st
        if range.isCollapsed()
          # if selection is collapsed then extend to the word.
          GENTICS.Utils.Dom.extendToWord(range)

          # insert a link with text here
          GENTICS.Utils.Dom.insertIntoDOM newFrame,
            range,
            Aloha.activeEditable.obj
          range.startContainer = range.endContainer = newFrame.contents()[0]
          range.startOffset = 0
          range.endOffset = newFrame.text().length
          dialog.modal('hide')
        else
          GENTICS.Utils.Dom.addMarkup(range, newFrame, false)


  Popover.register
    hover: true
    selector: selector
    populator: populator
