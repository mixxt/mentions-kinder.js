escapes = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
  '/': '&#x2F;'
};
escaper = /[&<>"'/]/g

Utils = {
  escape: (text)->
    text.replace escaper, (match)->
      escapes[match]
}