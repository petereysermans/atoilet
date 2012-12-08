var toilet_retriever = require('../retrievers/toilet_retriever');

module.exports.retrieve = function(request, response, next)
{
	toilet_retriever.on('done', 
						function(public_toilets) { response.write(JSON.stringify(public_toilets));/* response.json(public_toilets); */ response.end(); });
	toilet_retriever.retrieve();
	
	// response.render('index', { title: 'nearest' });
};
