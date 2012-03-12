
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


    it 'should deal with create', (next) ->
        Records = client.get
            name: 'records'
            temporal: true
            properties: 
                record_id: identifier: true
        date = new Date Date.UTC 2008, 8, 10, 16, 5, 10
        Records.clear (err) ->
            Records.create {}, (err, record) ->
                should.not.exist err
                record.cdate.should.be.an.instanceof Date
                record.mdate.should.be.an.instanceof Date
                next()

    it 'should deal with update', (next) ->
        Records = client.get
            name: 'records'
            temporal: true
            properties: 
                record_id: identifier: true
        date = new Date Date.UTC 2008, 8, 10, 16, 5, 10
        Records.clear (err) ->
            Records.create {}, (err, record) ->
                cdate = record.cdate
                Records.update record, (err, record) ->
                    should.not.exist err
                    record.cdate.should.be.an.instanceof Date
                    record.cdate.should.eql cdate
                    record.mdate.should.be.an.instanceof Date
                    next()
