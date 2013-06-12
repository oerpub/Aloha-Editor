

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
           
            console.log('adding history'); 
            for (var record in undoStack) {
                console.log(record, jQuery(undoStack[record]).find('p').length);
            }

            if (undoStack.length > 10) {
                undoStack.shift();
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
                record = Aloha.getEditableById('canvas').getContents();
                jQuery(cursorContainer).removeAttr('cursorposition');
            } else {
                record = targetEditable.clone();
            }

            return record;
        },
        handleUndo = function(e) {
            e.preventDefault();

            var snapshot = getSnapshot();
            // add current state to redo stack 
            if (undoStack[undoStack.length-1] != snapshot) {
                console.log('here');
                var currentState = snapshot;
            } else {
                var currentState = undoStack.pop();
            }
            
            console.log('undo begin'); 
            for (var record in undoStack) {
                console.log(record, jQuery(undoStack[record]).find('p').length);
            }

            if (undoStack.length) {

                redoStack.push(currentState);

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
            console.log('undo end'); 
            for (var record in undoStack) {
                console.log(record, undoStack[record].find('p').length);
            }
        }

    Aloha.bind('aloha-editable-created', function(e, editable) {

        if (editable.obj.is('#canvas')) {
            targetEditable = editable.obj; 

            Aloha.bind('aloha-smart-content-changed', function() {
                saveSnapshot(getSnapshot());
            });

            targetEditable.bind('keydown.aloha.oer-undo', 'ctrl+z', handleUndo);
            targetEditable.bind('keydown.aloha.oer-undo', 'meta+z', handleUndo);
        }
         
    });

    return Plugin.create('undo', {

        init: function() {

            console.log('undo');
        }
    });

});
