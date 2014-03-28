define [
    'jquery'
    'aloha'
    'aloha/plugin'
    'aloha/contenthandlermanager'
], ($, Aloha, Plugin, ContentHandlerManager) ->

  makeCleaner = (WordHandler, settings) ->
    return ContentHandlerManager.createHandler
      handleContent: (content) ->
        # TODO
        # 1. Do a msword cleanup
        content = WordHandler.handleContent(content)
        $content = $("<div>#{content}</div>")

        # 1.1. Clean up any remaining Mso* classes
        $content.find('*[class*="Mso"]').each (idx, el) ->
          remove = ""
          for c in el.classList
            if /^Mso/.test(c)
              remove = "#{remove} #{c}"
          remove = remove.trim()
          $(el).removeClass(remove) if remove

        # 2. Do additional cleanups for (open|libre)office
        # 2.1. Remove inline styles
        $content.find('*[style]').each (idx, el) ->
          $(el).removeAttr('style')

        # 2.2. Remove links to references #__RefHeading__[...]
        $content.find('a[href^="#"]').contents().unwrap()

        # 2.3. Remove Outline numbering
        # OO has weird way of pasting numbered outline. Number is simply
        # prepended to heading with no space
        $content.find('h1,h2,h3,h4,h5,h6').each (idx, el) ->
          head = $(el).text()
          newhead = head.replace(/^[\d.]+([^ \s\d.])/, '$1')
          $(el).text(newhead) if head != newhead

        # 2.4. If an additional cleanup callback is configured, call it.
        if settings.extra
          settings.extra($content)

        # 3. convert to proper xhtml. We do this by cloning the jquery
        # wrapped dom into an xhtml document. This also properly encodes
        # any entities to their unicode equivalents. Then we serialize the
        # document and chop off the containing body tags.
        xmldoc = document.implementation.createDocument(
          'http://www.w3.org/1999/xhtml', 'body', null)
        $content.contents().clone().each (idx, node) ->
          xmldoc.documentElement.appendChild(node)
        # Serialize, and chop off the wrapping body tags
        xml = (new XMLSerializer()).serializeToString(xmldoc)
        xml = xml.replace(/<\/body>$/, '').replace(/^<body[^>]*>/, '')

        return xml

  Plugin.create 'cleanup',
    init: () ->
      Aloha.require ['contenthandler/wordcontenthandler'], (WordHandler) =>
        ContentHandlerManager.register('cleanup', makeCleaner(WordHandler, @settings))
