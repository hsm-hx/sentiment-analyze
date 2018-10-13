require 'mongo'
require 'natto'

client = Mongo::Client.new('mongodb://localhost/sentiment')
pn_collection = client[:pn_dict]

$pn_dict = {}

words = pn_collection.find().distinct(:word)

# TODO: ドキュメントのvalue値を読み出す
words.each do |word|
  $pn_dict[word] = pn_collection.find({:word => word}, {_id:0, value:0}).inspect
end

p $pn_dict["好き"]

def parseText(text)
  nm = Natto::MeCab.new

  words = []
  nm.parse(text) do |n|
    words.push(n.surface())
  end
  
  return words
end

def getData(data, key)
  if data.include?(key)
    return data[key]
  else
    p key
    return nil
  end
end

def getSentiment(words)
  value = 0
  values = []
  score = 0
  word_count = 0

  words.each do |word|
    value = getData($pn_dict, word)
    values.push(value)
    if value != nil and value != 0
      score = score + value 
      word_count = word_count + 1
    end
  end

  if word_count != 0
    return score/word_count.to_f 
  else
    return 0
  end
end

def main()
  text = STDIN.gets()

  words = parseText(text)
  s_score = getSentiment(words)

  puts("#{text}\'s sentiment score is #{s_score}")
end

main()
