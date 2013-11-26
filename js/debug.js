$.fn.enableMyDebug = function(){
    return $(this).each(function(){
        var $el = $(this),
            instance = $el.data('mentionsKinder');

        instance.$originalInput.removeClass('mentions-kinder-hidden').addClass('debug-area form-control').attr('readonly', true);
    });
};