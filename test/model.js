
var assert = require('assert'),
	ron = require('ron'),
	Model = ron.Model;

module.exports = {
	'Test creation': function(callback){
		// Test return instance
		assert.ok(ron.create('TestCreation') instanceof Model);
		// Test registration
		var model = ron.create('TestCreation');
		assert.eql(ron.TestCreation, model);
		assert.eql('TestCreation', model.name);
	},
	'Test properties': function(callback){
		var model = ron.create('TestProperties');
		['get','put','delete'].forEach(function(method){
			assert.eql('function', typeof model[method]);
		})
	},
	'Test CRUD': function(callback){
		var model = ron.create('TestCRUD');
		var data = { property: 'value' };
		// Test creation
		model.put(data, function(err,record){
			assert.ifError(err);
			assert.ok( !isNaN(parseInt(record.id)) );
			assert.eql(data, record);
			var id = record.id;
			// Test get
			model.get(record.id,function(err,record){
				assert.eql(id,record.id);
				assert.eql(data, record);
				data.property = 'new value';
				// Test update
				model.put(id, data, function(err,record){
					assert.ifError(err);
					assert.eql(id, record.id);
					assert.eql(data, record);
					// Test get
					model.delete(id,function(err,success){
						assert.ifError(err);
						assert.ok(success);
						ron.quit();
					});
				});
			});
		});
	},
	'Test delete': function(callback){
		var model = ron.create('TestDelete');
		var data = { property: 'value' };
		// Test creation
		model.put(data, function(err,record){
			// Delete 1st time
			model.delete(record.id,function(err,success){
				assert.ifError(err);
				assert.ok(success);
				// Delete 2nd time
				model.delete(record.id,function(err,success){
					assert.ifError(err);
					assert.ok(!success);
					ron.quit();
				});
			});
		})
	},
	'Test list and clear': function(callback){
		var model = ron.create('TestDelete');
		var data = { property: 'value' };
		// Create 2 records
		model.put({ property: 'value 1' }, function(err,record){
			model.put({ property: 'value 2' }, function(err,record){
				// List all ids
				model.list(function(err,ids){
					assert.ifError(err);
					assert.eql(2,ids.length);
					// Clear all ids
					model.clear(function(err,ids){
						assert.ifError(err);
						assert.eql(2,ids.length);
						model.list(function(err,ids){
							assert.ifError(err);
							assert.eql(0,ids.length);
							ron.quit();
						});
					});
				});
			})
		})
	},
	'Test put': function(callback){
		var model = ron.create('TestPut');
		var data = { property: 'value' };
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
					// Clear all ids
					model.clear(function(err,ids){
						ron.quit();
					});
				});
			})
		})
	},
	'Test get properties': function(callback){
		var model = ron.create('TestGetProperties');
		var data = { property: 'value' };
		// Create 2 records
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
				// Clear all ids
				model.clear(function(err,ids){
					ron.quit();
				});
			});
		})
	}
}
