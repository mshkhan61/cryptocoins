class HomeController < ApplicationController
	require 'open-uri'

def index
	data={}
	map={}
	cycle=2016
	map["price"] = 1
	map["block"] = open("http://blockexplorer.com/q/getblockcount").read.to_i
	map["nextretarget"] = open("http://blockexplorer.com/q/nextretarget").read.to_i
	map["blocksleft"]=map["nextretarget"]-map["block"]
	map["measured"]=(cycle-map["blocksleft"])/float(cycle)
	map["difficulty"]=open("http://blockexplorer.com/q/getdifficulty").read.to_i
	map["estdifficulty"]=open("http://blockexplorer.com/q/estimate").read.to_i
	map["timeretarget"]=open("http://blockexplorer.com/q/eta").read.to_i
	data["btc"]=map

	generateMapData("ltc","http://litecoinscout.com/chain/litecoin/q",150,2016)
	generateMapData("ftc","http://explorer.feathercoin.com/chain/Feathercoin/q",150,504)
end

def generateMapData(name, url, blocktime, cycle):
	map={}
	map["price"] = JSON.parse(open("https://btc-e.com/api/2/"+name+"_btc/ticker").read["ticker"]["last"]
	map["block"] = open(url+"/getblockcount").read.to_i

	nethash=open(url+"/nethash/500/-500").read.split("START DATA")[1].split(",")
	hashesperblock=nethash[5].to_i
	nethashrate=nethash[7].to_i
	fullcycletime=blocktime*cycle
	lastretarget = (map["block"]/cycle)*cycle
	cycleblocks=map["block"]-lastretarget
	lastcycletime=open(url+"/nethash/1/"+str(cycleblocks*-1)+"/"+str(cycleblocks*-1+1)).read.split("START DATA")[1].split(",")[1].to_i
	currcycletime=int(nethash[1])-lastcycletime

	map["nextretarget"] = lastretarget+cycle
	map["blocksleft"]=map["nextretarget"]-map["block"]
	map["measured"]=cycleblocks/float(cycle)
	map["difficulty"]=float(nethash[4])
	map["estdifficulty"]=fullcycletime/(currcycletime/map["measured"])*map["difficulty"]
	map["timeretarget"]=map["blocksleft"]*hashesperblock/nethashrate
	data[name]=map
end
