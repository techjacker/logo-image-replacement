if (typeof require !== 'undefined') {
	var template = require('../tmpl/template.tmpl.js');
}

if (typeof module !== 'undefined' && module.exports) {
	module.exports = template;
}