var public_toilets_data = require('../data/public_toilet.json').openbaartoilet,
	EventEmitter = require('events').EventEmitter,
	util = require('util');

var ToiletRetriever = function()
{
};

util.inherits(ToiletRetriever, EventEmitter);

/** Converts numeric degrees to radians */
if(typeof(Number.prototype.toRad) === "undefined") {
    Number.prototype.toRad = function () {
        return this * Math.PI / 180;
    }
}

// start and end are objects with latitude and longitude
//decimals (default 2) is number of decimals in the output
//return is distance in kilometers. 
ToiletRetriever.prototype.getDistance = function(start, end, decimals) {
    decimals = decimals || 2;
    var earthRadius = 6371; // km
    lat1 = parseFloat(start.lat);
    lat2 = parseFloat(end.lat);
    lon1 = parseFloat(start.long);
    lon2 = parseFloat(end.long);

    var dLat = (lat2 - lat1).toRad();
    var dLon = (lon2 - lon1).toRad();
    var lat1 = lat1.toRad();
    var lat2 = lat2.toRad();

    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = earthRadius * c;
    return Math.round(d * Math.pow(10, decimals)) / Math.pow(10, decimals);
};


ToiletRetriever.prototype.retrieve = function(callback)
{
	var currentLocation = {
							lat: 51.2213422,
							long: 4.399342
					 	  };

	var number_of_public_toilets = public_toilets_data.length;
	var public_toilets = new Array();
	var nearest_toilets = new Array();
	
	console.log('loop public toilets');

	for(var i = 0; i < number_of_public_toilets; i++)
	{
		var current = public_toilets_data[i];

		public_toilets[i] = { id: i, lat: current.lat,
							  long: current.long,
							  description: current.omschrijving,
							  owner: current.eigenaar,
							  address:  { street: current.straat,
								  		  number: current.huisnummer,
										  postal: current.postcode,
										  city: current.district
								  		},
							  distance: this.getDistance(currentLocation, current, 2)
							};
	}

	public_toilets.sort(function(a, b) { return a.distance - b.distance });

	callback(public_toilets.slice(0, 10));
};

module.exports = new ToiletRetriever();
