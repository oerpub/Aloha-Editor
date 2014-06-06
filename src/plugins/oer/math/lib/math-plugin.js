// Generated by CoffeeScript 1.7.1
(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['aloha', 'aloha/plugin', 'jquery', 'overlay/overlay-plugin', 'ui/ui', 'copy/copy-plugin', 'css!math/css/math.css'], function(Aloha, Plugin, jQuery, Popover, UI, Copy) {
    var $_editor, EDITOR_HTML, LANGUAGES, MATHML_ANNOTATION_MIME_ENCODINGS, MATHML_ANNOTATION_NONMIME_ENCODINGS, TOOLTIP_TEMPLATE, addAnnotation, buildEditor, cleanupFormula, findFormula, getEncoding, getMathFor, insertMath, insertMathInto, makeCloseIcon, ob, placeCursorAfter, squirrelMath, triggerMathJax;
    EDITOR_HTML = '<div class="math-editor-dialog">\n    <div class="math-container">\n        <pre><span></span><br></pre>\n        <textarea type="text" class="formula" rows="1"\n                  placeholder="Insert your math notation here"></textarea>\n    </div>\n    <div class="footer controls form-inline">\n      <span>This is:</span>\n      <label class="radio inline">\n          <input type="radio" name="mime-type" value="math/asciimath"> ASCIIMath\n      </label>\n      <label class="radio inline">\n          <input type="radio" name="mime-type" value="math/tex"> LaTeX\n      </label>\n      <label class="radio inline mime-type-mathml">\n          <input type="radio" name="mime-type" value="math/mml"> MathML\n      </label>\n      <label class="plaintext-label radio inline">\n          <input type="radio" name="mime-type" value="text/plain"> Plain text\n      </label>\n      <button class="btn btn-default clear">Clear</button>\n      <button class="btn btn-default copy">Copy</button>\n      <button class="btn btn-primary done">Done</button>\n    </div>\n</div>';
    $_editor = jQuery(EDITOR_HTML);
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
      },
      'text/plain': {
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
      return typeof MathJax !== "undefined" && MathJax !== null ? MathJax.Hub.Configured() : void 0;
    });
    placeCursorAfter = function(el) {
      var $tail, n, range, sel;
      n = el.next();
      if (n.is('span.math-element-spaceafter')) {
        $tail = n;
      } else {
        $tail = jQuery('<span class="math-element-spaceafter aloha-ephemera-wrapper"></span>');
        el.after($tail);
      }
      range = document.createRange();
      range.setStart($tail[0], 0);
      range.collapse(true);
      sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
      return el.parents('.aloha-editable').first().focus();
    };
    getMathFor = function(el) {
      var jax;
      jax = typeof MathJax !== "undefined" && MathJax !== null ? MathJax.Hub.getJaxFor(el) : void 0;
      if (jax) {
        return jQuery(jax.root.toMathML());
      }
      return null;
    };
    squirrelMath = function($el) {
      var $mml;
      $mml = getMathFor($el.find('script')[0]);
      if ($mml !== null) {
        $el.find('.mathml-wrapper').remove();
        $mml.wrap('<span class="mathml-wrapper aloha-ephemera-wrapper"></span>');
        return $el.append($mml.parent());
      } else {
        return typeof console !== "undefined" && console !== null ? console.warn($el, 'has no associated Jax. Does this happen too often?') : void 0;
      }
    };
    Aloha.bind('aloha-editable-created', function(evt, editable) {
      var $maths;
      if (editable.obj.is(':not(.aloha-root-editable)')) {
        return;
      }
      editable.obj.on('copy', function(e) {
        var $content, clipboard, content;
        content = e.oerContent || Aloha.getSelection().getRangeAt(0).cloneContents();
        $content = $('<div />').append(content);
        if ($content.has('span.math-element').length && $content.has('script').length) {
          e.preventDefault();
          clipboard = e.clipboardData || e.originalEvent.clipboardData;
          return clipboard.setData('text/oerpub-content', $content.html());
        } else {
          return Copy.buffer($content.html());
        }
      });
      editable.obj.on('paste', function(e) {
        var $content, clipboard, content, math, range;
        clipboard = e.clipboardData || e.originalEvent.clipboardData;
        content = clipboard.getData('text/oerpub-content');
        if (content) {
          e.preventDefault();
          $content = jQuery('<div class="aloha-ephemera-wrapper newly-pasted-content" />').append(content).hide();
          $content.find('*[id]').removeAttr('id');
          range = Aloha.getSelection().getRangeAt(0);
          range.insertNode($content.get(0));
          math = [];
          $content.find('.math-element').each(function(idx, el) {
            var deferred;
            deferred = $.Deferred();
            math.push(deferred);
            return triggerMathJax(jQuery(el), function() {
              return deferred.resolve();
            });
          });
          return $.when.apply($content, math).done(function() {
            return $content.each(function() {
              var $$$;
              $$$ = jQuery(this);
              return $$$.replaceWith($$$.contents());
            });
          });
        }
      });
      editable.obj.bind('keydown', 'ctrl+m', function(evt) {
        insertMath();
        return evt.preventDefault();
      });
      $maths = editable.obj.find('math');
      $maths.wrap('<span class="math-element aloha-ephemera-wrapper" contenteditable="false"><span class="mathjax-wrapper aloha-ephemera"></span></span>');
      jQuery.each($maths, function(i, mml) {
        var $mathElement, $mml, mathParts, _ref;
        $mml = jQuery(mml);
        $mathElement = $mml.parent().parent();
        $mml.clone().wrap('<span class="mathml-wrapper aloha-ephemera-wrapper"></span>').parent().appendTo($mathElement);
        mathParts = findFormula($mml);
        if (_ref = mathParts.mimeType, __indexOf.call(MATHML_ANNOTATION_MIME_ENCODINGS, _ref) >= 0) {
          $mathElement.find('.mathjax-wrapper').text(LANGUAGES[mathParts.mimeType].open + mathParts.formula + LANGUAGES[mathParts.mimeType].close);
        }
        return triggerMathJax($mathElement, function() {
          var _ref1;
          if (_ref1 = mathParts.mimeType, __indexOf.call(MATHML_ANNOTATION_MIME_ENCODINGS, _ref1) >= 0) {
            addAnnotation($mathElement, mathParts.formula, mathParts.mimeType);
          }
          return makeCloseIcon($mathElement);
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
        Aloha.trigger('aloha-selection-changed', [range, evt]);
        return evt.stopPropagation();
      });
      editable.obj.on('click.matheditor', '.math-element-destroy', function(e) {
        var $el;
        jQuery(e.target).tooltip('destroy');
        $el = jQuery(e.target).closest('.math-element');
        $el.siblings('.math-element-spaceafter').remove();
        $el.popover('hide').tooltip('destroy').remove();
        return Aloha.activeEditable.smartContentChange({
          type: 'block-change'
        });
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
    insertMathInto = function($container) {
      var $math;
      $math = jQuery('<span class="math-element aloha-ephemera-wrapper"><span class="mathjax-wrapper aloha-ephemera"></span></span>');
      $container.html($math);
      return $math.trigger('show-popover');
    };
    insertMath = function() {
      var $el, formula, range;
      $el = jQuery('<span class="math-element aloha-ephemera-wrapper"><span class="mathjax-wrapper aloha-ephemera">&#160;</span></span>');
      range = Aloha.Selection.getRangeObject();
      if (range.isCollapsed()) {
        GENTICS.Utils.Dom.insertIntoDOM($el, range, Aloha.activeEditable.obj);
        $el.trigger('show-popover');
        return makeCloseIcon($el);
      } else {
        formula = range.getText();
        $el.find('.mathjax-wrapper').text(LANGUAGES['math/tex'].open + formula + LANGUAGES['math/tex'].close);
        GENTICS.Utils.Dom.removeRange(range);
        GENTICS.Utils.Dom.insertIntoDOM($el, range, Aloha.activeEditable.obj);
        return triggerMathJax($el, function() {
          addAnnotation($el, formula, 'math/tex');
          makeCloseIcon($el);
          Aloha.Selection.preventSelectionChanged();
          placeCursorAfter($el);
          return Aloha.activeEditable.smartContentChange({
            type: 'block-change'
          });
        });
      }
    };
    triggerMathJax = function($mathElement, cb) {
      var callback;
      if (typeof MathJax !== "undefined" && MathJax !== null) {
        callback = function() {
          squirrelMath($mathElement);
          return typeof cb === "function" ? cb() : void 0;
        };
        return MathJax.Hub.Queue(["Typeset", MathJax.Hub, $mathElement.find('.mathjax-wrapper')[0], callback]);
      } else {
        return console && console.log('MathJax was not loaded properly');
      }
    };
    cleanupFormula = function($editor, $span, destroy) {
      if (destroy == null) {
        destroy = false;
      }
      if (destroy || jQuery.trim($editor.find('.formula').val()).length === 0) {
        $span.find('.math-element-destroy').tooltip('destroy');
        $span.siblings('.math-element-spaceafter').remove();
        return $span.remove();
      }
    };
    buildEditor = function($span) {
      var $editor, $formula, formula, keyDelay, keyTimeout, mimeType, radios;
      $editor = $_editor.clone(true);
      if ($span.find('.mathjax-wrapper > *').length === 0) {
        $editor.find('.plaintext-label').remove();
      }
      $editor.find('.done').on('click', (function(_this) {
        return function() {
          $span.popover('hide');
          return placeCursorAfter($span);
        };
      })(this));
      $editor.find('.remove').on('click', (function(_this) {
        return function() {
          $span.popover('hide');
          return cleanupFormula($editor, $span, true);
        };
      })(this));
      $editor.find('.copy').on('click', (function(_this) {
        return function() {
          return Copy.buffer($span.outerHtml(), 'text/oerpub-content');
        };
      })(this));
      $editor.find('.clear').on('click', (function(_this) {
        return function() {
          return $editor.find('.formula').val('');
        };
      })(this));
      $formula = $editor.find('.formula');
      mimeType = $span.find('script[type]').attr('type') || 'math/tex';
      mimeType = mimeType.split(';')[0];
      formula = $span.find('script[type]').html();
      $editor.find("input[name=mime-type][value='" + mimeType + "']").prop('checked', true);
      $formula.val(formula);
      $editor.find('.math-container pre span').text(formula);
      if (mimeType !== 'math/mml') {
        $editor.find("label.mime-type-mathml").remove();
      }
      keyTimeout = null;
      keyDelay = function() {
        var $mathPoint, formulaWrapped, type;
        formula = jQuery(this).val();
        type = $editor.find('input[name=mime-type]:checked').val();
        $mathPoint = $span.children('.mathjax-wrapper').eq(0);
        if (!$mathPoint.length) {
          $mathPoint = jQuery('<span class="mathjax-wrapper aloha-ephemera"></span>');
          $span.prepend($mathPoint);
        }
        if (type === 'text/plain') {
          jQuery('<script type="text/plain"></script>').text(formula).appendTo($span);
          $mathPoint.text(formula);
        } else {
          $span.find('script[type="text/plain"]').remove();
          if (LANGUAGES[type].raw) {
            $formula = jQuery(formula);
            $mathPoint.text('').append($formula);
          } else {
            formulaWrapped = LANGUAGES[type].open + formula + LANGUAGES[type].close;
            $mathPoint.text(formulaWrapped);
          }
          triggerMathJax($span, function() {
            var $mathml;
            $mathml = $span.find('math');
            if ($mathml[0]) {
              if (__indexOf.call(MATHML_ANNOTATION_MIME_ENCODINGS, type) >= 0) {
                addAnnotation($span, formula, type);
              }
              makeCloseIcon($span);
            }
            return Aloha.activeEditable.smartContentChange({
              type: 'block-change'
            });
          });
        }
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
        clearTimeout(keyTimeout);
        return setTimeout(keyDelay.bind($formula), 500);
      });
      $span.off('shown.math').on('shown.math', function() {
        var $el, tt;
        $span.css('background-color', '#E5EEF5');
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
      $span.off('hidden.math').on('hidden.math', function() {
        var tt;
        $span.css('background-color', '');
        tt = jQuery(this).data('tooltip');
        if (tt) {
          tt.enable();
        }
        cleanupFormula($editor, jQuery(this));
        if ($span.find('script[type="text/plain"]').length) {
          return $span.replaceWith($span.find('.mathjax-wrapper').html());
        }
      });
      return $editor;
    };
    makeCloseIcon = function($el) {
      var $closer;
      $closer = $el.find('.math-element-destroy');
      if ($closer[0] == null) {
        $closer = jQuery('<span class="math-element-destroy aloha-ephemera fa fa-times" title="Delete\u00A0math"></span>');
        $closer.on('hidden', function(e) {
          return e.stopPropagation();
        });
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
    UI.adopt('insertMath', null, {
      click: function() {
        return insertMath();
      }
    });
    if (typeof MathJax !== "undefined" && MathJax !== null) {
      MathJax.Callback.Queue(MathJax.Hub.Register.StartupHook('MathMenu Ready'), function() {
        var copyCommand;
        copyCommand = MathJax.Menu.ITEM.COMMAND('Copy Math', function(e, f, g) {
          var $script;
          $script = jQuery(document.getElementById(MathJax.Menu.jax.inputID));
          return Copy.buffer($script.parent().parent().outerHtml(), 'text/oerpub-content');
        });
        return MathJax.Menu.menu.items.unshift(copyCommand);
      });
    }
    ob = {
      selector: '.math-element',
      populator: buildEditor,
      insertMathInto: insertMathInto,
      insertMath: insertMath,
      placement: 'top',
      markerclass: 'math-popover',
      editor: $_editor
    };
    Popover.register(ob);
    return ob;
  });

}).call(this);
