define [
  'aloha'
  'aloha/plugin'
  'jquery'
  'aloha/ephemera'
  'ui/ui'
  'ui/button'
  'figure/figure-plugin'
  'semanticblock/semanticblock-plugin'
  'css!media-embed/css/media-embed-plugin.css'], (Aloha, Plugin, jQuery, Ephemera, UI, Button, Figure, semanticBlock) ->

  DIALOG = '''
<div id="mediaEmbedDialog" class="modal hide fade" tabindex="-1" role="dialog" data-backdrop="false">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
    <h3>Add video, slides or other media</h3>
  </div>
  <div class="modal-body">
    <form>
      <label style="display: inline-block">
        URL: 
        <input type="text" name="videoUrl" size="90">
      </label>
      <button class="btn">Go</button>

      <div class="text-error hide">
        We could not determine how to include the media. Please check the URL for the media and try again or cancel.
      </div>
    </form>
  </div>
  <div class="modal-footer">
    <button class="btn" data-dismiss="modal">Cancel</button>
  </div>
</div>
'''
  CONFIRM_DIALOG = '''
<div id="mediaConfirmEmbedDialog" class="modal hide fade" tabindex="-1" role="dialog" data-backdrop="false">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
    <h3>Add video, slides or other media</h3>
  </div>
  <div class="modal-body">
    <div class="embed-preview"></div>
  </div>
  <div class="modal-footer">
    <button class="btn cancel">Back</button>
    <button class="btn primary embed">Insert Now</button>
  </div>
</div>
'''

  TEMPLATE = '''
<figure>
  <div data-type="title"></div>
  <div data-type="alternates"> 
  </div>
  <meta itemprop="url" content=""/>
  <span itemscope="itemscope" itemtype="http://schema.org/Person" itemprop="author">
      <meta itemprop="name" content="Mr. Bees" />
      <meta itemprop="url" content="http://www.flickr.com/photos/bees/" />
  </span>
  <meta itemprop="accessibilityFeature" content="captions" />
  <figcaption>
    <a itemprop="url" href="">Source</a>: by 
    <a itemprop="author" href=""></a>
  </figcaption>
</figure>
'''

  endpoints =
    default: 'http://noembed.com/embed'
    #vimeo: 'http://vimeo.com/api/oembed.json'
    #slideshare: 'http://www.slideshare.net/api/oembed/2'
    #flickr: 'http://www.flickr.com/services/oembed'

  embed = Plugin.create 'mediaEmbed',

    placeholder: null # Keep track of an inserted place holder

    ignore: '[data-type="title"],[data-type="alternates"],.noembed-embed,.noembed-embed *'

    create: (thing) ->
      $thing = $(TEMPLATE)

      $thing.find('[data-type="title"]').text(thing.title)
      $thing.find('[itemprop="url"]').attr('content', thing.url)
      $thing.find('[itemprop="author"] [itemprop="name"]').attr('content', thing.author)
      $thing.find('[itemprop="author"] [itemprop="url"]').attr('content', thing.authorUrl)
      $thing.find('a[itemprop="author"]').attr('href', thing.authorUrl)
      $thing.find('a[itemprop="author"]').text(thing.author)

      $thing.find('figcaption').append(thing.caption)
      $thing.find('[data-type="alternates"]').html(thing.html)

      $caption = $thing.find('figcaption').remove()
      $figure  = Figure.insertOverPlaceholder($thing.contents(), @placeholder)
      @placeholder = null

      $figure.find('figcaption').find('.aloha-editable').html($caption.contents())

    confirm: (thing) =>
      $dialog = $('#mediaConfirmEmbedDialog')
      $dialog = $(CONFIRM_DIALOG) if not $dialog.length

      $dialog.find('.embed-preview').empty().append(thing.html)

      if $dialog.find('iframe').attr('height') > 350
        $dialog.find('iframe').attr('height', 350)
      if $dialog.find('iframe').attr('width') > 500
        $dialog.find('iframe').attr('width', 500)

      $dialog.find('input,textarea').val('')

      $dialog.find('input[name="figureTitle"]').val(thing.title) if thing.title

      $dialog.find('.cancel').off('click').on 'click', (e) ->
        e.preventDefault(true)
        $dialog.modal 'hide'
        embed.showDialog()

      $dialog.find('.embed').off('.embed').on 'click', (e) ->
        e.preventDefault(true)
        $dialog.modal 'hide'
        embed.create
          url: thing.url
          html: thing.html
          author: thing.author
          authorUrl: thing.authorUrl

      $dialog.find('[data-dismiss]').on 'click', (e) ->
        embed.placeholder.remove()
        embed.placeholder = null
      $dialog.on 'keyup.dismiss.modal', (e) =>
        if e.which == 27
          @placeholder.remove()
          @placeholder = null
      $dialog.modal {show: true}

    embedByUrl: (url) =>
      bits = url.match(/(?:https?:\/\/)?(?:www\.)?([^\.]*)/)
      promise = new $.Deferred()

      if bits.length == 2
        domain = bits[1]

        endpoint = endpoints[domain] || endpoints['default']

        $.ajax(
          url: endpoint,
          data: {format: 'json', url: url}
          dataType: 'json'
        )
        .done (data) ->
          if data.error
            promise.reject()
          else
            promise.resolve()

            embed.confirm
              url: data.url || url
              html: data.html
              title: data.title
              author: data.author_name
              authorUrl: data.author_url
        .fail () =>
          promise.reject()

      promise
 
    showDialog: () ->
      $dialog = $('#mediaEmbedDialog')
      $dialog = $(DIALOG) if not $dialog.length

      $dialog.find('.text-error').hide()
      $dialog.find('input').val('')

      $dialog.find('form').off('submit').submit (e) =>
        e.preventDefault(true)

        @embedByUrl($dialog.find('input[name="videoUrl"]').val())
          .done ->
            $dialog.modal 'hide'
          .fail ->
            $dialog.find('.text-error').show()

      $dialog.find('[data-dismiss]').on 'click', (e) =>
        @placeholder.remove()
        @placeholder = null
      $dialog.on 'keyup.dismiss.modal', (e) =>
        if e.which == 27
          @placeholder.remove()
          @placeholder = null
      $dialog.modal 'show'

    init: () ->
      # Add a listener
      UI.adopt "insert-mediaEmbed", Button,
        click: =>
          @showDialog()

      # For legacy toolbars
      UI.adopt "insertMediaEmbed", Button,
        click: =>
          @placeholder = Figure.insertPlaceholder()
          @showDialog()

      semanticBlock.register(this)



