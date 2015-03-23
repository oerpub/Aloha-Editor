({
    // This file is copy/pasta'd from build-profile-with-common-extra-plugins.js
    // with additions in `paths` to include the oer plugins (see "OER Plugins")

    //The top level directory that contains your app. If this option is used
    //then it assumed your scripts are in a subdirectory under this path.
    //This option is not required. If it is not specified, then baseUrl
    //below is the anchor point for finding things. If this option is specified,
    //then all the files from the app directory will be copied to the dir:
    //output area, and baseUrl will assume to be a relative path under
    //this directory.
    appDir: "../../src/",

    //By default, all modules are located relative to this path. If baseUrl
    //is not explicitly set, then all modules are loaded relative to
    //the directory that holds the build file. If appDir is set, then
    //baseUrl should be specified as relative to the appDir.
    baseUrl: "lib/",

    //By default all the configuration for optimization happens from the command
    //line or by properties in the a config file, and configuration that was
    //passed to requirejs as part of the app's runtime "main" JS file is *not*
    //considered. However, if you prefer for the that "main" JS file configuration
    //to be read for the build so that you do not have to duplicate the values
    //in a separate configuration, set this property to the location of that
    //main JS file. The first requirejs({}), require({}), requirejs.config({}),
    //or require.config({}) call found in that file will be used.
    //mainConfigFile: '../some/path/to/main.js',

    //Set paths for modules. If relative paths, set relative to baseUrl above.
    //If a special value of "empty:" is used for the path value, then that
    //acts like mapping the path to an empty file. It allows the optimizer to
    //resolve the dependency to path, but then does not include it in the output.
    //Useful to map module names that are to resources on a CDN or other
    //http: URL when running in the browser and during an optimization that
    //file should be skipped because it has no dependencies.
    paths: {
        // These paths are the same setup as in aloha.js.
        // r.js doesn't process dynamic configuration and calls to
        // require() that don't list modules literally, so we need to
        // maintain this duplicate list

        // We don't include Aloha's patched jquery by default, the user
        // should do it himself.
        "jquery": "empty:",
        //"jquery": 'vendor/jquery-1.7.2',

        // We do include Aloha's patched jquery-ui by default, but the
        // user can override it if he is adventurous.
        "jqueryui": '../../oerpub/js/jquery-ui-1.9.0.custom-aloha',

        // For the repository browser
        'PubSub': 'vendor/pubsub/js/pubsub-unminified',
        'Class': 'vendor/class',
        'RepositoryBrowser': 'vendor/repository-browser/js/repository-browser-unminified',
        'jstree': 'vendor/jquery.jstree',              // Mutates jquery
        'jqgrid': 'vendor/jquery.jqgrid',              // Mutates jquery
        'jquery-layout': 'vendor/jquery.layout-1.3.0-rc30.7',     // Mutates jquery
        'jqgrid-locale-en': 'vendor/grid.locale.en', // Mutates jqgrid
        'jqgrid-locale-de': 'vendor/grid.locale.de', // Mutates jqgrid
        'repository-browser-i18n-de': 'vendor/repository-browser/js/repository-browser-unminified',
        'repository-browser-i18n-en': 'vendor/repository-browser/js/repository-browser-unminified',

        // Shortcuts for all common plugins
        "ui": "../plugins/common/ui/lib",
        "ui/vendor": "../plugins/common/ui/vendor",
        "ui/css": "../plugins/common/ui/css",
        "ui/nls": "../plugins/common/ui/nls",
        "ui/res": "../plugins/common/ui/res",
        "link": "../plugins/common/link/lib",
        "link/vendor": "../plugins/common/link/vendor",
        "link/css": "../plugins/common/link/css",
        "link/nls": "../plugins/common/link/nls",
        "link/res": "../plugins/common/link/res",
        // "table": "../plugins/common/table/lib",
        // "table/vendor": "../plugins/common/table/vendor",
        // "table/css": "../plugins/common/table/css",
        // "table/nls": "../plugins/common/table/nls",
        // "table/res": "../plugins/common/table/res",
        "list": "../plugins/common/list/lib",
        "list/vendor": "../plugins/common/list/vendor",
        "list/css": "../plugins/common/list/css",
        "list/nls": "../plugins/common/list/nls",
        "list/res": "../plugins/common/list/res",
        "image": "../plugins/common/image/lib",
        "image/vendor": "../plugins/common/image/vendor",
        "image/css": "../plugins/common/image/css",
        "image/nls": "../plugins/common/image/nls",
        "image/res": "../plugins/common/image/res",
        "highlighteditables": "../plugins/common/highlighteditables/lib",
        "highlighteditables/vendor": "../plugins/common/highlighteditables/vendor",
        "highlighteditables/css": "../plugins/common/highlighteditables/css",
        "highlighteditables/nls": "../plugins/common/highlighteditables/nls",
        "highlighteditables/res": "../plugins/common/highlighteditables/res",
        "format": "../plugins/common/format/lib",
        "format/vendor": "../plugins/common/format/vendor",
        "format/css": "../plugins/common/format/css",
        "format/nls": "../plugins/common/format/nls",
        "format/res": "../plugins/common/format/res",
        "dom-to-xhtml": "../plugins/common/dom-to-xhtml/lib",
        "dom-to-xhtml/vendor": "../plugins/common/dom-to-xhtml/vendor",
        "dom-to-xhtml/css": "../plugins/common/dom-to-xhtml/css",
        "dom-to-xhtml/nls": "../plugins/common/dom-to-xhtml/nls",
        "dom-to-xhtml/res": "../plugins/common/dom-to-xhtml/res",
        "contenthandler": "../plugins/common/contenthandler/lib",
        "contenthandler/vendor": "../plugins/common/contenthandler/vendor",
        "contenthandler/css": "../plugins/common/contenthandler/css",
        "contenthandler/nls": "../plugins/common/contenthandler/nls",
        "contenthandler/res": "../plugins/common/contenthandler/res",
        "characterpicker": "../plugins/common/characterpicker/lib",
        "characterpicker/vendor": "../plugins/common/characterpicker/vendor",
        "characterpicker/css": "../plugins/common/characterpicker/css",
        "characterpicker/nls": "../plugins/common/characterpicker/nls",
        "characterpicker/res": "../plugins/common/characterpicker/res",
        "commands": "../plugins/common/commands/lib",
        "commands/vendor": "../plugins/common/commands/vendor",
        "commands/css": "../plugins/common/commands/css",
        "commands/nls": "../plugins/common/commands/nls",
        "commands/res": "../plugins/common/commands/res",
        "align": "../plugins/common/align/lib",
        "align/vendor": "../plugins/common/align/vendor",
        "align/css": "../plugins/common/align/css",
        "align/nls": "../plugins/common/align/nls",
        "align/res": "../plugins/common/align/res",
        "abbr": "../plugins/common/abbr/lib",
        "abbr/vendor": "../plugins/common/abbr/vendor",
        "abbr/css": "../plugins/common/abbr/css",
        "abbr/nls": "../plugins/common/abbr/nls",
        "abbr/res": "../plugins/common/abbr/res",
        "block": "../plugins/common/block/lib",
        "block/vendor": "../plugins/common/block/vendor",
        "block/css": "../plugins/common/block/css",
        "block/nls": "../plugins/common/block/nls",
        "block/res": "../plugins/common/block/res",
        "horizontalruler": "../plugins/common/horizontalruler/lib",
        "horizontalruler/vendor": "../plugins/common/horizontalruler/vendor",
        "horizontalruler/css": "../plugins/common/horizontalruler/css",
        "horizontalruler/nls": "../plugins/common/horizontalruler/nls",
        "horizontalruler/res": "../plugins/common/horizontalruler/res",
        "undo": "../plugins/common/undo/lib",
        "undo/vendor": "../plugins/common/undo/vendor",
        "undo/css": "../plugins/common/undo/css",
        "undo/nls": "../plugins/common/undo/nls",
        "undo/res": "../plugins/common/undo/res",
        "paste": "../plugins/common/paste/lib",
        "paste/vendor": "../plugins/common/paste/vendor",
        "paste/css": "../plugins/common/paste/css",
        "paste/nls": "../plugins/common/paste/nls",
        "paste/res": "../plugins/common/paste/res",

        // Shortcuts for some often used extra plugins (not all)
        "cite": "../plugins/extra/cite/lib",
        "cite/vendor": "../plugins/extra/cite/vendor",
        "cite/css": "../plugins/extra/cite/css",
        "cite/nls": "../plugins/extra/cite/nls",
        "cite/res": "../plugins/extra/cite/res",
        "flag-icons": "../plugins/extra/flag-icons/lib",
        "flag-icons/vendor": "../plugins/extra/flag-icons/vendor",
        "flag-icons/css": "../plugins/extra/flag-icons/css",
        "flag-icons/nls": "../plugins/extra/flag-icons/nls",
        "flag-icons/res": "../plugins/extra/flag-icons/res",
        "numerated-headers": "../plugins/extra/numerated-headers/lib",
        "numerated-headers/vendor": "../plugins/extra/numerated-headers/vendor",
        "numerated-headers/css": "../plugins/extra/numerated-headers/css",
        "numerated-headers/nls": "../plugins/extra/numerated-headers/nls",
        "numerated-headers/res": "../plugins/extra/numerated-headers/res",
        "formatlesspaste": "../plugins/extra/formatlesspaste/lib",
        "formatlesspaste/vendor": "../plugins/extra/formatlesspaste/vendor",
        "formatlesspaste/css": "../plugins/extra/formatlesspaste/css",
        "formatlesspaste/nls": "../plugins/extra/formatlesspaste/nls",
        "formatlesspaste/res": "../plugins/extra/formatlesspaste/res",
        "linkbrowser": "../plugins/extra/linkbrowser/lib",
        "linkbrowser/vendor": "../plugins/extra/linkbrowser/vendor",
        "linkbrowser/css": "../plugins/extra/linkbrowser/css",
        "linkbrowser/nls": "../plugins/extra/linkbrowser/nls",
        "linkbrowser/res": "../plugins/extra/linkbrowser/res",
        "imagebrowser": "../plugins/extra/imagebrowser/lib",
        "imagebrowser/vendor": "../plugins/extra/imagebrowser/vendor",
        "imagebrowser/css": "../plugins/extra/imagebrowser/css",
        "imagebrowser/nls": "../plugins/extra/imagebrowser/nls",
        "imagebrowser/res": "../plugins/extra/imagebrowser/res",
        "ribbon": "../plugins/extra/ribbon/lib",
        "ribbon/vendor": "../plugins/extra/ribbon/vendor",
        "ribbon/css": "../plugins/extra/ribbon/css",
        "ribbon/nls": "../plugins/extra/ribbon/nls",
        "ribbon/res": "../plugins/extra/ribbon/res",
        "toc": "../plugins/extra/toc/lib",
        "toc/vendor": "../plugins/extra/toc/vendor",
        "toc/css": "../plugins/extra/toc/css",
        "toc/nls": "../plugins/extra/toc/nls",
        "toc/res": "../plugins/extra/toc/res",
        "wai-lang": "../plugins/extra/wai-lang/lib",
        "wai-lang/vendor": "../plugins/extra/wai-lang/vendor",
        "wai-lang/css": "../plugins/extra/wai-lang/css",
        "wai-lang/nls": "../plugins/extra/wai-lang/nls",
        "wai-lang/res": "../plugins/extra/wai-lang/res",
        "headerids": "../plugins/extra/headerids/lib",
        "headerids/vendor": "../plugins/extra/headerids/vendor",
        "headerids/css": "../plugins/extra/headerids/css",
        "headerids/nls": "../plugins/extra/headerids/nls",
        "headerids/res": "../plugins/extra/headerids/res",
        "metaview": "../plugins/extra/metaview/lib",
        "metaview/vendor": "../plugins/extra/metaview/vendor",
        "metaview/css": "../plugins/extra/metaview/css",
        "metaview/nls": "../plugins/extra/metaview/nls",
        "metaview/res": "../plugins/extra/metaview/res",
        "listenforcer": "../plugins/extra/listenforcer/lib",
        "listenforcer/vendor": "../plugins/extra/listenforcer/vendor",
        "listenforcer/css": "../plugins/extra/listenforcer/css",
        "listenforcer/nls": "../plugins/extra/listenforcer/nls",
        "listenforcer/res": "../plugins/extra/listenforcer/res",

        // OER Plugins
        'draganddropfiles': '../plugins/extra/draganddropfiles/lib',
        'cleanup': '../plugins/oer/cleanup/lib',
        'overlay'     : '../plugins/oer/overlay/lib',
        'overlay/css' : '../plugins/oer/overlay/css',
        'toolbar'     : '../plugins/oer/toolbar/lib',
        'toolbar/css' : '../plugins/oer/toolbar/css',
        'figure'     : '../plugins/oer/figure/lib',
        'figure/css' : '../plugins/oer/figure/css',
        'math'     : '../plugins/oer/math/lib',
        'math/css' : '../plugins/oer/math/css',
        'simulation'     : '../plugins/oer/simulation/lib',
        'simulation/css' : '../plugins/oer/simulation/css',
        'assorted' : '../plugins/oer/assorted/lib',
        'assorted/css': '../plugins/oer/assorted/css',
        'note'     : '../plugins/oer/note/lib',
        'note/css'     : '../plugins/oer/note/css',
        'semanticblock': '../plugins/oer/semanticblock/lib',
        'semanticblock/css': '../plugins/oer/semanticblock/css', // Hmm, adding the css directory does not seem to help
        'copy': '../plugins/oer/copy/lib',
        'copy/css': '../plugins/oer/copy/css',
        'definition': '../plugins/oer/definition/lib',
        'definition/css': '../plugins/oer/definition/css',
        'equation': '../plugins/oer/equation/lib',
        'equation/css': '../plugins/oer/equation/css',
        'example': '../plugins/oer/example/lib',
        'example/css': '../plugins/oer/example/css',
        'exercise': '../plugins/oer/exercise/lib',
        'exercise/css': '../plugins/oer/exercise/css',
        'mathcheatsheet': '../plugins/oer/mathcheatsheet/lib',
        'mathcheatsheet/css': '../plugins/oer/mathcheatsheet/css',
        'multipart': '../plugins/oer/multipart/lib',
        'multipart/css': '../plugins/oer/multipart/css',
        'quotation': '../plugins/oer/quotation/lib',
        'quotation/css': '../plugins/oer/quotation/css',
        'table': '../plugins/oer/table/lib',
        'table/css': '../plugins/oer/table/css',
        'media-embed': '../plugins/oer/media-embed/lib',
        'media-embed/css': '../plugins/oer/media-embed/css',


        //Do not forget to add these to aloha.coffee

    },

    //Configure CommonJS packages. See http://requirejs.org/docs/api.html#packages
    //for more information.
    packagePaths: [],
    packages: [],
    // To get CSS files I tried the following but still failed
    // packages: [{
    //     name: 'css',
    //     location: './',
    //     main: 'css'
    // }],


    //The directory path to save the output. If not specified, then
    //the path will default to be a directory called "build" as a sibling
    //to the build file. All relative paths are relative to the build file.
    dir: "../../target/build-profile-with-oer/rjs-output",

    //As of RequireJS 2.0.2, the dir above will be deleted before the
    //build starts again. If you have a big build and are not doing
    //source transforms with onBuildRead/onBuildWrite, then you can
    //set keepBuildDir to true to keep the previous dir. This allows for
    //faster rebuilds, but it could lead to unexpected errors if the
    //built code is transformed in some way.
    keepBuildDir: true,

    //Used to inline i18n resources into the built file. If no locale
    //is specified, i18n resources will not be inlined. Only one locale
    //can be inlined for a build. Root bundles referenced by a build layer
    //will be included in a build layer regardless of locale being set.
    //locale: "en-us",

    //How to optimize all the JS files in the build output directory.
    //Right now only the following values
    //are supported:
    //- "uglify": (default) uses UglifyJS to minify the code.
    //- "closure": uses Google's Closure Compiler in simple optimization
    //mode to minify the code. Only available if running the optimizer using
    //Java.
    //- "closure.keepLines": Same as closure option, but keeps line returns
    //in the minified files.
    //- "none": no minification will be done.
    skipDirOptimize: true,
    optimize: "uglify2",

    //If using UglifyJS for script optimization, these config options can be
    //used to pass configuration values to UglifyJS.
    //See https://github.com/mishoo/UglifyJS for the possible values.
    uglify: {
        toplevel: true,
        ascii_only: true,
        beautify: true,
        max_line_length: 1000
    },

    //If using Closure Compiler for script optimization, these config options
    //can be used to configure Closure Compiler. See the documentation for
    //Closure compiler for more information.
    closure: {
        CompilerOptions: {},
        CompilationLevel: 'SIMPLE_OPTIMIZATIONS',
        loggingLevel: 'WARNING'
    },

    //Allow CSS optimizations. Allowed values:
    //- "standard": @import inlining, comment removal and line returns.
    //Removing line returns may have problems in IE, depending on the type
    //of CSS.
    //- "standard.keepLines": like "standard" but keeps line returns.
    //- "none": skip CSS optimizations.
    //- "standard.keepComments": keeps the file comments, but removes line
    //returns.  (r.js 1.0.8+)
    //- "standard.keepComments.keepLines": keeps the file comments and line
    //returns. (r.js 1.0.8+)
    optimizeCss: "standard",//"standard.keepLines",

    //If optimizeCss is in use, a list of of files to ignore for the @import
    //inlining. The value of this option should be a comma separated list
    //of CSS file names to ignore. The file names should match whatever
    //strings are used in the @import calls.
    cssImportIgnore: null,

    //cssIn is typically used as a command line option. It can be used
    //along with out to optimize a single CSS file.
    //cssIn: "path/to/main.css",
    //out: "path/to/css-optimized.css",

    //Inlines the text for any text! dependencies, to avoid the separate
    //async XMLHttpRequest calls to load those dependencies.
    inlineText: true,

    //Allow "use strict"; be included in the RequireJS files.
    //Default is false because there are not many browsers that can properly
    //process and give errors on code for ES5 strict mode,
    //and there is a lot of legacy code that will not work in strict mode.
    useStrict: false,

    //Specify build pragmas. If the source files contain comments like so:
    //>>excludeStart("fooExclude", pragmas.fooExclude);
    //>>excludeEnd("fooExclude");
    //Then the comments that start with //>> are the build pragmas.
    //excludeStart/excludeEnd and includeStart/includeEnd work, and the
    //the pragmas value to the includeStart or excludeStart lines
    //is evaluated to see if the code between the Start and End pragma
    //lines should be included or excluded. If you have a choice to use
    //"has" code or pragmas, use "has" code instead. Pragmas are harder
    //to read, but they can be a bit more flexible on code removal vs.
    //has-based code, which must follow JavaScript language rules.
    //Pragmas also remove code in non-minified source, where has branch
    //trimming is only done if the code is minified via UglifyJS or
    //Closure Compiler.
    pragmas: {
        alohaLoadInEndClosure: true
    },

    //Skip processing for pragmas.
    skipPragmas: false,

    //If skipModuleInsertion is false, then files that do not use define()
    //to define modules will get a define() placeholder inserted for them.
    //Also, require.pause/resume calls will be inserted.
    //Set it to true to avoid this. This is useful if you are building code that
    //does not use require() in the built project or in the JS files, but you
    //still want to use the optimization tool from RequireJS to concatenate modules
    //together.
    skipModuleInsertion: false,

    //If it is not a one file optimization, scan through all .js files in the
    //output directory for any plugin resource dependencies, and if the plugin
    //supports optimizing them as separate files, optimize them. Can be a
    //slower optimization. Only use if there are some plugins that use things
    //like XMLHttpRequest that do not work across domains, but the built code
    //will be placed on another domain.
    optimizeAllPluginResources: false,

    //Finds require() dependencies inside a require() or define call. By default
    //this value is false, because those resources should be considered dynamic/runtime
    //calls. However, for some optimization scenarios,
    //Introduced in 1.0.3. Previous versions incorrectly found the nested calls
    //by default.
    findNestedDependencies: false,

    //If set to true, any files that were combined into a build layer will be
    //removed from the output folder.
    removeCombined: true,

    // Put CSS in a separate file. None of the common aloha modules include
    // css dependencies, so this should cause only the oer css to be collected
    // into one file, in lib/aloha.css.
    separateCSS: false,

    //List the modules that will be optimized. All their immediate and deep
    //dependencies will be included in the module's file when the build is
    //done. If that module or any of its dependencies includes i18n bundles,
    //only the root bundles will be included unless the locale: section is set above.
    modules: [
        //Just specifying a module name means that module will be converted into
        //a built file that contains all of its dependencies. If that module or any
        //of its dependencies includes i18n bundles, they may not be included in the
        //built file unless the locale: section is set above.
        {
            name: "aloha",

            include: [
                // all common plugins
                "ui/ui-plugin",
                "format/format-plugin",
                "list/list-plugin",
                "image/image-plugin",
                "highlighteditables/highlighteditables-plugin",
                "dom-to-xhtml/dom-to-xhtml-plugin",
                "contenthandler/contenthandler-plugin",
                "block/block-plugin",
                "paste/paste-plugin",

                // OER Plugins
                'draganddropfiles/draganddropfiles-plugin',
                'cleanup/cleanup-plugin',
                'overlay/overlay-plugin',
                'assorted/assorted-plugin',
                'toolbar/toolbar-plugin',
                'math/math-plugin',
                'simulation/simulation-plugin',
                'note/note-plugin',
                'semanticblock/semanticblock-plugin',
                'copy/copy-plugin',
                'definition/definition-plugin',
                'equation/equation-plugin',
                'example/example-plugin',
                'exercise/exercise-plugin',
                'math/math-plugin',
                'mathcheatsheet/mathcheatsheet-plugin',
                'multipart/multipart-plugin',
                'note/note-plugin',
                'quotation/quotation-plugin',
                'table/table-plugin',
                'toolbar/toolbar-plugin',
                'media-embed/media-embed-plugin'
            ]
        },
    ],


    //Another way to use wrap, but uses file paths. This makes it easier
    //to have the start text contain license information and the end text
    //to contain the global variable exports, like
    //window.myGlobal = requirejs('myModule');
    //File paths are relative to the build file, or if running a commmand
    //line build, the current directory.
    wrap: {
        startFile: "closure-start.frag",
        endFile: "closure-end.frag",
    },

    //By default, comments that have a license in them are preserved in the
    //output. However, for a larger built files there could be a lot of
    //comment files that may be better served by having a smaller comment
    //at the top of the file that points to the list of all the licenses.
    //This option will turn off the auto-preservation, but you will need
    //work out how best to surface the license information.
    preserveLicenseComments: false,

    //Sets the logging level. It is a number. If you want "silent" running,
    //set logLevel to 4. From the logger.js file:
    //TRACE: 0,
    //INFO: 1,
    //WARN: 2,
    //ERROR: 3,
    //SILENT: 4
    //Default is 0.
    logLevel: 0,
})
