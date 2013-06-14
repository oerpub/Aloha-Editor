

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
        contentChanged = false;
        inProgress = false,
        addToHistory = function(record) {
            undoStack.push(record);
            redoStack = [];
           
            console.log('adding history'); 
            for (var record in undoStack) {
                console.log(record, jQuery(undoStack[record].rawcontents).find('p').length);
            }

            if (undoStack.length > 10) {
                undoStack.shift();
            } 
        },
        saveSnapshot = function(snapshot) {
            if (!inProgress && (!undoStack.length || (undoStack[undoStack.length-1] != snapshot))) {
                contentChanged = false; 
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

            return {
                contents: contents,
                rawcontents: targetEditable.html()
            };
        },
        handleUndo = function(e) {
            if (e && e.preventDefault) {
                e.preventDefault();
            }

            console.log(contentChanged);
            // add current state to redo stack 
            if (contentChanged) {
                console.log('changed');
                redoStack.push(getSnapshot());
            } else {
                redoStack.push(undoStack.pop());
            }
            
            console.log('undo begin'); 
            for (var record in undoStack) {
                console.log(record, jQuery(undoStack[record].rawcontents).find('p').length);
            }

            if (undoStack.length) {

                inProgress = true;

                // turn off aloha
                targetEditable.mahalo();

                // revert the document
                console.log('setting to index', undoStack.length - 1);
                targetEditable.html(undoStack[undoStack.length-1].contents);

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
                contentChanged = false;
            } 
            console.log('undo end'); 
            for (var record in undoStack) {
                console.log(record, jQuery(undoStack[record].rawcontents).find('p').length);
            }
        }

    Aloha.bind('aloha-editable-created', function(e, editable) {

        if (editable.obj.is('#canvas')) {
            targetEditable = editable.obj; 

            targetEditable.bind('input', function() {
                contentChanged = true;
            });

            Aloha.bind('aloha-smart-content-changed', function() {
                console.log('smart-content-changed');
                saveSnapshot(getSnapshot());
            });

            targetEditable.bind('keydown.aloha.oer-undo', 'ctrl+z', handleUndo);
            targetEditable.bind('keydown.aloha.oer-undo', 'meta+z', handleUndo);
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
                    console.log('redo');
                }
            });
        }
    });

});
