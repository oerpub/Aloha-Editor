// Generated by CoffeeScript 1.3.3
(function() {

  define(["aloha/core", "jquery", "aloha/contenthandlermanager", "aloha/plugin", "aloha/console", "vendor/sanitize"], function(Aloha, jQuery, ContentHandlerManager, Plugin, console) {
    var SanitizeContentHandler, initSanitize, sanitize;
    initSanitize = function(configAllows) {
      var config, filter, sanitize;
      filter = ["restricted", "basic", "relaxed"];
      config = Aloha.defaults.supports;
      if (Aloha.settings.contentHandler.sanitize && jQuery.inArray(Aloha.settings.contentHandler.sanitize, filter) > -1) {
        config = Aloha.defaults.sanitize[Aloha.settings.contentHandler.sanitize];
      } else {
        config = Aloha.defaults.sanitize.relaxed;
      }
      if (Aloha.settings.contentHandler.allows) {
        config = Aloha.settings.contentHandler.allows;
      }
      if (configAllows) {
        config = configAllows;
      }
      config.filters = [
        function(elem) {
          return elem.contentEditable !== "false";
        }
      ];
      return sanitize = new Sanitize(config, jQuery);
    };
    "use strict";

    sanitize = void 0;
    if (!Aloha.defaults.sanitize) {
      Aloha.defaults.sanitize = {};
    }
    Aloha.defaults.sanitize.restricted = {
      elements: ["b", "em", "i", "strong", "u", "del", "p", "span", "div", "br"]
    };
    Aloha.defaults.sanitize.basic = {
      elements: ["a", "abbr", "b", "blockquote", "br", "cite", "code", "dd", "del", "dl", "dt", "em", "i", "li", "ol", "p", "pre", "q", "small", "strike", "strong", "sub", "sup", "u", "ul"],
      attributes: {
        a: ["href"],
        blockquote: ["cite"],
        q: ["cite"],
        abbr: ["title"]
      },
      protocols: {
        a: {
          href: ["ftp", "http", "https", "mailto", "__relative__"]
        },
        blockquote: {
          cite: ["http", "https", "__relative__"]
        },
        q: {
          cite: ["http", "https", "__relative__"]
        }
      }
    };
    Aloha.defaults.sanitize.relaxed = {
      elements: ["a", "abbr", "b", "blockquote", "br", "caption", "cite", "code", "col", "colgroup", "dd", "del", "dl", "dt", "em", "h1", "h2", "h3", "h4", "h5", "h6", "i", "img", "li", "ol", "p", "pre", "q", "small", "strike", "strong", "sub", "sup", "table", "tbody", "td", "tfoot", "th", "thead", "tr", "u", "ul", "span", "hr", "object", "div"],
      attributes: {
        a: ["href", "title", "id", "class", "target", "data-gentics-aloha-repository", "data-gentics-aloha-object-id"],
        div: ["id", "class", "style"],
        abbr: ["title"],
        blockquote: ["cite"],
        br: ["class"],
        col: ["span", "width"],
        colgroup: ["span", "width"],
        img: ["align", "alt", "height", "src", "title", "width", "class", "data-caption", "data-align", "data-width", "data-original-image"],
        ol: ["start", "type"],
        p: ["class", "style", "id"],
        q: ["cite"],
        table: ["summary", "width"],
        td: ["abbr", "axis", "colspan", "rowspan", "width"],
        th: ["abbr", "axis", "colspan", "rowspan", "scope", "width"],
        ul: ["type"],
        span: ["class", "style", "lang", "xml:lang", "role"]
      },
      protocols: {
        a: {
          href: ["ftp", "http", "https", "mailto", "__relative__"]
        },
        blockquote: {
          cite: ["http", "https", "__relative__"]
        },
        img: {
          src: ["http", "https", "__relative__"]
        },
        q: {
          cite: ["http", "https", "__relative__"]
        }
      }
    };
    /*
      Handle the content from eg. paste action and sanitize the html
      @param content
    */

    SanitizeContentHandler = ContentHandlerManager.createHandler({
      handleContent: function(content) {
        var containerClasses, containerId, contentHandlerConfig, i, sanitizeConfig;
        sanitizeConfig = void 0;
        contentHandlerConfig = void 0;
        if (Aloha.activeEditable && Aloha.settings.contentHandler && Aloha.settings.contentHandler.handler && Aloha.settings.contentHandler.handler.sanitize) {
          if (Aloha.settings.contentHandler.handler.sanitize) {
            contentHandlerConfig = Aloha.settings.contentHandler.handler.sanitize;
          }
          containerId = contentHandlerConfig["#" + Aloha.activeEditable.getId()];
          if (typeof containerId !== "undefined") {
            sanitizeConfig = contentHandlerConfig;
          } else {
            containerClasses = Aloha.activeEditable.obj.attr("class").split(" ");
            i = 0;
            while (i < containerClasses.length) {
              if (typeof contentHandlerConfig["." + containerClasses[i]] !== "undefined") {
                sanitizeConfig = contentHandlerConfig["." + containerClasses[i]];
              }
              i++;
            }
          }
        }
        if (typeof sanitize === "undefined" || typeof sanitizeConfig !== "undefined") {
          initSanitize(sanitizeConfig);
        }
        if (typeof content === "string") {
          content = jQuery("<div>" + content + "</div>").get(0);
        } else {
          if (content instanceof jQuery) {
            content = jQuery("<div>").append(content).get(0);
          }
        }
        return jQuery("<div>").append(sanitize.clean_node(content)).html();
      }
    });
    return SanitizeContentHandler;
  });

}).call(this);