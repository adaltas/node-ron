
var assert = require('assert'),
	ron = require('ron'),
	Model = ron.Model;

module.exports = {
	'Test counter': function(callback){
		var model = ron.create('TestUuidCounter');
		model.uuid(function(err,id){
			assert.ifError(err);
			assert.ok(!isNaN(parseInt(id)));
			// Clear
			model.clear(function(err,ids){
				callback();
			});
		});
	},
	'Test counter quantity': function(callback){
		var model = ron.create('TestUuidCounterQuantity');
		model.uuid(5, function(err,ids){
			assert.ifError(err);
			assert.ok(Array.isArray(ids));
			assert.eql(5,ids.length);
			model.uuid(1, function(err,ids){
				assert.ifError(err);
				assert.ok(Array.isArray(ids));
				assert.eql(1,ids.length);
				// Clear
				model.clear(function(err,ids){
					callback();
				});
			});
		});
	},
	'quit': function(callback){
		ron.quit();
		callback();
	}
}
