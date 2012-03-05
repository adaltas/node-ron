
should = require 'should'

try config = require '../conf/test' catch e
ron = require '../index'

describe 'type', ->

    client = Users = null
    
    before (next) ->
        client = ron config
        next()
    
    after (next) ->
        client.quit next

    it 'should return a record or an array depending on the provided argument', ->
        Records = client.get
            name: 'records'
            properties: 
                a_date: type: 'date'
        date = new Date Date.UTC 2008, 8, 10, 16, 5, 10
        # Serialization
        result = Records.serialize a_date: date
        result.should.not.be.an.instanceof Array
        result.should.eql a_date: date.getTime()
        result = Records.serialize [a_date: date]
        result.should.be.an.instanceof Array
        result.should.eql [a_date: date.getTime()]
        # Deserialization
        result = Records.unserialize a_date: "#{date.getTime()}"
        result.should.not.be.an.instanceof Array
        result.should.eql a_date: date
        result = Records.unserialize [a_date: "#{date.getTime()}"]
        result.should.be.an.instanceof Array
        result.should.eql [a_date: date]


    it 'should deal with dates', (next) ->
        Records = client.get
            name: 'records'
            properties: 
                record_id: identifier: true
                a_date: type: 'date'
        date = new Date Date.UTC 2008, 8, 10, 16, 5, 10
        # Test create
        Records.clear (err) ->
            Records.create
                a_date: date
            , (err, record) ->
                should.not.exist err
                recordId = record.record_id
                record.a_date.should.equal date
                # Test all
                Records.all (err, records) ->
                    should.not.exist err
                    records.length.should.equal 1
                    records[0].a_date.should.eql date
                    # Test update
                    date.setYear 2010
                    Records.update
                        record_id: recordId
                        a_date: date
                    , (err, record) ->
                        should.not.exist err
                        record.a_date.should.eql date
                        # Test list
                        Records.list (err, records) ->
                            should.not.exist err
                            records.length.should.equal 1
                            records[0].a_date.should.eql date
                            # Test list
                            Records.get records[0].record_id, (err, record) ->
                                should.not.exist err
                                record.a_date.should.eql date
                                next()
