sys = require "sys"
rabbit = require "amqp"

console.log "Connecting to rabbit..."
connection = rabbit.createConnection { host: "localhost", port: 5672 }

connection.on "ready", () ->
    exchangeOptions = { type: "fanout", autoDelete: true }

    connection.exchange(
        "pubbery",
        exchangeOptions,
        (x) -> whenExchangeReady x
    )

whenExchangeReady = (pub) ->
    queueOptions = { autoDelete: true }

    sub1 = createSubscription connection, "sub2"

    sub2 = createSubscription connection, "sub1"

    whenQueueIsReady sub2, () ->
            console.log("HAY! Let's send like, 5 messages!")

            message = { text: "HAY" }

            for x in [5..1]
                do () ->
                    pub.publish "nada", message, {}

whenQueueIsReady = ( queue, callback ) ->
    queue.on "queueBindOk", () ->
        queue.on "basicConsumeOk", () ->
            callback()

createSubscription = (connection, queueName) ->
    connection.queue(
        queueName,
        queueOptions,
        (q) ->
            q.bind("pubbery", "*")
            q.subscribe( getHandler(queueName) )

getHandler = (x) ->
    (message, headers, deliveryInfo) ->
        console.log(x + " received: " + message.text )


