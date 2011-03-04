
var assert = require('assert'),
	ron = require('ron'),
	Model = ron.Model;

module.exports = {
	'Test define': function(callback){
		var model = ron.create('TestUniqueDefine').unique('property');
		assert.ok(model.properties.property.unique);
		callback();
	},
	'Test schema': function(callback){
		var model = ron.create('TestUniqueSchema').unique('unique_property');
		model.put({
			unique_property: 'unique',
			other_property: 'other'
		},function(err,record){
			assert.ifError(err);
			var multi = ron.client().multi();
			multi.type('count:TestUniqueSchema',function(err,type){
				assert.eql('string',type);
			});
			multi.type('obj:TestUniqueSchema:'+record.id,function(err,type){
				assert.eql('hash',type);
			});
			multi.type('index:TestUniqueSchema',function(err,type){
				assert.eql('set',type);
			});
			multi.type('index:TestUniqueSchema:unique_property',function(err,type){
				assert.eql('hash',type);
			});
			multi.exec(function(err,results){
				// Put a second time
				callback();
			});
		});
	},
	'Test exists': function(callback){
		var model = ron.create('TestUniqueExists').unique('unique_property_1').unique('unique_property_2');
		model.put([{
			unique_property_1: 'unique 1.1',
			other_property: 'other'
		},{
			unique_property_1: 'unique 2.1',
			unique_property_2: 'unique 2.2',
			other_property: 'other'
		}],function(err,record){
			assert.ifError(err);
			// Test true
			model.exists({
				unique_property_1: 'unique 1.1',
				other_property: 'other updated'
			},function(err,exists){
				assert.ifError(err);
				assert.ok(exists);
				// Test true width 2 values
				model.exists({
					unique_property_1: 'unique 2.1',
					unique_property_2: 'unique 2.2',
					other_property: 'other updated'
				},function(err,exists){
					assert.ifError(err);
					assert.ok(exists);
					// Test false
					model.exists({
						unique_property_1: 'unique x.x',
						unique_property_2: 'unique x.x',
						other_property: 'other updated'
					},function(err,exists){
						assert.ifError(err);
						assert.ok(!exists);
						// Test corrupted
						model.exists({
							unique_property_1: 'unique 2.1',
							unique_property_2: 'unique x.x',
							other_property: 'other updated'
						},function(err,exists){
							assert.ok(err instanceof Error);
							model.clear(function(err){
								callback();
							})
						});
					});
				});
			});
		});
	},
	'Test update': function(callback){
		var model = ron.create('TestUniqueUpdate').unique('unique_property');
		model.put({
			unique_property: 'unique',
			other_property: 'other'
		},function(err,record){
			assert.ifError(err);
			model.update({
				id: record.id,
				unique_property: 'unique',
				other_property: 'other updated'
			},function(err,record){
				assert.ifError(err);
				model.length(function(err,length){
					assert.ifError(err);
					assert.eql(1,length);
					model.clear(function(err){
						assert.ifError(err);
						// ron.quit();
						callback();
					});
				})
			});
		});
	},
	'Test create': function(callback){
		console.log('todo');
		var model = ron.create('TestCreate').unique('unique_property');
		model.put({
			unique_property: 'unique',
			other_property: 'other'
		},function(err,record){
			assert.ifError(err);
			model.put({
				unique_property: 'unique',
				other_property: 'other'
			},function(err,record){
				assert.ifError(err);
				model.length(function(err,length){
					model.clear(function(err){
						callback();
					});
				});
			});
		});
	},
	'Test put': function(callback){
		console.log('todo');
		var model = ron.create('TestPut').unique('unique_property');
		model.put({
			unique_property: 'unique',
			other_property: 'other'
		},function(err,record){
			assert.ifError(err);
			model.put({
				unique_property: 'unique',
				other_property: 'other'
			},function(err,record){
				assert.ifError(err);
				model.length(function(err,length){
					model.clear(function(err){
						callback();
					});
				});
			});
		});
	},
	'Test clear': function(callback){
		var model = ron.create('TestUniqueClear').unique('property');
		model.put({
			property: 'my value'
		},function(err,record){
			assert.ifError(err);
			model.clear(function(err){
				assert.ifError(err);
				var multi = ron.client().multi();
				multi.type('count:TestUniqueClear',function(err,type){
					assert.eql('none',type);
				});
				multi.type('obj:TestUniqueClear:'+record.id,function(err,type){
					assert.eql('none',type);
				});
				multi.type('index:TestUniqueClear',function(err,type){
					assert.eql('none',type);
				});
				multi.type('index:TestUniqueClear:property',function(err,type){
					assert.eql('none',type);
				});
				multi.exec(function(err,results){
					// ron.quit();
					callback();
				});
			});
		});
	},
	'Test get': function(callback){
		var model = ron.create('TestUniqueGet').unique('property');
		model.put({
			property: 'my value'
		},function(err,record){
			model.get('property', 'my value', function(err,record){
				assert.ifError(err);
				assert.ok( !isNaN(parseInt(record.id)) );
				assert.eql('my value',record.property);
				model.clear(function(err){
					assert.ifError(err);
					callback();
				});
			});
		});
	},
	'Test get missing': function(callback){
		var model = ron.create('TestUniqueMissing').unique('property');
		model.get('property', 'missing value', function(err,record){
			assert.ifError(err);
			assert.eql(null,record);
			callback();
		});
	},
	'Test delete': function(callback){
		var model = ron.create('TestUniqueDelete').unique('property_1').unique('property_2');
		model.put({
			property_1: 'my value 1',
			property_2: 'my value 2'
		},function(err,record){
			assert.ifError(err);
			model.delete(record.id,function(err,id){
				assert.ifError(err);
				var multi = ron.client().multi();
				multi.type('count:TestUniqueDelete',function(err,type){
					assert.eql('string',type);
				});
				multi.type('obj:TestUniqueDelete:'+id,function(err,type){
					assert.eql('none',type);
				});
				multi.scard('index:TestUniqueDelete',function(err,length){
					assert.eql(0,length);
				});
				multi.hgetall('index:TestUniqueDelete:property',function(err,value){
					assert.eql({},value);
				});
				multi.exec(function(err,results){
					model.clear(function(err){
						callback();
					});
				});
			});
		});
	},
	'Test unique query': function(callback){
		var model = ron.create('TestUniqueQuery').unique('property');
		model.put([{
			property: 'value 1'
		},{
			property: 'value 2'
		},{
			property: 'value 3'
		}],function(err,records){
			model.get({property:['value 1','value 3']},function(err,records){
				assert.eql(2,records.length);
				assert.eql('value 1',records[0].property);
				assert.eql('value 3',records[1].property);
				model.clear(function(err){
					callback();
				});
			})
		});
	},
	'quit': function(callback){
		ron.quit();
		callback();
	}
}
