// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
    $('.collapsible a').each(function(idx, elem){
      $(elem).prepend('<span class="ui-icon ui-icon-triangle-1-e float-left prefixed-icon"></span>');
    });

    $('.collapsible .collapsible-content').hide();
    $('.collapsible a.collapsible-title').each(function(idx, elem){elem.href ="#";});
    $('.collapsible a.collapsible-title').click(function(){
      var collapsible = $(this).parents('.collapsible');

      collapsible.find('.collapsible-content').toggle();

      var prefixed_icon = collapsible.find('a .prefixed-icon');
      prefixed_icon.toggleClass('ui-icon-triangle-1-e');
      prefixed_icon.toggleClass('ui-icon-triangle-1-s');

      return false;
    });

    $('.auto-focused').focus();

    var buttons = $('input[type="button"]').add('input[type="submit"]').add('button');
    buttons.addClass('ui-button ui-widget ui-state-default ui-corner-all');

    var toggleHoverClasses = function(){$(this).toggleClass('ui-state-default'); $(this).toggleClass('ui-state-hover');}
    buttons.bind('mouseover', toggleHoverClasses);
    buttons.bind('mouseout', toggleHoverClasses);

    $('ul.bulleted li').each(function(idx, elem){
      $(elem).prepend('<span class="ui-icon ui-icon-stop float-left bullet"></span>');
    });

    $('h1').add('h2').not("#error_explanation h2").each(function(idx, elem){
      $(elem).prepend('<span class="ui-icon ui-icon-grip-diagonal-se float-left prefixed-icon"></span>');
    });

    $('body').append('<div class="cleared"></div><br>');

    $("a[href$='.pdf']").each(function(idx, elem){
      $(elem).after('<span class="extension-hint">[pdf]</span>');
    });

    $("a[href$='.jpg'], a[href$='.gif'], a[href$='.png'], a[href$='.bmp']").each(function(idx, elem){
      $(elem).after('<span class="extension-hint">[image]</span>');
    });

    $(document).ajaxError(function(xhr, status, error){
      $(".alert").html(status.responseText);
    });
});
