sys = require "sys"
rabbit = require "amqp"
cradle = require "cradle"

queueOptions = { durable: true }
connection = rabbit.createConnection( { host: "localhost", port: 5672 } )
connection.on( "ready", () -> whenConnectionReady() )

couch = new (cradle.Connection)(
    "http://localhost",
    5984,
    { cache: false, raw: false })

db = couch.database("durabledb")
db.create()

whenConnectionReady = () ->
    queue = createQueue( connection, "durable.fanout", "durable.db" )
    whenQueueIsReady( queue, () -> console.log( "Queue ready" ) )

createQueue = ( connection, exchange, queueName ) ->
    connection.queue(
        queueName,
        queueOptions,
        (queue) -> bindQueue( queue, exchange )
    )

bindQueue = ( queue, exchange ) ->
    queue.bind( exchange, "*" )
    queue.subscribe(
        ( message, headers, deliveryInfo ) ->
            db.save( message.value,
                { event: message.event },
                (err,res) -> console.log( "Couch sez: " + res )
            )
    )

whenQueueIsReady = ( queue, callback ) ->
    queue.on( "queueBindOk", () ->
        queue.on( "basicConsumeOk", () -> callback() )
    )