sys = require "sys"
rabbit = require "amqp"
cradle = require "cradle"

exchangeOptions = { type: "fanout", autoDelete: true, passive: true }

connection = rabbit.createConnection( { host: "localhost", port: 5672 } )
connection.on( "ready", () -> whenConnectionReady() )

couch = new (cradle.Connection)(
    "http://localhost",
    5984,
    { cache: false, raw: false })

db = couch.database("durabledb")

whenConnectionReady = () ->
    exchange = connection.exchange(
         "respond",
         exchangeOptions,
         () ->
            queue = connection.queue( "requests" )
            queue.subscribe( ( message, headers, deliveryInfo ) ->
                db.get( message.docid, (err,doc) ->
                    exchange.publish( "", doc, {deliveryMode: 2} )
                )
            )
    )