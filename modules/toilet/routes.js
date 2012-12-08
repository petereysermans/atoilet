var nearest_toilet_middleware = require('./middleware/nearest_toilet_middleware');

module.exports = function(app)
{
	app.get('/nearest.json', nearest_toilet_middleware.retrieve);
};
