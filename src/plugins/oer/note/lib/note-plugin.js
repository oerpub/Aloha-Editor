// Generated by CoffeeScript 1.3.3
(function() {

  define(['aloha', 'aloha/plugin', 'jquery', 'aloha/ephemera', 'ui/ui', 'ui/button', 'semanticblock/semanticblock-plugin', 'css!note/css/note-plugin.css'], function(Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) {
    var TEMPLATE, TITLE_CONTAINER;
    TEMPLATE = '<div class="note" data-type="note">\n    <div class="title"></div>\n</div>';
    TITLE_CONTAINER = '<div class="title-container dropdown">\n    <a class="type" data-toggle="dropdown"></a>\n    <span class="title" placeholder="Add a title (optional)"></span>\n    <ul class="dropdown-menu">\n        <li><a href="">Note</a></li>\n        <li><a href="">Aside</a></li>\n        <li><a href="">Warning</a></li>\n        <li><a href="">Tip</a></li>\n        <li><a href="">Important</a></li>\n    </ul>\n</div>';
    return Plugin.create('note', {
      init: function() {
        var className, hasTitle, types, _results;
        types = this.settings.classes || {
          note: true
        };
        _results = [];
        for (className in types) {
          hasTitle = types[className];
          semanticBlock.activateHandler(className, function(element) {
            var body, title, titleContainer, titleElement, type;
            if (hasTitle) {
              titleElement = element.children('.title');
              if (titleElement.length) {
                title = titleElement.text();
                titleElement.remove();
              } else {
                title = '';
              }
            }
            type = element.data('type') || className;
            body = element.children();
            element.children().remove();
            if (hasTitle) {
              titleContainer = jQuery(TITLE_CONTAINER);
              titleContainer.find('.title').text(title);
              titleContainer.find('.type').text(type);
              titleContainer.prependTo(element);
              titleContainer.children('.title').aloha();
            }
            return $('<div>').addClass('body').attr('placeholder', "Type the text of your " + className + " here.").append(body).appendTo(element).aloha();
          });
          semanticBlock.deactivateHandler(className, function(element) {
            var body, title;
            body = element.children('.body').children();
            element.children('.body').remove();
            if (hasTitle) {
              title = element.children('.title-container').children('.title').text();
              element.children('.title-container').remove();
              jQuery("<div>").addClass('title').text(title).prependTo(element);
            }
            return element.append(body);
          });
          UI.adopt("insert-" + className, Button, {
            click: function() {
              return semanticBlock.insertAtCursor(TEMPLATE);
            }
          });
          if ('note' === className) {
            _results.push(UI.adopt("insertNote", Button, {
              click: function() {
                return semanticBlock.insertAtCursor(TEMPLATE);
              }
            }));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    });
  });

}).call(this);
