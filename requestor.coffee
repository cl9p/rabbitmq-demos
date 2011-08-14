sys = require "sys"
rabbit = require "amqp"

exchangeOptions = { type: "fanout", autoDelete: "true" }
requestOptions = { autoDelete: "true" }
responseOptions = { autoDelete: "true", exclusive: "true" }

connection = rabbit.createConnection( { host: "localhost", port: 5672 } )
connection.on( "ready", () -> whenConnectionReady() )

makeRequest = ( exchange, message ) ->
    exchange.publish(
        "",
        message,
        {deliveryMode: 2}
    )

handleResponse = ( message, headers, deliveryInfo ) ->
    console.log( message )

whenConnectionReady = () ->
    connection.exchange(
        "request",
        exchangeOptions,
        ( exchange ) -> whenRequestExchangeReady( exchange )
    )

    connection.exchange(
        "respond",
        exchangeOptions,
        ( exchange ) -> whenResponseExchangeReady(
             exchange,
             handleResponse )
    )

whenRequestExchangeReady = ( exchange ) ->
    connection.queue(
        "requests",
        requestOptions,
        ( queue ) ->
            queue.bind( exchange, "*" )

            for x in [1..200]
                do () -> makeRequest(
                    exchange,
                    {
                        docid: x.toString()
                    })
    )

whenResponseExchangeReady = ( exchange, onMessage ) ->
    connection.queue(
        "responses",
        responseOptions,
        ( queue ) -> bindQueue( queue, exchange, onMessage )
    )

bindQueue = ( queue, exchange, onMessage ) ->
    queue.bind( exchange, "*" )
    queue.subscribe(
        ( message, headers, deliveryInfo ) ->
            onMessage( message, headers, deliveryInfo )
    )