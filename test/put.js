
var assert = require('assert'),
	ron = require('ron'),
	Model = ron.Model;

module.exports = {
	'Test put': function(callback){
		var model = ron.create('TestPut');
		// Create 2 records
		model.put({ property_1: 'value 1' }, function(err,record){
			assert.ifError(err);
			var id = record.id;
			model.put(record.id, { property_2: 'value 2' }, function(err,record){
				assert.ifError(err);
				assert.eql(id,record.id);
				// List all ids
				model.get(record.id, function(err,record){
					assert.ifError(err);
					assert.eql('value 1',record.property_1);
					assert.eql('value 2',record.property_2);
					// Clear
					model.clear(function(err,ids){
						callback();
					});
				});
			})
		})
	},
	'Test put multiple': function(callback){
		var model = ron.create('TestPut');
		// Create 2 records
		model.put([{
			property: 'value 1'
		},{
			property: 'value 2'
		}], function(err,records){
			assert.ifError(err);
			assert.eql(2,records.length);
			assert.eql('value 1',records[0].property);
			assert.eql('value 2',records[1].property);
			model.list(function(err,ids){
				assert.eql(2,ids.length);
				// Clear
				model.clear(function(err,ids){
					callback();
				});
			});
		})
	},
	'quit': function(callback){
		ron.quit();
		callback();
	}
}
