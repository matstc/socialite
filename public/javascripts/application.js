var S = {
	update_grapevine: function(){
		$.get("/comments/recent", null, function(response, status, request){
			var site = $(".comment-overview .updatable");
			site.hide();
			site.html(response);
			S.apply_theme(site);
			site.fadeIn(1000);
		});
	},

	apply_theme: function(node){
		var buttons = node.find('input[type="button"]').add(node.find('input[type="submit"]')).add(node.find('button'));
		buttons.addClass('ui-button ui-widget ui-state-default ui-corner-all');

		var toggleHoverClasses = function(){$(this).toggleClass('ui-state-default'); $(this).toggleClass('ui-state-hover');}
		buttons.bind('mouseover', toggleHoverClasses);
		buttons.bind('mouseout', toggleHoverClasses);

		node.find('ul.bulleted li').each(function(idx, elem){
			$(elem).prepend('<span class="ui-icon ui-icon-stop float-left bullet"></span>');
	    });
	}
};

$(document).ready(function(){
    $('h1').add('h2').not("#error_explanation h2").not(".session-info h1").each(function(idx, elem){
      $(elem).prepend('<span class="ui-icon ui-icon-carat-1-e float-left prefixed-icon"></span>');
    });

	$('h3').not(".comment-overview h3").each(function(idx, elem){
      $(elem).prepend('<span class="ui-icon ui-icon-minusthick float-left prefixed-icon"></span>');
    });

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

	S.apply_theme($(document.body));

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
	
	$("form[action='/comments']").submit(function(){
		setTimeout(S.update_grapevine, 2000);
	});

	setInterval(S.update_grapevine, 120000);

	setTimeout(function(){
		$(".notice").slideUp();
	}, 8000);
});
