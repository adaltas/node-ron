
var orm = require(__dirname+'/../lib/orm'),
	Model = require(__dirname+'/../lib/Model'),
	assert = require('assert');

module.exports = {
	'Test define': function(callback){
		var model = orm.create('TestDefine').unique('property');
		assert.ok(model.properties.property.unique);
	},
	'Test put': function(callback){
		var model = orm.create('TestUniquePut').unique('unique_property');
		model.put({
			unique_property: 'unique',
			other_property: 'other'
		},function(err,record){
			assert.ifError(err);
			var multi = orm.client().multi();
			multi.type('count:TestUniquePut',function(err,type){
				assert.eql('string',type);
			});
			multi.type('obj:TestUniquePut:'+record.id,function(err,type){
				assert.eql('hash',type);
			});
			multi.type('index:TestUniquePut',function(err,type){
				assert.eql('set',type);
			});
			multi.type('index:TestUniquePut:unique_property',function(err,type){
				assert.eql('hash',type);
			});
			multi.exec(function(err,results){
				// Put a second time
				model.put({
					id: record.id,
					unique_property: 'unique',
					other_property: 'other updated'
				},function(err,record){
					assert.ifError(err);
					model.length(function(err,count){
						assert.ifError(err);
						assert.eql(1,count);
						model.clear(function(err){
							assert.ifError(err);
							orm.quit();
						});
					})
				});
			});
		});
	},
	'Test clear': function(callback){
		var model = orm.create('TestClear').unique('property');
		model.put({
			property: 'my value'
		},function(err,record){
			assert.ifError(err);
			model.clear(function(err){
				assert.ifError(err);
				var multi = orm.client().multi();
				multi.type('count:TestClear',function(err,type){
					assert.eql('none',type);
				});
				multi.type('obj:TestClear:'+record.id,function(err,type){
					assert.eql('none',type);
				});
				multi.type('index:TestClear',function(err,type){
					assert.eql('none',type);
				});
				multi.type('index:TestClear:property',function(err,type){
					assert.eql('none',type);
				});
				multi.exec(function(err,results){
					orm.quit();
				});
			});
		});
	},
	'Test get': function(callback){
		var model = orm.create('TestGet').unique('property');
		model.put({
			property: 'my value'
		},function(err,record){
			model.get('property', 'my value', function(err,record){
				assert.ifError(err);
				assert.ok( !isNaN(parseInt(record.id)) );
				assert.eql('my value',record.property);
				model.clear(function(err){
					assert.ifError(err);
					orm.quit();
				});
			});
		});
	},
	'Test delete': function(callback){
		var model = orm.create('TestDelete').unique('property_1').unique('property_2');
		model.put({
			property_1: 'my value 1',
			property_2: 'my value 2'
		},function(err,record){
			assert.ifError(err);
			model.delete(record.id,function(err,id){
				assert.ifError(err);
				var multi = orm.client().multi();
				multi.type('count:TestDelete',function(err,type){
					assert.eql('string',type);
				});
				multi.type('obj:TestDelete:'+id,function(err,type){
					assert.eql('none',type);
				});
				multi.scard('index:TestDelete',function(err,length){
					assert.eql(0,length);
				});
				multi.hgetall('index:TestDelete:property',function(err,value){
					assert.eql({},value);
				});
				multi.exec(function(err,results){
					model.clear(function(err){
						orm.quit();
					});
				});
			});
		});
	}
}
