sys = require "sys"
rabbit = require "amqp"

exchangeOptions = { type: "fanout", durable: "true" }

connection = rabbit.creatConnection( { host: "localhost", port: 5672 } )
connection.on( "ready", () -> whenConnectionReady() )

whenConnectionReady = () ->
    connection.exchange( "durable.fanout", exchangeOptions,
        ( exchange ) -> whenExchangeReady( exchange )

whenExchangeReady = ( exchange ) ->
    for x in [1..20]
        do () -> exchange.publish(
                "",
                { event: "incremented", value: x },
                { deliveryMode: 2 }
        )