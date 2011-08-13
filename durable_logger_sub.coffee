sys = require "sys"
rabbit = require "amqp"
log4js = require "log4js"

queueOptions = { durable: true }
connection = rabbit.creatConnection( { host: "localhost", port: 5672 } )
connection.on( "ready", () -> whenConnectionReady() )

log4js.addAppender( log4js.fileAppender("event.log"), "events" )
log = log4js.getLogger( "events" )
log.setLevel("INFO")

whenConnectionReady = () ->
    queue = createQueue( connection, "durable.exchange", "durable.log" )
    whenQueueIsReady( queue,

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
            log.info( message.event + " " + message.value )
    )

whenQueueIsReady = ( queue, callback ) ->
    queue.on "queueBindOk", () ->
        queue.on "basicConsumeOk", () -> callback()