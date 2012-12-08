var nearest_toilet_middleware = require('./middleware/nearest_toilet_middleware');

module.exports = function(app)
{
	app.get('/nearest', nearest_toilet_middleware.retrieve);
};
