sys = require "sys"
rabbit = require "amqp"

exchangeOptions = { type: "fanout", autoDelete: true }
queueOptions = { autoDelete: true }
message = { text: "Test" }

connection = rabbit.createConnection( { host: "localhost", port: 5672 } )
connection.on( "ready", () -> whenConnectionReady() )

whenConnectionReady = () ->
    connection.exchange(
        "fanout.exchange",
        exchangeOptions,
        ( exchange ) -> whenExchangeReady( exchange )
    )

whenExchangeReady = ( exchange ) ->
    queue1 = createQueue( connection, exchange, "queue1" )
    queue2 = createQueue( connection, exchange, "queue2" )
    whenQueueIsReady( queue2, () -> publishMessage( exchange, message, 5 ) )

createQueue = ( connection, exchange, queueName ) ->
    connection.queue(
        queueName,
        queueOptions,
        (queue) -> bindQueue( queue, exchange )
    )

bindQueue = ( queue, exchange ) ->
    queue.bind( exchange, "*" )
    queue.subscribe( createHandler( queue.name ) )

whenQueueIsReady = ( queue, callback ) ->
    queue.on "queueBindOk", () ->
        queue.on "basicConsumeOk", () -> callback()

createHandler = ( queueName ) ->
    ( message, headers, deliveryInfo ) ->
        console.log(queueName + " received: " + message.text )

publishMessage = ( exchange, message, repeat ) ->
            console.log("Sending message " + repeat + " times.")
            for x in [1..repeat]
                do () -> exchange.publish( "", message, {} )

