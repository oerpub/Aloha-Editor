# To be able to edit math, render in MathJax, and serialize out MathML
# we need to wrap the math element in various elements.
#
# Note: Webkit in linux has a bug where `math` elements are always visible so we wrap it in a hidden `span`
# See http://code.google.com/p/chromium/issues/detail?id=175212

# Example intermediate states:
#
# ### Original DOM
#
#    <math/>

# ### Before MathJax loads (STEP1)
#
#    <span class="math-element aloha-ephemera-wrapper">
#      <span class="mathjax-wrapper aloha-ephemera"> # Note: This element will be removed completely when serialized
#        <math/>
#      </span>
#    </span>

# ### After MathJax loads (STEP2)
#
#    <span class="math-element ...">
#      <span class="mathjax-wrapper ...">
#        <span class="MathJax_Display">...</span>
#        <script type="text/mml">...</script>
#      </span>
#    </span>

# ### After Editor loads (STEP3)
#
#    <span class="math-element ...">
#      <span class="mathjax-wrapper ...">...</span>
#      <span class="mathml-wrapper aloha-ephemera-wrapper">    # This element is to fix the Webkit display bug
#        <math/>
#      </span>
#    </span>


define [ 'aloha', 'aloha/plugin', 'jquery', 'popover/popover-plugin', 'ui/ui', 'css!../../../oer/math/css/math.css' ], (Aloha, Plugin, jQuery, Popover, UI) ->

  EDITOR_HTML = '''
    <div class="math-editor-dialog">
        <div class="math-container">
            <pre><span></span><br></pre>
            <textarea type="text" class="formula" rows="1"
                      placeholder="Insert your math notation here"></textarea>
        </div>
        <div class="footer">
          <span>This is:</span>
          <label class="radio inline">
              <input type="radio" name="mime-type" value="math/asciimath"> ASCIIMath
          </label>
          <label class="radio inline">
              <input type="radio" name="mime-type" value="math/tex"> LaTeX
          </label>
          <label class="radio inline mime-type-mathml">
              <input type="radio" name="mime-type" value="math/mml"> MathML
          </label>
          <label class="cheatsheet-label checkbox inline">
            <input id="cheatsheet-activator" type="checkbox" name="cheatsheet-activator"> Show cheat sheet
          </label>
          <button class="btn btn-primary done">Done</button>
        </div>
    </div>
  '''

  LANGUAGES =
    'math/asciimath': {open: '`', close: '`', raw:false}
    'math/tex': {open: '[TEX_START]', close: '[TEX_END]', raw:false}
    'math/mml': {raw: true}

  MATHML_ANNOTATION_MIME_ENCODINGS    = [ 'math/tex', 'math/asciimath' ]
  MATHML_ANNOTATION_NONMIME_ENCODINGS =
    'tex':       'math/tex'
    'latex':     'math/tex'
    'asciimath': 'math/asciimath'

  TOOLTIP_TEMPLATE = '<div class="aloha-ephemera tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'

  # Wait until Aloha is started before loading MathJax
  # Also, wrap all math in a span/div. MathJax replaces the MathJax element
  # losing all jQuery data attached to it (like popover data, the original Math Formula, etc)
  # add `aloha-ephemera-wrapper` so this span is unwrapped
  Aloha.ready ->
    MathJax.Hub.Configured() if MathJax?

  getMathFor = (id) ->
    jax = MathJax?.Hub.getJaxFor id
    if jax
      mathStr = jax.root.toMathML()
      jQuery(mathStr)

  squirrelMath = ($el) ->
    # `$el` is the `.math-element`

    $mml = getMathFor $el.find('script').attr('id')

    # STEP3
    $el.find('.mathml-wrapper').remove()
    $mml.wrap '<span class="mathml-wrapper aloha-ephemera-wrapper"></span>'
    $el.append $mml.parent()

  Aloha.bind 'aloha-editable-created', (evt, editable) ->
    # Bind ctrl+m to math insert/mathify
    editable.obj.bind 'keydown', 'ctrl+m', (evt) ->
      insertMath()
      evt.preventDefault()

    # STEP1
    $maths = editable.obj.find('math')
    $maths.wrap '<span class="math-element aloha-ephemera-wrapper"><span class="mathjax-wrapper aloha-ephemera"></span></span>'

    # TODO: Explicitly call Mathjax Typeset
    jQuery.each $maths, (i, mml) ->
      $mml = jQuery(mml)
      $mathElement = $mml.parent().parent()
      # replace the MathML with ASCII/LaTeX formula if possible
      mathParts = findFormula $mml
      if mathParts.mimeType in MATHML_ANNOTATION_MIME_ENCODINGS
        $mathElement.find('.mathjax-wrapper').text(LANGUAGES[mathParts.mimeType].open +
                                                   mathParts.formula +
                                                   LANGUAGES[mathParts.mimeType].close)
      triggerMathJax $mathElement, ->
        if mathParts.mimeType in MATHML_ANNOTATION_MIME_ENCODINGS
          addAnnotation $mathElement, mathParts.formula, mathParts.mimeType
        makeCloseIcon $mathElement
        if not $mathElement.next().is '.aloha-ephemera-wrapper'
          # a math meta-element needs to followed by a non-breaking space in a span
          jQuery('<span class="aloha-ephemera-wrapper">&#160;</span>').insertAfter($mathElement)

    # What to when user clicks on math
    jQuery(editable.obj).on 'click.matheditor', '.math-element, .math-element *', (evt) ->
      $el = jQuery(@)

      $el = $el.parents('.math-element') if not $el.is('.math-element')

      # Make sure the math element is never editable
      $el.contentEditable(false)

      # Update what Aloha thinks is the selection
      # Can't just use Aloha.Selection.updateSelection because the thing that was clicked isn't editable
      # and setSelection will just silently return without triggering the selection update.
      range = new GENTICS.Utils.RangeObject()
      range.startContainer = range.endContainer = $el[0]
      range.startOffset = range.endOffset = 0
      Aloha.Selection.rangeObject = range

      #evt.target = evt.currentTarget = $el[0]
      Aloha.trigger('aloha-selection-changed', range)

      # Since the click is on the math-element or its children
      # (the math element is just a little horizontal bar but its children
      # stick out above and below it). Don't handle the same event for each
      # child.
      evt.stopPropagation()

    editable.obj.on('click.matheditor', '.math-element-destroy', (e) ->
      jQuery(e.target).tooltip('destroy')
      $el = jQuery(e.target).closest('.math-element')
      # Though the tooltip was bound to the editor and delegates
      # to these items, you still have to clean it up youself
      $el.trigger('hide').tooltip('destroy').remove()
      Aloha.activeEditable.smartContentChange {type: 'block-change'}
      e.preventDefault()
    )

    # Add hlpful tooltips
    if jQuery.ui and jQuery.ui.tooltip
      # Use jq.ui tooltip
      editable.obj.tooltip(
        items: ".math-element",
        content: -> 'Click anywhere in math to edit it',
        template: TOOLTIP_TEMPLATE)
    else
      # This requires a custom version of jquery-ui, to avoid the conflict
      # between the two .toolbar plugins. This one assumes bootstrap
      # tooltip
      editable.obj.tooltip(
        selector: '.math-element'
        placement: 'top'
        title: 'Click anywhere in math to edit it'
        trigger: 'hover',
        template: TOOLTIP_TEMPLATE)

  insertMath = () ->
    $el = jQuery('<span class="math-element aloha-ephemera-wrapper"><span class="mathjax-wrapper aloha-ephemera">&#160;</span></span>') # nbsp
    range = Aloha.Selection.getRangeObject()
    if range.isCollapsed()
      GENTICS.Utils.Dom.insertIntoDOM $el, range, Aloha.activeEditable.obj
      # Callback opens up the math editor by "clicking" on it
      $el.trigger 'show'
      makeCloseIcon($el)
    else
      # a math meta-element needs to followed by a non-breaking space in a span
      $tail = jQuery('<span class="aloha-ephemera-wrapper">&#160;</span>')
      # Assume the user highlighted ASCIIMath (by putting the text in backticks)
      formula = range.getText()
      $el.find('.mathjax-wrapper').text(LANGUAGES['math/asciimath'].open +
                                        formula +
                                        LANGUAGES['math/asciimath'].close)
      GENTICS.Utils.Dom.removeRange range
      GENTICS.Utils.Dom.insertIntoDOM $el.add($tail), range, Aloha.activeEditable.obj
      triggerMathJax $el, ->
        addAnnotation $el, formula, 'math/asciimath'
        makeCloseIcon($el)

        # This will likely break in IE
        sel = window.getSelection()
        r = sel.getRangeAt(0)
        r.selectNodeContents($tail.parent().get(0))
        r.setEndAfter($tail.get(0))
        r.setStartAfter($tail.get(0))
        sel.removeAllRanges()
        sel.addRange(r)

        # Let aloha know what we've done
        r = new GENTICS.Utils.RangeObject()
        r.update()
        Aloha.Selection.rangeObject = r
        Aloha.activeEditable.smartContentChange {type: 'block-change'}

  # Register the button with an action
  UI.adopt 'insertMath', null,
    click: () -> insertMath()

  # STEP2
  triggerMathJax = ($mathElement, cb) ->
    if MathJax?
      # keep the `.math-element` parent
      # Be sure to squirrel away the MathML because the DOM only contains the HTML+CSS output
      callback = () ->
        squirrelMath $mathElement
        cb?()
      MathJax.Hub.Queue ["Typeset", MathJax.Hub, $mathElement.find('.mathjax-wrapper')[0], callback]
    else
      console.log 'MathJax was not loaded properly'

  cleanupFormula = ($editor, $span, destroy=false) ->
    # If math is empty, remove the box
    if destroy or jQuery.trim($editor.find('.formula').val()).length == 0
      $span.find('.math-element-destroy').tooltip('destroy')
      $span.remove()

  # $span contains the span with LaTeX/ASCIIMath
  buildEditor = ($span) ->
    $editor = jQuery(EDITOR_HTML)

    # If cheat sheet feature not active, remove checkbox
    try
      if not Aloha.settings.plugins.math.cheatsheet
        $editor.find('.cheatsheet-label').remove()
    catch err
      # Default to removing it
      $editor.find('.cheatsheet-label').remove()

    # Bind some actions for the buttons
    $editor.find('.done').on 'click', =>
      if not $span.next().is '.aloha-ephemera-wrapper'
        # a math meta-element needs to followed by a non-breaking space in a span
        jQuery('<span class="aloha-ephemera-wrapper">&#160;</span>').insertAfter($span)
      $span.trigger 'hide'
    $editor.find('.remove').on 'click', =>
      $span.trigger 'hide'
      cleanupFormula($editor, $span, true)

    $formula = $editor.find('.formula')

    # Set the formula in jQuery data if it hasn't been set before
    #$span.data('math-formula', $span.data('math-formula') or $span.attr('data-math-formula') or $span.text())

    mimeType = $span.find('script[type]').attr('type') or 'math/asciimath'
    # tex could be "math/tex; mode=display" so split in the semicolon
    mimeType = mimeType.split(';')[0]

    formula = $span.find('script[type]').html()

    # Set the language and fill in the formula
    $editor.find("input[name=mime-type][value='#{mimeType}']").attr('checked', true)
    $formula.val(formula)

    # Set the hidden pre that causes auto-sizing to the same value
    $editor.find('.math-container pre span').text(formula)

    # If the language isn't MathML then hide the MathML radio
    $editor.find("label.mime-type-mathml").remove() if mimeType != 'math/mml'

    keyTimeout = null
    keyDelay = () ->
      # Try and parse it as ASCIIMath
      formula = jQuery(@).val() # $span.data('math-formula')
      mimeType = $editor.find('input[name=mime-type]:checked').val()

      $mathPoint = $span.children('.mathjax-wrapper')
      if not $mathPoint[0]
        $mathPoint = jQuery('<span class="mathjax-wrapper aloha-ephemera"></span>')
        $span.prepend $mathPoint

      if LANGUAGES[mimeType].raw
        $formula = jQuery(formula)
        $mathPoint.text('').append($formula)
      else
        formulaWrapped = LANGUAGES[mimeType].open + formula + LANGUAGES[mimeType].close
        $mathPoint.text(formulaWrapped)
      triggerMathJax $span, ->
        # Save the Edited text into the math annotation element
        $mathml = $span.find('math')
        if $mathml[0]
          if mimeType in MATHML_ANNOTATION_MIME_ENCODINGS
            addAnnotation $span, formula, mimeType
          makeCloseIcon($span)
        Aloha.activeEditable.smartContentChange {type: 'block-change'}

      # TODO: Async save the input when MathJax correctly parses and typesets the text
      $span.data('math-formula', formula)
      $formula.trigger('focus')

    $formula.on 'input', () ->
        clearTimeout(keyTimeout)
        setTimeout(keyDelay.bind(@), 500)
        $editor.find('.math-container pre span').text(
            $editor.find('.formula').val())

    # Grr, Bootstrap doesn't set the cheked value properly on radios
    radios = $editor.find('input[name=mime-type]')
    radios.on 'click', () ->
        radios.attr('checked', false)
        jQuery(@).attr('checked', true)
        clearTimeout(keyTimeout)
        setTimeout(keyDelay.bind($formula), 500)

    $span.off('shown-popover').on 'shown-popover', () ->
      $span.css 'background-color', '#E5EEF5'
      jQuery('#math-cheatsheet .cheatsheet-open').show()
      $el = jQuery(@)
      tt = $el.data('tooltip')
      tt.hide().disable() if tt
      setTimeout( () ->
        $popover = $el.data('popover')
        $popover.$tip.find('.formula').trigger('focus') if $popover
      , 10)

    $span.off('hidden-popover').on 'hidden-popover', () ->
      jQuery('#math-cheatsheet').trigger 'hide'
      jQuery('#math-cheatsheet .cheatsheet-open').hide()
      $span.css 'background-color', ''
      tt = jQuery(@).data('tooltip')
      tt.enable() if tt
      cleanupFormula($editor, jQuery(@))

    # When cheat sheet is activated, open it
    $editor.find('#cheatsheet-activator').on 'change', (e) ->
      if jQuery(e.target).is(':checked')
        jQuery('#math-cheatsheet').trigger "show"
      else
        jQuery('#math-cheatsheet').trigger "hide"

    $editor

  makeCloseIcon = ($el) ->
    # $el is <span class="math-element">
    $closer = $el.find '.math-element-destroy'
    if not $closer[0]?
      $closer = jQuery('<a class="math-element-destroy aloha-ephemera" title="Delete\u00A0math">&nbsp;</a>')
      if jQuery.ui and jQuery.ui.tooltip
        $closer.tooltip()
      else
        $closer.tooltip(placement: 'bottom', template: TOOLTIP_TEMPLATE)
      $el.append($closer)

  addAnnotation = ($span, formula, mimeType) ->
      # $span is <span class="math-element">
    $mml = $span.find('math')
    if $mml[0]
      $annotation = $mml.find('annotation')
      # ## Finicky MathML structure
      #
      # The generated MathML needs:
      #
      # - A single `<semantics/>` element
      # - The semantics element **must** have _exactly_ 2 children
      # - The second child **must** be the `<annotation/>`

      # If the `<annotation/>` element is not the 2nd child or not in a `<semantics/>`
      # then MathJax will treat it as a '<mtext/>' and not hide it.
      if not $annotation[0]?
        if $mml.children().length > 1 # Wrap math equation in mrow if equation is more than one single child
          $mml.wrapInner('<mrow></mrow>')
        $semantics = $mml.find('semantics')
        if not $semantics[0]
          $mml.wrapInner('<semantics></semantics>')
          $semantics = $mml.find('semantics')
        $annotation = jQuery('<annotation></annotation>').appendTo($semantics)
      $annotation.attr('encoding', mimeType)
      $annotation.text(formula)

  getEncoding = ($annotation) ->
    encoding = $annotation.attr 'encoding'
    #if MATHML_ANNOTATION_MIME_ENCODINGS.contains encoding
    if encoding in MATHML_ANNOTATION_MIME_ENCODINGS
      mimeEncoding = encoding
      return mimeEncoding
    # cannonicalize the non-mime encodings
    encoding = encoding.toLowerCase()
    if encoding of MATHML_ANNOTATION_NONMIME_ENCODINGS
      mimeEncoding = MATHML_ANNOTATION_NONMIME_ENCODINGS[encoding]
      return mimeEncoding
    return null

  # Looking to precisely match the math we create in the editor
  #    <math>
  #      <semantics>
  #        single math element
  #        <annotation />
  #      </semantics>
  #    </math>
  findFormula = ($mml) ->
    formula = null
    mimeType = "math/mml"
    if $mml.children().length is 1
      $firstChild = jQuery($mml.children()[0])
      if $firstChild.is 'semantics'
        $semantics = $firstChild
        if $semantics.children().length is 2
          $secondChild = jQuery($semantics.children()[1])
          if $secondChild.is 'annotation[encoding]'
            $annotation = $secondChild
            encoding = getEncoding $annotation
            formula = $annotation.text()
            if encoding of LANGUAGES
              return { 'mimeType': encoding, 'formula': formula }
    return { 'mimeType': mimeType, 'formula': formula }

  SELECTOR = '.math-element' # ,.MathJax[role="textbox"][aria-readonly="true"],.MathJax_Display[role="textbox"][aria-readonly="true"]'
  Popover.register
    selector: SELECTOR
    populator: buildEditor
    placement: 'top'
    markerclass: 'math-popover'

  # When this plugin is loaded, add some html machinery at the bottom of the
  # window to facilitate the help system, if configured to do so.


  try
    if Aloha.settings.plugins.math.cheatsheet
      help = jQuery('''
        <div id="math-cheatsheet">
          <div class="cheatsheet-open">
            <img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/open-cheat-sheet-01.png' + '''" alt="open" />
          </div>
          <div class="cheatsheet">
            <div class="cheatsheet-close">
              <img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/close-cheat-sheet-01.png' + '''" alt="open" />
            </div>
            <div class="cheatsheet-title"><strong>Math Cheat Sheet</strong>: Copy the "code" that matches the display you want. Paste it into the math entry box above. Adjust as needed.</div>
            <div class="cheatsheet-type">
              <div><input type="radio" name="cs-math-type" id="cs_radio_ascii" value="ascii" checked="checked"> <label for="cs_radio_ascii">ASCIIMath</label></div>
              <div><input type="radio" name="cs-math-type" id="cs_radio_latex" value="latex"> <label for="cs_radio_latex">LaTeX</label></div>
            </div>
            <div class="cheatsheet-values cheatsheet-ascii">
              <table>
                <tr>
                  <td><strong>Display:</strong></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/root2over2.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/pirsq.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/xltoet0.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/infinity.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/aplusxover2.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/choose.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/integral.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/function-01.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/matrix-01.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/sin-01.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/piecewise-01.gif' + '''" /></td>
                  <td><img src="''' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/standard-product-01.gif' + '''" /></td>
                </tr>
                <tr>
                  <td><strong>ASCIIMath code:</strong></td>
                  <td>sqrt(2)/2</td>
                  <td>pir^2  or  pi r^2</td>
                  <td>x &lt;= 0</td>
                  <td>x -&gt; oo</td>
                  <td>((A+X)/2 , (B+Y)/2)</td>
                  <td>sum_{k=0}^{s-1} ((n),(k))</td>
                  <td>int_-2^2 4-x^2dx</td>
                  <td>d/dxf(x)=lim_(h-&gt;0)(f(x+h)-f(x))/h</td>
                  <td>[[a,b],[c,d]]((n),(k))</td>
                  <td>sin^-1(x)</td>
                  <td>x/x={(1,if x!=0),(text{undefined},if x=0):}</td>
                  <td>((a*b))/c</td>
                </tr>
              </table>
            </div>
            <div class="cheatsheet-values cheatsheet-latex">TODO<br /><br /><br /><br /><br /><br /></div>
            <div style="clear: both"></div>
          </div>
        </div>
      ''')
      jQuery('body').append(help)
      opener = help.find('.cheatsheet-open')
    
      help.on 'show', (e) ->
        opener.hide()
        # It says slideDown, but it really causes it to slid up.
        jQuery(@).find('.cheatsheet').slideDown "fast", () ->
          # Adjust the height of the document, to allow scrolling to the
          # bottom
          if Aloha.activeEditable
              a = jQuery(@).height()
              h = Aloha.activeEditable.obj.height()
              h = Aloha.activeEditable.obj.height(a+h+50)
    
      help.on 'hide', (e) ->
        Aloha.activeEditable.obj.height('auto') if Aloha.activeEditable
        jQuery(@).find('.cheatsheet').slideUp "fast", () ->
            opener.show()
    
      opener.on 'click', (e) ->
        help.trigger 'show'
        # Tick the cheat sheet activator tickbox
        jQuery('body > .popover .math-editor-dialog #cheatsheet-activator').prop('checked', true)
    
      help.find('.cheatsheet-close').on "click", (e) ->
        help.trigger "hide"
        # Untick activator
        jQuery('body > .popover .math-editor-dialog #cheatsheet-activator').prop('checked', false)
    
      help.find('.cheatsheet-type input').on "change", (e) ->
        sh = jQuery(e.target).val()
        help.find('.cheatsheet-ascii').hide()
        help.find('.cheatsheet-latex').hide()
        help.find(".cheatsheet-#{sh}").show()
      help.on 'mousedown', (e) ->
        # Stop the click from bubbling up and closing the math plugin
        e.stopPropagation()
  catch err
    # Ignore the error, default to false in other words.
