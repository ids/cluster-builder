var kafka = require('kafka-node');
const avro = require('avsc');

var client;
 
var APP_VERSION = "0.8.5"
var APP_NAME = "KafkaConsumer"
 
var eventListenerAPI = module.exports;
 
var kafka = require('kafka-node')
var Consumer = kafka.Consumer
 
// from the Oracle Event Hub - Platform Cluster Connect Descriptor
 
var topicName = "reddit_posts";
 
console.log("Running Module " + APP_NAME + " version " + APP_VERSION);
console.log("Event Hub Topic " + topicName);
 
var KAFKA_BROKER_IP = '192.168.100.153:9092';
 
var consumerOptions = {
    kafkaHost: KAFKA_BROKER_IP,
    groupId: 'local-consume-events-from-event-hub-test',
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

    const reddit_post_type = avro.Type.forSchema({
        "type": "record",
        "name": "reddit_post",
        "namespace": "com.landoop.social.reddit.post",
        "doc": "Schema for Reddit Posts dataset. [https://www.kaggle.com/reddit/reddit-comments-may-2015/discussion/16213]",
        "fields": [
          {
            "name": "created_utc",
            "type": "int"
          },
          {
            "name": "ups",
            "type": "int"
          },
          {
            "name": "subreddit_id",
            "type": "string"
          },
          {
            "name": "link_id",
            "type": "string"
          },
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "score_hidden",
            "type": "int"
          },
          {
            "name": "author_flair_css_class",
            "type": [
              "null",
              "string"
            ]
          },
          {
            "name": "author_flair_text",
            "type": [
              "null",
              "string"
            ]
          },
          {
            "name": "subreddit",
            "type": "string"
          },
          {
            "name": "id",
            "type": "string"
          },
          {
            "name": "removal_reason",
            "type": [
              "null",
              "string"
            ]
          },
          {
            "name": "gilded",
            "type": "int"
          },
          {
            "name": "downs",
            "type": "int"
          },
          {
            "name": "archived",
            "type": "boolean"
          },
          {
            "name": "author",
            "type": "string"
          },
          {
            "name": "score",
            "type": "int"
          },
          {
            "name": "retrieved_on",
            "type": "int"
          },
          {
            "name": "body",
            "type": "string"
          },
          {
            "name": "distinguished",
            "type": [
              "null",
              "string"
            ]
          },
          {
            "name": "edited",
            "type": "int"
          },
          {
            "name": "controversiality",
            "type": "boolean"
          },
          {
            "name": "parent_id",
            "type": "string"
          }
        ]
    });

    //var buf = new Buffer(message.value, 'binary'); // Read string into a buffer.
    //var decodedMessage = reddit_post_type.fromBuffer(buf.slice(5)); // Skip prefix.
    //console.log(decodedMessage);

   console.log(JSON.parse(JSON.stringify(message.value)))

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