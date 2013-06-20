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
        snapshotsAreSimilar = function(snap1, snap2) {

            var $snap1 = jQuery(snap1),
                $snap2 = jQuery(snap2);

            $snap1.find('[cursorposition]').each(function() {
                jQuery(this).removeAttr('cursorposition');
            });
            $snap2.find('[cursorposition]').each(function() {
                jQuery(this).removeAttr('cursorposition');
            });

            return $snap1.html() == $snap2.html();
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
        
            // need a minimum of one thing in the undo stack to take action here
            if (undoStack.length) {

                // get current state of the editor
                var currentState = getSnapshot();

                // if the current state and the last snapshot are different then
                // we just want to revert back to the last snapshot.
                if (snapshotsAreSimilar(currentState, undoStack[undoStack.length-1])) {
                    console.log('changed');
                    redoStack.push(currentState);

                // if the snapshots are the same we move the most recent one over to the 
                // redo stack and revert to the one before, this requires at least two
                // things in the undo stack.
                } else if (undoStack.length > 1) {
                    redoStack.push(undoStack.pop());
                // if the above case fails then we don't have enough information to 
                // preform an undo
                } else {
                    return false;
                }

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
