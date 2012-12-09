var toilet_retriever = require('../retrievers/toilet_retriever');

module.exports.retrieve = function(request, response, next)
{
	// toilet_retriever.on('done', 
	// 					function(public_toilets) { 
	// 					  // response.header('Content-Type', 'application/json');
	// 					  return response.send(public_toilets); 
	// 					  // response.end()
	// 					}
	// );
	toilet_retriever.retrieve(function(public_toilets) { 
    return response.json(public_toilets); 
  });
	
	// response.render('index', { title: 'nearest' });
};
