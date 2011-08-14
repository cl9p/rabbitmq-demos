sys = require "sys"
rabbit = require "amqp"

exchangeOptions = { type: "fanout", durable: "true" }

connection = rabbit.createConnection( { host: "localhost", port: 5672 } )
connection.on( "ready", () -> whenConnectionReady() )

whenConnectionReady = () ->
    connection.exchange(
        "durable.fanout",
        exchangeOptions,
        ( exchange ) -> whenExchangeReady( exchange )
    )

whenExchangeReady = ( exchange ) ->
    for x in [1..200]
        do () -> exchange.publish(
                "test",
                { event: "incremented", value: x.toString() },
                { deliveryMode: 2 }
        )