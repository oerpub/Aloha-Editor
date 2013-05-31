// Generated by CoffeeScript 1.6.2
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['aloha', 'aloha/plugin', 'jquery', 'popover/popover-plugin', 'ui/ui', 'css!../../../oer/math/css/math.css'], function(Aloha, Plugin, jQuery, Popover, UI) {
    var EDITOR_HTML, LANGUAGES, MATHML_ANNOTATION_MIME_ENCODINGS, MATHML_ANNOTATION_NONMIME_ENCODINGS, SELECTOR, TOOLTIP_TEMPLATE, addAnnotation, buildEditor, cleanupFormula, findFormula, getEncoding, getMathFor, help, insertMath, makeCloseIcon, opener, squirrelMath, triggerMathJax;

    EDITOR_HTML = '<div class="math-editor-dialog">\n    <div class="math-container">\n        <pre><span></span><br></pre>\n        <textarea type="text" class="formula" rows="1"\n                  placeholder="Insert your math notation here"></textarea>\n    </div>\n    <div class="footer">\n      <span>This is:</span>\n      <label class="radio inline">\n          <input type="radio" name="mime-type" value="math/asciimath"> ASCIIMath\n      </label>\n      <label class="radio inline">\n          <input type="radio" name="mime-type" value="math/tex"> LaTeX\n      </label>\n      <label class="radio inline mime-type-mathml">\n          <input type="radio" name="mime-type" value="math/mml"> MathML\n      </label>\n      <label class="checkbox inline">\n        <input id="cheatsheet-activator" type="checkbox" name="cheatsheet-activator"> Show cheat sheet\n      </label>\n      <button class="btn btn-primary done">Done</button>\n    </div>\n</div>';
    LANGUAGES = {
      'math/asciimath': {
        open: '`',
        close: '`',
        raw: false
      },
      'math/tex': {
        open: '[TEX_START]',
        close: '[TEX_END]',
        raw: false
      },
      'math/mml': {
        raw: true
      }
    };
    MATHML_ANNOTATION_MIME_ENCODINGS = ['math/tex', 'math/asciimath'];
    MATHML_ANNOTATION_NONMIME_ENCODINGS = {
      'tex': 'math/tex',
      'latex': 'math/tex',
      'asciimath': 'math/asciimath'
    };
    TOOLTIP_TEMPLATE = '<div class="aloha-ephemera tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>';
    Aloha.ready(function() {
      if (typeof MathJax !== "undefined" && MathJax !== null) {
        return MathJax.Hub.Configured();
      }
    });
    getMathFor = function(id) {
      var jax, mathStr;

      jax = typeof MathJax !== "undefined" && MathJax !== null ? MathJax.Hub.getJaxFor(id) : void 0;
      if (jax) {
        mathStr = jax.root.toMathML();
        return jQuery(mathStr);
      }
    };
    squirrelMath = function($el) {
      var $mml;

      $mml = getMathFor($el.find('script').attr('id'));
      $el.find('.mathml-wrapper').remove();
      $mml.wrap('<span class="mathml-wrapper aloha-ephemera-wrapper"></span>');
      return $el.append($mml.parent());
    };
    Aloha.bind('aloha-editable-created', function(evt, editable) {
      var $maths;

      editable.obj.bind('keydown', 'ctrl+m', function(evt) {
        insertMath();
        return evt.preventDefault();
      });
      $maths = editable.obj.find('math');
      $maths.wrap('<span class="math-element aloha-ephemera-wrapper"><span class="mathjax-wrapper aloha-ephemera"></span></span>');
      jQuery.each($maths, function(i, mml) {
        var $mathElement, $mml, mathParts, _ref;

        $mml = jQuery(mml);
        $mathElement = $mml.parent().parent();
        mathParts = findFormula($mml);
        if (_ref = mathParts.mimeType, __indexOf.call(MATHML_ANNOTATION_MIME_ENCODINGS, _ref) >= 0) {
          $mathElement.find('.mathjax-wrapper').text(LANGUAGES[mathParts.mimeType].open + mathParts.formula + LANGUAGES[mathParts.mimeType].close);
        }
        return triggerMathJax($mathElement, function() {
          var _ref1;

          if (_ref1 = mathParts.mimeType, __indexOf.call(MATHML_ANNOTATION_MIME_ENCODINGS, _ref1) >= 0) {
            addAnnotation($mathElement, mathParts.formula, mathParts.mimeType);
          }
          makeCloseIcon($mathElement);
          if (!$mathElement.next().is('.aloha-ephemera-wrapper')) {
            return jQuery('<span class="aloha-ephemera-wrapper">&#160;</span>').insertAfter($mathElement);
          }
        });
      });
      jQuery(editable.obj).on('click.matheditor', '.math-element, .math-element *', function(evt) {
        var $el, range;

        $el = jQuery(this);
        if (!$el.is('.math-element')) {
          $el = $el.parents('.math-element');
        }
        $el.contentEditable(false);
        range = new GENTICS.Utils.RangeObject();
        range.startContainer = range.endContainer = $el[0];
        range.startOffset = range.endOffset = 0;
        Aloha.Selection.rangeObject = range;
        Aloha.trigger('aloha-selection-changed', range);
        return evt.stopPropagation();
      });
      editable.obj.on('click.matheditor', '.math-element-destroy', function(e) {
        var $el;

        jQuery(e.target).tooltip('destroy');
        $el = jQuery(e.target).closest('.math-element');
        $el.trigger('hide').tooltip('destroy').remove();
        Aloha.activeEditable.smartContentChange({
          type: 'block-change'
        });
        return e.preventDefault();
      });
      if (jQuery.ui && jQuery.ui.tooltip) {
        return editable.obj.tooltip({
          items: ".math-element",
          content: function() {
            return 'Click anywhere in math to edit it';
          },
          template: TOOLTIP_TEMPLATE
        });
      } else {
        return editable.obj.tooltip({
          selector: '.math-element',
          placement: 'top',
          title: 'Click anywhere in math to edit it',
          trigger: 'hover',
          template: TOOLTIP_TEMPLATE
        });
      }
    });
    insertMath = function() {
      var $el, $tail, formula, range;

      $el = jQuery('<span class="math-element aloha-ephemera-wrapper"><span class="mathjax-wrapper aloha-ephemera">&#160;</span></span>');
      range = Aloha.Selection.getRangeObject();
      if (range.isCollapsed()) {
        GENTICS.Utils.Dom.insertIntoDOM($el, range, Aloha.activeEditable.obj);
        $el.trigger('show');
        return makeCloseIcon($el);
      } else {
        $tail = jQuery('<span class="aloha-ephemera-wrapper">&#160;</span>');
        formula = range.getText();
        $el.find('.mathjax-wrapper').text(LANGUAGES['math/asciimath'].open + formula + LANGUAGES['math/asciimath'].close);
        GENTICS.Utils.Dom.removeRange(range);
        GENTICS.Utils.Dom.insertIntoDOM($el.add($tail), range, Aloha.activeEditable.obj);
        return triggerMathJax($el, function() {
          var r, sel;

          addAnnotation($el, formula, 'math/asciimath');
          makeCloseIcon($el);
          sel = window.getSelection();
          r = sel.getRangeAt(0);
          r.selectNodeContents($tail.parent().get(0));
          r.setEndAfter($tail.get(0));
          r.setStartAfter($tail.get(0));
          sel.removeAllRanges();
          sel.addRange(r);
          r = new GENTICS.Utils.RangeObject();
          r.update();
          Aloha.Selection.rangeObject = r;
          return Aloha.activeEditable.smartContentChange({
            type: 'block-change'
          });
        });
      }
    };
    UI.adopt('insertMath', null, {
      click: function() {
        return insertMath();
      }
    });
    triggerMathJax = function($mathElement, cb) {
      var callback;

      if (typeof MathJax !== "undefined" && MathJax !== null) {
        callback = function() {
          squirrelMath($mathElement);
          return typeof cb === "function" ? cb() : void 0;
        };
        return MathJax.Hub.Queue(["Typeset", MathJax.Hub, $mathElement.find('.mathjax-wrapper')[0], callback]);
      } else {
        return console.log('MathJax was not loaded properly');
      }
    };
    cleanupFormula = function($editor, $span, destroy) {
      if (destroy == null) {
        destroy = false;
      }
      if (destroy || jQuery.trim($editor.find('.formula').val()).length === 0) {
        $span.find('.math-element-destroy').tooltip('destroy');
        return $span.remove();
      }
    };
    buildEditor = function($span) {
      var $editor, $formula, formula, keyDelay, keyTimeout, mimeType, radios,
        _this = this;

      $editor = jQuery(EDITOR_HTML);
      $editor.find('.done').on('click', function() {
        if (!$span.next().is('.aloha-ephemera-wrapper')) {
          jQuery('<span class="aloha-ephemera-wrapper">&#160;</span>').insertAfter($span);
        }
        return $span.trigger('hide');
      });
      $editor.find('.remove').on('click', function() {
        $span.trigger('hide');
        return cleanupFormula($editor, $span, true);
      });
      $formula = $editor.find('.formula');
      mimeType = $span.find('script[type]').attr('type') || 'math/asciimath';
      mimeType = mimeType.split(';')[0];
      formula = $span.find('script[type]').html();
      $editor.find("input[name=mime-type][value='" + mimeType + "']").attr('checked', true);
      $formula.val(formula);
      $editor.find('.math-container pre span').text(formula);
      if (mimeType !== 'math/mml') {
        $editor.find("label.mime-type-mathml").remove();
      }
      keyTimeout = null;
      keyDelay = function() {
        var $mathPoint, formulaWrapped;

        formula = jQuery(this).val();
        mimeType = $editor.find('input[name=mime-type]:checked').val();
        $mathPoint = $span.children('.mathjax-wrapper');
        if (!$mathPoint[0]) {
          $mathPoint = jQuery('<span class="mathjax-wrapper aloha-ephemera"></span>');
          $span.prepend($mathPoint);
        }
        if (LANGUAGES[mimeType].raw) {
          $formula = jQuery(formula);
          $mathPoint.text('').append($formula);
        } else {
          formulaWrapped = LANGUAGES[mimeType].open + formula + LANGUAGES[mimeType].close;
          $mathPoint.text(formulaWrapped);
        }
        triggerMathJax($span, function() {
          var $mathml;

          $mathml = $span.find('math');
          if ($mathml[0]) {
            if (__indexOf.call(MATHML_ANNOTATION_MIME_ENCODINGS, mimeType) >= 0) {
              addAnnotation($span, formula, mimeType);
            }
            makeCloseIcon($span);
          }
          return Aloha.activeEditable.smartContentChange({
            type: 'block-change'
          });
        });
        $span.data('math-formula', formula);
        return $formula.trigger('focus');
      };
      $formula.on('input', function() {
        clearTimeout(keyTimeout);
        setTimeout(keyDelay.bind(this), 500);
        return $editor.find('.math-container pre span').text($editor.find('.formula').val());
      });
      radios = $editor.find('input[name=mime-type]');
      radios.on('click', function() {
        radios.attr('checked', false);
        jQuery(this).attr('checked', true);
        clearTimeout(keyTimeout);
        return setTimeout(keyDelay.bind($formula), 500);
      });
      $span.off('shown-popover').on('shown-popover', function() {
        var $el, tt;

        $span.css('background-color', '#E5EEF5');
        jQuery('#math-cheatsheet .cheatsheet-open').show();
        $el = jQuery(this);
        tt = $el.data('tooltip');
        if (tt) {
          tt.hide().disable();
        }
        return setTimeout(function() {
          var $popover;

          $popover = $el.data('popover');
          if ($popover) {
            return $popover.$tip.find('.formula').trigger('focus');
          }
        }, 10);
      });
      $span.off('hidden-popover').on('hidden-popover', function() {
        var tt;

        jQuery('#math-cheatsheet .cheatsheet-open').hide();
        jQuery('#math-cheatsheet .cheatsheet').hide();
        $span.css('background-color', '');
        tt = jQuery(this).data('tooltip');
        if (tt) {
          tt.enable();
        }
        return cleanupFormula($editor, jQuery(this));
      });
      $editor.find('#cheatsheet-activator').on('change', function(e) {
        if (jQuery(e.target).is(':checked')) {
          return jQuery('#math-cheatsheet').trigger("show");
        } else {
          return jQuery('#math-cheatsheet').trigger("hide");
        }
      });
      return $editor;
    };
    makeCloseIcon = function($el) {
      var $closer;

      $closer = $el.find('.math-element-destroy');
      if ($closer[0] == null) {
        $closer = jQuery('<a class="math-element-destroy aloha-ephemera" title="Delete\u00A0math">&nbsp;</a>');
        if (jQuery.ui && jQuery.ui.tooltip) {
          $closer.tooltip();
        } else {
          $closer.tooltip({
            placement: 'bottom',
            template: TOOLTIP_TEMPLATE
          });
        }
        return $el.append($closer);
      }
    };
    addAnnotation = function($span, formula, mimeType) {
      var $annotation, $mml, $semantics;

      $mml = $span.find('math');
      if ($mml[0]) {
        $annotation = $mml.find('annotation');
        if ($annotation[0] == null) {
          if ($mml.children().length > 1) {
            $mml.wrapInner('<mrow></mrow>');
          }
          $semantics = $mml.find('semantics');
          if (!$semantics[0]) {
            $mml.wrapInner('<semantics></semantics>');
            $semantics = $mml.find('semantics');
          }
          $annotation = jQuery('<annotation></annotation>').appendTo($semantics);
        }
        $annotation.attr('encoding', mimeType);
        return $annotation.text(formula);
      }
    };
    getEncoding = function($annotation) {
      var encoding, mimeEncoding;

      encoding = $annotation.attr('encoding');
      if (__indexOf.call(MATHML_ANNOTATION_MIME_ENCODINGS, encoding) >= 0) {
        mimeEncoding = encoding;
        return mimeEncoding;
      }
      encoding = encoding.toLowerCase();
      if (encoding in MATHML_ANNOTATION_NONMIME_ENCODINGS) {
        mimeEncoding = MATHML_ANNOTATION_NONMIME_ENCODINGS[encoding];
        return mimeEncoding;
      }
      return null;
    };
    findFormula = function($mml) {
      var $annotation, $firstChild, $secondChild, $semantics, encoding, formula, mimeType;

      formula = null;
      mimeType = "math/mml";
      if ($mml.children().length === 1) {
        $firstChild = jQuery($mml.children()[0]);
        if ($firstChild.is('semantics')) {
          $semantics = $firstChild;
          if ($semantics.children().length === 2) {
            $secondChild = jQuery($semantics.children()[1]);
            if ($secondChild.is('annotation[encoding]')) {
              $annotation = $secondChild;
              encoding = getEncoding($annotation);
              formula = $annotation.text();
              if (encoding in LANGUAGES) {
                return {
                  'mimeType': encoding,
                  'formula': formula
                };
              }
            }
          }
        }
      }
      return {
        'mimeType': mimeType,
        'formula': formula
      };
    };
    SELECTOR = '.math-element';
    Popover.register({
      selector: SELECTOR,
      populator: buildEditor,
      placement: 'top',
      markerclass: 'math-popover'
    });
    help = jQuery('<div id="math-cheatsheet">\n  <div class="cheatsheet-open">\n    <img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/open-cheat-sheet-01.png' + '" alt="open" />\n</div>\n<div class="cheatsheet">\n  <div class="cheatsheet-close">\n    <img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/close-cheat-sheet-01.png' + '" alt="open" />\n</div>\n<div class="cheatsheet-title"><strong>Math Cheat Sheet</strong>: Copy the "code" that matches the display you want. Paste it into the math entry box above. Adjust as needed.</div>\n<div class="cheatsheet-type">\n  <div><input type="radio" name="cs-math-type" id="cs_radio_ascii" value="ascii" checked="checked"> <label for="cs_radio_ascii">ASCIIMath</label></div>\n  <div><input type="radio" name="cs-math-type" id="cs_radio_latex" value="latex"> <label for="cs_radio_latex">LaTeX</label></div>\n</div>\n<div class="cheatsheet-values cheatsheet-ascii">\n  <table>\n    <tr>\n      <td><strong>Display:</strong></td>\n      <td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/root2over2.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/pirsq.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/xltoet0.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/infinity.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/aplusxover2.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/choose.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/integral.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/function-01.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/matrix-01.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/sin-01.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/piecewise-01.gif' + '" /></td>\n<td><img src="' + Aloha.settings.baseUrl + '/../plugins/oer/math/img/standard-product-01.gif' + '" /></td>\n        </tr>\n        <tr>\n          <td><strong>ASCIIMath code:</strong></td>\n          <td>sqrt(2)/2</td>\n          <td>pir^2  or  pi r^2</td>\n          <td>x &lt;= 0</td>\n          <td>x -&gt; oo</td>\n          <td>((A+X)/2 , (B+Y)/2)</td>\n          <td>sum_{k=0}^{s-1} ((n),(k))</td>\n          <td>int_-2^2 4-x^2dx</td>\n          <td>d/dxf(x)=lim_(h-&gt;0)(f(x+h)-f(x))/h</td>\n          <td>[[a,b],[c,d]]((n),(k))</td>\n          <td>sin^-1(x)</td>\n          <td>x/x={(1,if x!=0),(text{undefined},if x=0):}</td>\n          <td>((a*b))/c</td>\n        </tr>\n      </table>\n    </div>\n    <div class="cheatsheet-values cheatsheet-latex">TODO<br /><br /><br /><br /><br /><br /></div>\n    <div style="clear: both"></div>\n  </div>\n</div>');
    jQuery('body').append(help);
    opener = help.find('.cheatsheet-open');
    help.on('show', function(e) {
      opener.hide();
      return jQuery(this).find('.cheatsheet').slideDown("fast");
    });
    help.on('hide', function(e) {
      return jQuery(this).find('.cheatsheet').slideUp("fast", function() {
        return opener.show();
      });
    });
    opener.on('click', function(e) {
      help.trigger('show');
      return jQuery('body > .popover .math-editor-dialog #cheatsheet-activator').prop('checked', true);
    });
    help.find('.cheatsheet-close').on("click", function(e) {
      help.trigger("hide");
      return jQuery('body > .popover .math-editor-dialog #cheatsheet-activator').prop('checked', false);
    });
    help.find('.cheatsheet-type input').on("change", function(e) {
      var sh;

      sh = jQuery(e.target).val();
      help.find('.cheatsheet-ascii').hide();
      help.find('.cheatsheet-latex').hide();
      return help.find(".cheatsheet-" + sh).show();
    });
    return help.on('mousedown', function(e) {
      return e.stopPropagation();
    });
  });

}).call(this);
