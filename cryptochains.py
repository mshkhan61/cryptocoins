#!/usr/bin/python

import urllib2
import json

data={}

def generateMapData(name, url, blocktime, cycle):
	map={}
	map["price"] = json.loads(urllib2.urlopen("https://btc-e.com/api/2/"+name+"_btc/ticker").read())["ticker"]["last"]
	map["block"] = int(urllib2.urlopen(url+"/getblockcount").read())

	nethash=urllib2.urlopen(url+"/nethash/500/-500").read().split("START DATA")[1]
	nethash=nethash.split(",")
	hashesperblock=int(nethash[5])
	nethashrate=int(nethash[7])
	fullcycletime=blocktime*cycle
	lastretarget = (map["block"]/cycle)*cycle
	cycleblocks=map["block"]-lastretarget
	lastcycletime=int(urllib2.urlopen(url+"/nethash/1/"+str(cycleblocks*-1)+"/"+str(cycleblocks*-1+1)).read().split("START DATA")[1].split(",")[1])
	currcycletime=int(nethash[1])-lastcycletime

	map["nextretarget"] = lastretarget+cycle
	map["blocksleft"]=map["nextretarget"]-map["block"]
	map["measured"]=cycleblocks/float(cycle)
	map["difficulty"]=float(nethash[4])
	map["estdifficulty"]=fullcycletime/(currcycletime/map["measured"])*map["difficulty"]
	map["timeretarget"]=map["blocksleft"]*hashesperblock/nethashrate
	data[name]=map

map={}
cycle=2016
map["price"] = 1
map["block"] = int(urllib2.urlopen("http://blockexplorer.com/q/getblockcount").read())
map["nextretarget"] = int(urllib2.urlopen("http://blockexplorer.com/q/nextretarget").read())
map["blocksleft"]=map["nextretarget"]-map["block"]
map["measured"]=(cycle-map["blocksleft"])/float(cycle)
map["difficulty"]=urllib2.urlopen("http://blockexplorer.com/q/getdifficulty").read()
map["estdifficulty"]=urllib2.urlopen("http://blockexplorer.com/q/estimate").read()
map["timeretarget"]=urllib2.urlopen("http://blockexplorer.com/q/eta").read()
data["btc"]=map

generateMapData("ltc","http://litecoinscout.com/chain/litecoin/q",150,2016)
generateMapData("ftc","http://explorer.feathercoin.com/chain/Feathercoin/q",150,504)

for key,value in data.items():
	print key
	for k2, v2 in value.items():
		print k2, ":",v2 

