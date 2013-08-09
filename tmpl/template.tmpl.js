module.exports = function anonymous(obj) {

  function escape(html) {
    return String(html)
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  };

  function section(obj, prop, negate, str) {
    var val = obj[prop];
    if ('function' == typeof val) return val.call(obj, str);
    if (negate) val = !val;
    if (val) return str;
    return '';
  };

  return "<header role=\"banner\" id=\"logo\" class=\"container\">\n	<hgroup>\n		<h1><a class=\"ir logo\" href=\"" + escape(obj.homepage) + "\">" + escape(obj.sitename) + "</a></h1>\n	</hgroup>\n</header>"
}