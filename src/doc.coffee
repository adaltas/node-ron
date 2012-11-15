
fs = require 'fs'
mecano = require 'mecano'
each = require 'each'

date = -> d = (new Date).toISOString()

convert_anchor = (text) ->
  re_anchor = /`([\w]+)\(/g
  text.replace re_anchor, (str, code) ->
    # At least in FF, <a href="" /> doesn't close the tag
    "<a name=\"#{code}\"></a>\n`#{code}("

convert_code = (text) ->
  re_code = /\n(\s{2}\s*?\w[\s\S]*?)\n(?!\s)/g
  text.replace re_code, (str, code) ->
    code = code.split('\n').map((line)->line.substr(4)).join('\n')
    "\n```coffeescript\n#{code}\n```\n"

each( ['Client', 'Schema', 'Records'] )
.parallel( true )
.on 'item', (next, file) ->
  source = "#{__dirname}/#{file}.coffee"
  destination = "#{__dirname}/../doc/#{file.toLowerCase()}.md"
  fs.readFile source, 'ascii', (err, content) ->
    return console.error err if err
    re = /###\n([\s\S]*?)\n( *)###/g
    re_title = /([\s\S]+)\n={2}=+([\s\S]*)/g
    match = re.exec content
    # docs += match[1]
    match = re_title.exec match[1]
    docs = """
    ---
    language: en
    layout: page
    title: "#{match[1]}"
    date: #{date()}
    comments: false
    sharing: false
    footer: false
    navigation: ron
    github: https://github.com/wdavidw/node-ron
    ---
    #{convert_code match[2]}
    """
    while match = re.exec content
      # Unindent
      match[1] = match[1].split('\n').map((line)->line.substr(2)).join('\n')
      docs += convert_code convert_anchor match[1]
      docs += '\n'
    fs.writeFile destination, docs, next
.on 'both', (err) ->
  return console.error err if err
  console.log 'Documentation generated'
  destination = process.argv[2]
  return unless destination
  each( ['index', 'client', 'schema', 'records'] )
  .on 'item', (next, file) ->
    mecano.copy
      source: "#{__dirname}/../doc/#{file}.md"
      destination: destination
      force: true
    , next
  .on 'both', (err) ->
    return console.error err if err
    console.log 'Documentation published'

