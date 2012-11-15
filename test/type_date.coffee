
should = require 'should'

try config = require '../conf/test' catch e
ron = if process.env.RON_COV then require '../lib-cov/ron' else require '../lib/ron'

describe 'type date', ->

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

  it 'should parse date provided as string', ->
    Records = client.get
      name: 'records'
      properties: 
        a_date: type: 'date'
    date = '2008-09-10'
    # Serialization
    result = Records.serialize a_date: date
    result.should.eql a_date: (new Date date).getTime()
    # Deserialization
    result = Records.unserialize a_date: date
    result.should.eql a_date: new Date date

  it 'should unserialize dates in seconds and milliseconds', ->
    Records = client.get
      name: 'records'
      properties: 
        a_date: type: 'date'
    date = '2008-09-10'
    # Deserialization
    result = Records.unserialize a_date: date, { milliseconds: true }
    result.a_date.should.eql 1221004800000
    result = Records.unserialize a_date: date, { seconds: true }
    result.a_date.should.eql 1221004800

  it 'should deal with Date objects', (next) ->
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
        record.a_date.getTime().should.eql date.getTime()
        # Test all
        Records.all (err, records) ->
          should.not.exist err
          records.length.should.equal 1
          records[0].a_date.getTime().should.eql date.getTime()
          # Test update
          date.setYear 2010
          Records.update
            record_id: recordId
            a_date: date
          , (err, record) ->
            should.not.exist err
            record.a_date.getTime().should.eql date.getTime()
            # Test list
            Records.list (err, records) ->
              should.not.exist err
              records.length.should.equal 1
              records[0].a_date.getTime().should.eql date.getTime()
              # Test list
              Records.get records[0].record_id, (err, record) ->
                should.not.exist err
                record.a_date.getTime().should.eql date.getTime()
                next()
