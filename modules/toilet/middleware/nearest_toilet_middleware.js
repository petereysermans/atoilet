var toilet_retriever = require('../retrievers/toilet_retriever');

module.exports.retrieve = function(request, response, next)
{
	toilet_retriever.retrieve(
	  function(public_toilets) {
      response.json(public_toilets);
      response.end();
    }
  );
};
