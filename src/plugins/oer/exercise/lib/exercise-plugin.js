// Generated by CoffeeScript 1.5.0
(function() {

  define(['aloha', 'aloha/plugin', 'jquery', 'aloha/ephemera', 'ui/ui', 'ui/button', 'semanticblock/semanticblock-plugin', 'css!exercise/css/exercise-plugin.css'], function(Aloha, Plugin, jQuery, Ephemera, UI, Button, semanticBlock) {
    var SOLUTION_TEMPLATE, SOLUTION_TYPE_CONTAINER, TEMPLATE, TYPE_CONTAINER;
    TEMPLATE = '<div class="exercise" data-type="exercise">\n    <div class="problem"></div>\n</div>';
    SOLUTION_TEMPLATE = '<div class="solution">\n</div> ';
    TYPE_CONTAINER = '<div class="type-container dropdown">\n    <a class="type" data-toggle="dropdown"></a>\n    <ul class="dropdown-menu">\n        <li><a href="">Exercise</a></li>\n        <li><a href="">Homework</a></li>\n        <li><a href="">Problem</a></li>\n        <li><a href="">Question</a></li>\n        <li><a href="">Task</a></li>\n    </ul>\n</div>';
    SOLUTION_TYPE_CONTAINER = '<div class="type-container dropdown">\n    <a class="type" data-toggle="dropdown"></a>\n    <ul class="dropdown-menu">\n        <li><a href="">Answer</a></li>\n        <li><a href="">Solution</a></li>\n    </ul>\n</div>';
    return Plugin.create('exercise', {
      init: function() {
        semanticBlock.activateHandler('.exercise', function(element) {
          var problem, solutions, type, typeContainer;
          type = element.attr('data-type') || 'exercise';
          problem = element.children('.problem');
          solutions = element.children('.solution');
          element.children().remove();
          typeContainer = jQuery(TYPE_CONTAINER);
          typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1));
          typeContainer.prependTo(element);
          problem.attr('placeholder', "Type the text of your problem here.").appendTo(element).aloha();
          jQuery('<div>').addClass('solutions').appendTo(element);
          jQuery('<div>').addClass('solution-controls').append('<a class="add-solution">Click here to add an answer/solution</a>').append('<a class="solution-toggle"></a>').appendTo(element);
          if (!solutions.length) {
            return element.children('.solution-controls').children('.solution-toggle').hide();
          }
        });
        semanticBlock.deactivateHandler('.exercise', function(element) {
          var problem, solutions;
          problem = element.children('.problem');
          solutions = element.children('.solutions').children();
          if (problem.text() === problem.attr('placeholder')) {
            problem.text('');
          }
          element.children().remove();
          jQuery("<div>").addClass('problem').html(jQuery('<p>').append(problem.html())).appendTo(element);
          return element.append(solutions);
        });
        semanticBlock.activateHandler('.solution', function(element) {
          var body, type, typeContainer;
          type = element.attr('data-type') || 'solution';
          body = element.children();
          element.children().remove();
          typeContainer = jQuery(SOLUTION_TYPE_CONTAINER);
          typeContainer.find('.type').text(type.charAt(0).toUpperCase() + type.slice(1));
          typeContainer.prependTo(element);
          return jQuery('<div>').addClass('body').append(body).appendTo(element).aloha();
        });
        semanticBlock.deactivateHandler('.solution', function(element) {
          var content;
          content = element.children('.body').html();
          element.children().remove();
          return jQuery('<p>').append(content).appendTo(element);
        });
        UI.adopt('insertExercise', Button, {
          click: function() {
            return semanticBlock.insertAtCursor(TEMPLATE);
          }
        });
        semanticBlock.registerEvent('click', '.exercise .solution-controls a.add-solution', function() {
          var controls, exercise;
          exercise = $(this).parents('.exercise').first();
          controls = exercise.children('.solution-controls');
          controls.children('.solution-toggle').text('hide solution').show();
          return semanticBlock.appendElement($(SOLUTION_TEMPLATE), exercise.children('.solutions'));
        });
        semanticBlock.registerEvent('click', '.exercise .solution-controls a.solution-toggle', function() {
          var controls, exercise, solutions;
          exercise = $(this).parents('.exercise').first();
          controls = exercise.children('.solution-controls');
          solutions = exercise.children('.solutions');
          return solutions.slideToggle(function() {
            if (solutions.is(':visible')) {
              return controls.children('.solution-toggle').text('hide solution');
            } else {
              return controls.children('.solution-toggle').text('show solution');
            }
          });
        });
        return semanticBlock.registerEvent('click', '.exercise .semantic-delete', function() {
          var controls, exercise;
          exercise = $(this).parents('.exercise').first();
          controls = exercise.children('.solution-controls');
          controls.children('.add-solution').show();
          if (exercise.children('.solutions').children().length === 1) {
            return controls.children('.solution-toggle').hide();
          }
        });
      }
    });
  });

}).call(this);
