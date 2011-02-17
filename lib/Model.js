
var Step = require('step');


var Model = module.exports = function(ron,name){
	// Public
	this.name = name;
	this.properties = {};
	// Private
	this._ron = ron;
	this._identify = 'id';
	this._unique = [];
	this._required = [];
}

Model.prototype.property = function(property){
	if(!this.properties[property]){
		this.properties[property] = {};
	}
	return this;
}
Model.prototype.identify = function(property){
	this.property(property);
	this.properties[property].identify = true;
	this._identify = property;
	return this;
}
Model.prototype.unique = function(property){
	this.property(property);
	this.properties[property].unique = true;
	this._unique.push(property);
	return this;
}

Model.prototype.required = function(property){
	this.property(property);
	this.properties[property].required = true;
	this._required.push(property);
	return this;
}

Model.prototype.clear = function(callback){
	this.list(function(err,ids){
		if(err){ return callback(err); }
		var multi = this._ron.client().multi();
		ids.forEach(function(id){
			multi.del('obj:'+this.name+':'+id);
		}.bind(this));
		this._unique.forEach(function(property){
			multi.del('index:'+this.name+':'+property);
		}.bind(this));
		multi.del('index:'+this.name);
		multi.del('count:'+this.name);
		multi.exec(function(err){
			callback(err,ids);
		})
	}.bind(this));
};


Model.prototype.delete = function(id,callback){
	if(this._unique.length){
		var client = this._ron.client();
		var properties = [];
		var args = ['obj:'+this.name+':'+id];
		this._unique.forEach(function(property){
			args.push(property);
			properties.push(property);
		});
		args.push(function(err,values){
			var multi = this._ron.client().multi();
			properties.forEach(function(property,i){
				multi.del('index:'+this.name+':'+property,values[i]);
			}.bind(this));
			multi.del('obj:'+this.name+':'+id);
			multi.srem('index:'+this.name,id);
			multi.exec(function(err,values){
				callback(err,id);
			})
		}.bind(this));
		client.hmget.apply(client,args);
	}else{
		var multi = this._ron.client().multi();
		multi.del('obj:'+this.name+':'+id);
		multi.srem('index:'+this.name,id);
		// this._unique.forEach(function(property){
		// 	multi.set('index:'+this.name+':'+property+':'+record.username,id);
		// })
		multi.exec(function(err,values){
			callback(err,values.every(function(value){return value;}));
		});
	}
};

/**
 * Retrieve one or multiple objects.
 * 
 * Using its identifier
 *     .get('123',function(err,id,record){});
 * Using a unique property
 *     .get('my_property','my value',function(err,id,record){});
 * 
 * To only retrieve certain properties of an object
 *     .get('123',['property_1','property_2'],function(err,id,record){})
 */
Model.prototype.get = function(){
	var args = Array.prototype.slice.call(arguments),
		callback = args.pop(),
		properties = args.length > 1 && args[args.length-1] instanceof Array ? args.pop(): [];
	// Using its identifier & multi passed as argument
	if( args.length === 1 && typeof callback === 'object' ){
		var multi = callback;
		args[0].forEach(function(id){
			if(properties.length){
				properties.unshift('obj:'+this.name+':'+id);
				multi.hmget.apply(multi,properties);
			}else{
				multi.hgetall('obj:'+this.name+':'+id);
			}
		}.bind(this));
	// Using its identifier
	}else if( args.length === 1 ){
		// Multiple identifiers
		if(args[0] instanceof Array){
			var multi = this._ron.client().multi();
			this.get(args[0],properties,multi);
			multi.exec(function(err,records){
				records.forEach(function(record, i){
					if(!Object.keys(record).length){
						records[i] = null;
						return;
					}
					record[this._identify] = args[0];
				}.bind(this));
				callback(err,records);
			}.bind(this));
		}else{
			var client = this._ron.client();
			if(properties.length){
				properties.unshift('obj:'+this.name+':'+args[0]);
				properties.push(function(err,values){
					var record = {};
					record[this._identify] = args[0];
					for(var i=1; i<properties.length-1; i++){
						record[properties[i]] = values[i-1];
					}
					callback(err,record);
				}.bind(this));
				client.hmget.apply(client,properties);
			}else{
				client.hgetall('obj:'+this.name+':'+args[0],function(err,record){
					if(err){ return callback(err); }
					record[this._identify] = args[0];
					callback(err,record);
				}.bind(this));
			}
		}
	// Using a unique property
	}else{
		this._ron.client().hget('index:'+this.name+':'+args[0],args[1],function(err,id){
			if(err){ return callback(err); }
			if(id === null) {
				return callback(null, null);
			}
			this.get(id,properties,callback);
		}.bind(this));
	}
	return this;
};

/**
 * Create/insert an object
 * put([id], record, callback)
 */
Model.prototype.put = function(){
	var args = Array.prototype.slice.call(arguments),
		callback = args.pop(),
		id,
		record;
	if(args.length === 2){
		id = args[0];
		record = args[1];
	}else{
		record = args[0];
	}
	this._required.forEach(function(property){
		if( !property in record ){
			return callback( new Error('Missing "'+property+'" property') );
		}
	});
	if(id){
		record[this._identify] = id;
		this.update(record,callback);
	}else if(record[this._identify]){
		this.update(record,callback);
	}else{
		this.create(record,callback);
		// Retrieve all indexed value from the record
		// See if they changed
		// If so, drop index and create the new one
		// var uniques = [];
		// this._unique.forEach(function(unique){
		// 	
		// })
	}
};
Model.prototype.create = function(record,callback){
	var client = this._ron.client();
	client.incr('count:'+this.name,function(err,id){
		if(err){ return callback(err); }
		record[this._identify] = id;
		this.update(record,callback);
	}.bind(this));
};

Model.prototype.update = function(record,callback){
	var multi = this._ron.client().multi(),
		id = record[this._identify];
	this._unique.forEach(function(property){
		multi.hset('index:'+this.name+':'+property,record[property],id);
	}.bind(this))
	multi.sadd('index:'+this.name,id);
	delete record[this._identify];
	multi.hmset('obj:'+this.name+':'+id,record);
	multi.exec(function(err){
		record[this._identify] = id;
		callback(err,record);
	}.bind(this));
};

Model.prototype.list = function(callback){
	this._ron.client().smembers('index:'+this.name,function(err,values){
		callback(err,values);
	});
};

Model.prototype.length = function(callback){
	this._ron.client().scard('index:'+this.name,function(err,length){
		callback(err,length);
	});
};
