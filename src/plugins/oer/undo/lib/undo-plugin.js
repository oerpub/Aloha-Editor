

define([
    'aloha',
    'aloha/plugin',
    'jquery',
    'ui/ui',
    'ui/button'],
    function(Aloha, Plugin, jQuery, UI, Button) {

    var undoStack = [],
        redoStack = [],
        targetEditable,
        inProgress = false,
        addToHistory = function(record) {
            undoStack.push(record);
            redoStack = [];

            if (undoStack.length > 10) {
                undoStack.shift();
            } 
        },
        addToFuture = function(record) {
            redoStack.push(record);

            if (redoStack.length > 10) {
                redoStack.shift();
            } 
        },
        saveSnapshot = function(snapshot) {
            if (!inProgress && (!undoStack.length || (undoStack[undoStack.length-1] != snapshot))) {
                addToHistory(snapshot);
            }
        }
        getSnapshot = function() {
            var selection = Aloha.Selection.getRangeObject(),
                element;

            if (selection.startContainer) {

                var cursorContainer = selection.startContainer;

                if (cursorContainer.nodeName == '#text') {
                    cursorContainer = cursorContainer.parentNode; 
                }

                jQuery(cursorContainer).attr('cursorposition', selection.endOffset);
                contents = Aloha.getEditableById('canvas').getContents();
                jQuery(cursorContainer).removeAttr('cursorposition');
            } else {
                contents = Aloha.getEditableById('canvas').getContents();
            }

            return contents;
        },
        handleRedo = function(e) {
            if (e && e.preventDefault) {
                e.preventDefault();
            }

            console.log('redolength:', redoStack.length);

            if (redoStack.length) {

                inProgress = true;

                // turn off aloha
                targetEditable.mahalo();

                // revert the document
                targetEditable.html(redoStack[redoStack.length-1]);

                // shuffle snapshots
                undoStack.push(redoStack.pop());

                // turn aloha back on
                targetEditable.aloha();

                // set cursor position
                var cursorElement = targetEditable.find('[cursorposition]');
                if (cursorElement.length) {
                    var cursorOffset = cursorElement.attr('cursorposition'),
                        range = new GENTICS.Utils.RangeObject({
                            startContainer: cursorElement.get(0).childNodes[0],
                            endContainer: cursorElement.get(0).childNodes[0],
                            startOffset: cursorOffset,
                            endOffset: cursorOffset 
                        });

                    targetEditable.focus();
                    range.select();
                    cursorElement.removeAttr('cursorposition');
                }
                
                inProgress = false;
            } 
        },
        handleUndo = function(e) {
            if (e && e.preventDefault) {
                e.preventDefault();
            }

            // add current state to redo stack
            var currentState = getSnapshot(); 
            if (currentState != undoStack[undoStack.length-1]) {
                console.log('changed');
                redoStack.push(currentState);
            } else {
                redoStack.push(undoStack.pop());
            }

            console.log('undostack:',undoStack.length);
            if (undoStack.length) {

                inProgress = true;

                // turn off aloha
                targetEditable.mahalo();

                // revert the document
                console.log('setting to index', undoStack.length - 1);
                targetEditable.html(undoStack[undoStack.length-1]);

                // turn aloha back on
                targetEditable.aloha();

                // set cursor position
                var cursorElement = targetEditable.find('[cursorposition]');
                if (cursorElement.length) {
                    var cursorOffset = cursorElement.attr('cursorposition'),
                        range = new GENTICS.Utils.RangeObject({
                            startContainer: cursorElement.get(0).childNodes[0],
                            endContainer: cursorElement.get(0).childNodes[0],
                            startOffset: cursorOffset,
                            endOffset: cursorOffset 
                        });

                    targetEditable.focus();
                    range.select();
                    cursorElement.removeAttr('cursorposition');
                }
                
                inProgress = false;
            } 
        }

    Aloha.bind('aloha-editable-created', function(e, editable) {

        if (editable.obj.is('#canvas')) {

            if (!targetEditable) {
                targetEditable = editable.obj; 
                saveSnapshot(getSnapshot());
            }

            Aloha.bind('aloha-smart-content-changed', function() {
                console.log('smart-content-changed');
                saveSnapshot(getSnapshot());
            });

            targetEditable.bind('keydown.aloha.oer-undo', 'ctrl+z', handleUndo);
            targetEditable.bind('keydown.aloha.oer-undo', 'meta+z', handleUndo);

            targetEditable.bind('keydown.aloha.oer-redo', 'ctrl+shift+z', handleRedo);
            targetEditable.bind('keydown.aloha.oer-redo', 'meta+shift+z', handleRedo);
        }
         
    });

    return Plugin.create('undo', {

        init: function() {
            UI.adopt('undo', Button, {
                click: function() {
                    handleUndo();
                }
            });
            UI.adopt('redo', Button, {
                click: function() {
                    handleRedo()
                }
            });
        }
    });

});
