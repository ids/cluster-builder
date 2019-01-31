// before running, either globally install kafka-node  (npm install kafka-node)
// or add kafka-node to the dependencies of the local application
 
var kafka = require('kafka-node')
var Producer = kafka.Producer
KeyedMessage = kafka.KeyedMessage;
 
var client;
KeyedMessage = kafka.KeyedMessage;
 
var APP_VERSION = "0.8.5"
var APP_NAME = "KafkaProducer"
 
var topicName = "seantopic";
var KAFKA_BROKER_IP = '192.168.100.151:9092';
 
// from the Oracle Event Hub - Platform Cluster Connect Descriptor
var kafkaConnectDescriptor = KAFKA_BROKER_IP;
 
console.log("Running Module " + APP_NAME + " version " + APP_VERSION);
 
function initializeKafkaProducer(attempt) {
  try {
    console.log(`Try to initialize Kafka Client at ${kafkaConnectDescriptor} and Producer, attempt ${attempt}`);
    const client = new kafka.KafkaClient({ kafkaHost: kafkaConnectDescriptor });
    console.log("created client");
    producer = new Producer(client);
    console.log("submitted async producer creation request");
    producer.on('ready', function () {
      console.log("Producer is ready in " + APP_NAME);
    });
    producer.on('error', function (err) {
      console.log("failed to create the client or the producer " + JSON.stringify(err));
    })
  }
  catch (e) {
    console.log("Exception in initializeKafkaProducer" + JSON.stringify(e));
    console.log("Try again in 5 seconds");
    setTimeout(initializeKafkaProducer, 5000, ++attempt);
  }
}//initializeKafkaProducer
initializeKafkaProducer(1);
 
var eventPublisher = module.exports;
 
eventPublisher.publishEvent = function (eventKey, event) {
  km = new KeyedMessage(eventKey, JSON.stringify(event));
  payloads = [
    { topic: topicName, messages: [km], partition: 0 }
  ];
  producer.send(payloads, function (err, data) {
    if (err) {
      console.error("Failed to publish event with key " + eventKey + " to topic " + topicName + " :" + JSON.stringify(err));
    }
    console.log("Published event with key " + eventKey + " to topic " + topicName + " :" + JSON.stringify(data));
  });
 
}
 
//example calls: (after waiting for three seconds to give the producer time to initialize)
setTimeout(function () {
  eventPublisher.publishEvent("mykey", { "kenteken": "56-TAG-2", "country": "nl" })
}
  , 3000)