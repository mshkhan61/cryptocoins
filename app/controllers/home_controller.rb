class HomeController < ApplicationController
	require 'open-uri'
	require 'json'
#TODO bootstrap formatting

def index
	#get new data
		@attributes=["name","price","block","nextretarget","blocksleft","measured","difficulty","estdifficulty","timeretarget"]
		@data={}
		@data["btc"]=generateBTCData(2016)
		@data["ltc"]=generateMapData("ltc","http://litecoinscout.com/chain/litecoin/q",150,2016)
		@data["ftc"]=generateMapData("ftc","http://explorer.feathercoin.com/chain/Feathercoin/q",150,504)
end

def generateMapData(name, url, blocktime, cycle)
	map={}
	map["name"]=name
	map["price"] = JSON.parse(open("https://btc-e.com/api/2/"+name+"_btc/ticker").read)["ticker"]["last"]
	map["block"] = open(url+"/getblockcount").read.to_i

	nethash=open(url+"/nethash/500/-500").read.split("START DATA")[1].split(",")
	hashesperblock=nethash[5].to_i
	nethashrate=nethash[7].to_i
	fullcycletime=blocktime*cycle
	lastretarget = (map["block"]/cycle)*cycle
	cycleblocks=map["block"]-lastretarget
	lastcycletime=open(url+"/nethash/1/"+(cycleblocks*-1).to_s+"/"+(cycleblocks*-1+1).to_s).read.split("START DATA")[1].split(",")[1].to_i
	currcycletime=nethash[1].to_i-lastcycletime

	map["nextretarget"] = lastretarget+cycle
	map["blocksleft"]=map["nextretarget"]-map["block"]
	map["measured"]=cycleblocks/cycle.to_f
	map["difficulty"]=nethash[4].to_f
	map["estdifficulty"]=fullcycletime/(currcycletime/map["measured"])*map["difficulty"]
	map["timeretarget"]=map["blocksleft"]*hashesperblock/nethashrate
	return map
end

def generateBTCData(cycle)
	map={}
	map["name"]="btc"
	map["price"] = 1
	map["block"] = open("http://blockexplorer.com/q/getblockcount").read.to_i
	map["nextretarget"] = open("http://blockexplorer.com/q/nextretarget").read.to_i
	map["blocksleft"]=map["nextretarget"]-map["block"]
	map["measured"]=(cycle-map["blocksleft"])/cycle.to_f
	map["difficulty"]=open("http://blockexplorer.com/q/getdifficulty").read.to_i
	map["estdifficulty"]=open("http://blockexplorer.com/q/estimate").read.to_i
	map["timeretarget"]=open("http://blockexplorer.com/q/eta").read.to_i
	return map
end

end
