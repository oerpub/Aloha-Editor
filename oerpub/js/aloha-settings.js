(function(window, undefined){

    if (window.Aloha === undefined || window.Aloha === null) {
        var Aloha = window.Aloha = {};
    }

    require.config({ waitSeconds: 42 });

    Aloha.settings = {
        jQuery: window.jQuery,
        logLevels: {'error': true, 'warn': true, 'info': false, 'debug': false},
        errorhandling : true,
        requireConfig: {
            waitSeconds: 42,
            paths: {
                // Override location of jquery-ui and use our own. Because
                // jquery-ui and bootstrap conflict in a few cases (buttons,
                // tooltip) our copy has those removed.
                jqueryui: '../../oerpub/js/jquery-ui-1.9.0.custom-aloha'
            }
        },  
        plugins: {
            assorted: {
                image: {
                    preview: true,
                    uploadurl: '/upload_dnd'
                }
            },
            genericbutton: {
                buttons: [{'id': 'save', 'title': 'Save', 'event': 'swordpushweb.save' }]
            },
            toolbar: {
                formats: {
                  'p':   'Normal Text',
                  'h1':  'Heading',
                  'h2':  'Subheading',
                  'h3':  'SubSubHeading',
                  'pre': 'Code'
                }
            },
            format: {
                config : ['b', 'i', 'u', 'p', 'sub', 'sup', 'h1', 'h2', 'h3']
            },
            table: {
                editables: {
                    '#canvas': { enabled: true },
                    '.title-editor': {enabled: false},
                }
            },
            block: {
                defaults : {
                    '.default-block': {
                    },
                    'figure': {
                        'aloha-block-type': 'FigureBlock'
                    }
                },
                rootTags: ['span', 'div', 'figure'],
                dragdrop: "1"
            },
        },
        bundles: {
            // Path for custom bundle relative from require.js path
            oer: '../plugins/oer'
        }
    };

    Aloha.settings.contentHandler = {
        insertHtml: [ 'word', 'generic', 'oembed'],
        initEditable: [],
        getContents: []
    }


})(window);
