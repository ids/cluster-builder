var kafka = require('kafka-node');
 
var client;
 
var APP_VERSION = "0.8.5"
var APP_NAME = "KafkaConsumer"
 
var eventListenerAPI = module.exports;
 
var kafka = require('kafka-node')
var Consumer = kafka.Consumer
 
// from the Oracle Event Hub - Platform Cluster Connect Descriptor
 
var topicName = "seantopic";
 
console.log("Running Module " + APP_NAME + " version " + APP_VERSION);
console.log("Event Hub Topic " + topicName);
 
var KAFKA_BROKER_IP = '192.168.100.151:9092';
 
var consumerOptions = {
    kafkaHost: KAFKA_BROKER_IP,
    groupId: 'local-consume-events-from-event-hub-for-kenteken-applicatie',
    sessionTimeout: 15000,
    protocol: ['roundrobin'],
    fromOffset: 'earliest' // equivalent of auto.offset.reset valid values are 'none', 'latest', 'earliest'
};
 
var topics = [topicName];
var consumerGroup = new kafka.ConsumerGroup(Object.assign({ id: 'consumerLocal' }, consumerOptions), topics);
consumerGroup.on('error', onError);
consumerGroup.on('message', onMessage);
 
consumerGroup.on('connect', function () {
    console.log('connected to ' + topicName + " at " + consumerOptions.host);
})
 
function onMessage(message) {
    console.log('%s read msg Topic="%s" Partition=%s Offset=%d'
    , this.client.clientId, message.topic, message.partition, message.offset);
    console.log(message);
}
 
function onError(error) {
    console.error(error);
    console.error(error.stack);
}
 
process.once('SIGINT', function () {
    async.each([consumerGroup], function (consumer, callback) {
        consumer.close(true, callback);
    });
});