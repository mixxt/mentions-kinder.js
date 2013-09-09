$.fn.enableMyDebug = function(){
    return $(this).each(function(){
        var $el = $(this),
            instance = $el.data('mentionsKinder'),
            $debugArea = $('<textarea class="debug-area form-control" readonly name="'+ instance.$input.attr('name') +'"></textarea>');

        instance.$input.replaceWith($debugArea);
        $debugArea.val(instance.$input.val());
        instance.$input = $debugArea;
    });
};