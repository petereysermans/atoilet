var toilet_retriever = require('../retrievers/toilet_retriever');

module.exports.retrieve = function(request, response, next)
{
	toilet_retriever.on('done', 
						function(public_toilets) { response.json(public_toilets); });
	toilet_retriever.retrieve();
};
