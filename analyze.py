import pymongo
import MeCab as mecab

client = pymongo.MongoClient()

db = client.sentiment
pn_collection = db["pn_dict"]

pn_dict = {data['word']: data['value'] for data in pn_collection.find(
    {}, {'word': 1, 'value': 1}
    )
    }

m = mecab.Tagger("-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd -Owakati")

def parseText(string):
    m.parse('')
    words = m.parse(string)
    
    words = words.split(" ")
    
    return words

def getData(data, key):
    if key in data:
        return data[key]
    else:
        return None

def getSentiment(words):
    value = 0
    values = []
    score = 0
    word_count = 0

    for word in words:
        value = getData(pn_dict, word)
        values.append(value)
        if value is not None and value != 0:
            score += value 
            word_count += 1

    if word_count != 0:
        return score/float(word_count) 
    else:
        return 0

def main():
    text = input()

    words = parseText(text)
    print(words)
    s_score = getSentiment(words)

    print(text + "\'s sentiment score is " + str(s_score))

if __name__ == '__main__':
    main()
