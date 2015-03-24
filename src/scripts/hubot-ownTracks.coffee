# Description:
#   Hubot plugin to retrieve ownTracks' location data from MQTT server using finds.jp reverse-geocoding service.
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   hubot location me   - Retrieve my location data

http = require('http')
mqtt = require('mqtt')

client = mqtt.connect(process.env.HUBOT_OWNTRACKS_URL,
{ protocolId: 'MQIsdp', protocolVersion: 3 })
topic= process.env.HUBOT_OWNTRACKS_TOPIC
msg = ""

client.subscribe(topic)

client.on('message', (topic,message) ->
  ob = JSON.parse(message);
  dt = new Date(Number(ob.tst*1000))
  if(ob.acc < 3000) # accuracy < 3km only
    url = "http://www.finds.jp/ws/rgeocode.php?json&lat="+ob.lat+"&lon="+ob.lon
    http.get(url, (res) ->
      res.on('data', (chunk) ->
        geo = JSON.parse(chunk)
        month = dt.getMonth()+1
        day=dt.getDate()
        hour=dt.getHours()
        min=dt.getMinutes()
        if(geo.result)
          curloc=geo.result.prefecture.pname+geo.result.municipality.mname+"あたりです"
        else
          curloc="よくわかりません"
        msg =  "#{month}月#{day}日#{hour}時#{min}分 時点の現在位置は,"+curloc
      ).on('error',  (e) ->
        console.log("Got error: " + e.message);
      ))
)

module.exports = (robot) ->
  robot.respond /location me/i, (message) ->
#x=() ->
        message.send msg
         #setTimeout(() ->
           #console.log msg
         #, 1000)

#x()
