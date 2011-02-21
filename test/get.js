
var assert = require('assert'),
	ron = require('ron'),
	Model = ron.Model;

module.exports = {
	'Test get properties': function(callback){
		var model = ron.create('TestGetProperties');
		model.put({
			property_1: 'value 1',
			property_2: 'value 2',
			property_3: 'value 3',
		}, function(err,record){
			// List all ids
			model.get(record.id, ['property_1','property_3'], function(err,record){
				assert.ifError(err);
				assert.eql('value 1',record.property_1);
				assert.eql('undefined',typeof record.property_2);
				assert.eql('value 3',record.property_3);
				// Clear
				model.clear(function(err,ids){
					callback();
				});
			});
		})
	},
	'Test get multiple ids': function(callback){
		var model = ron.create('TestGetMultipleIds');
		// Create 2 records
		model.put({
			property: 'value 1',
		}, function(err,record){
			model.put({
				property: 'value 2',
			}, function(err,record){
				// List all ids
				model.list(function(err,ids){
					assert.ifError(err);
					assert.eql(2,ids.length);
					assert.ok(Array.isArray(ids));
					// Test
					model.get(ids, function(err,records){
						assert.ifError(err);
						assert.eql(2,records.length);
						assert.eql('value 1',records[0].property);
						assert.eql('value 2',records[1].property);
						assert.ok(!isNaN(parseInt(records[1].id)));
						// Clear
						model.clear(function(err,ids){
							// Get missing ids
							model.get(ids, function(err,records){
								assert.ifError(err);
								assert.eql([null,null],records);
								// Clear
								model.clear(function(err,ids){
									callback();
								});
							});
						});
					});
				})
			})
		})
	},
	'Get missing': function(callback){
		var model = ron.create('TestGetMissing');
		model.get('missing',function(err,record){
			assert.eql(null,record);
			callback();
		});
	},
	'Get multiple missing': function(callback){
		var model = ron.create('TestGetMissing');
		model.put({
			property: 'value 1',
		}, function(err,record){
			model.get(['missing 1',record.id,'missing 2'],function(err,records){
				assert.eql(null,records[0]);
				assert.eql(record.id,records[1].id);
				assert.eql(null,records[2]);
				callback();
			});
		});
	},
	'quit': function(callback){
		ron.quit();
		callback();
	}
}
