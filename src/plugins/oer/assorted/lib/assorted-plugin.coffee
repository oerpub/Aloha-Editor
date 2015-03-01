###
Register a couple of assorted oer plugins
###
define [ 'aloha/plugin', 'jquery', 'overlay/overlay-plugin', './link', './image'], (Plugin, $, Popover, linkConfig, imageConfig) ->
  Plugin.create 'assorted',
    defaultSettings:
        image:
            preview: true
    init: () ->
      @settings = $.extend true, @defaultSettings, @settings
      Popover.register linkConfig
      Popover.register imageConfig
      #Popover.register figureConfig
      #Popover.register figcaptionConfig
