
class Dog 
    dogName: "fido" 
    constructor: (@dogName) -> 
 
    doStuff: -> 
        console.log('the dog is walking'); 
        sayHello.call(this); 
 
    sayHello = -> 
        console.log("Hi! I'm "+@dogName); 
 
ralph = new Dog("ralph"); 
ralph.doStuff(); 
 
peter = new Dog("peter");
ralph.doStuff(); 
peter.doStuff(); 
ralph.doStuff(); 

###
class GetSet

    schema = {}

    constructor: (sch = {}) ->
        schema = sch

    set: (key, value) ->
        schema[key] = value
    
    get: (key) ->
        schema[key]
    
gs1 = new GetSet
gs2 = new GetSet

gs1.set 'a', 'b'
gs2.set 'a', 'c'

console.log gs1.get 'a'
###