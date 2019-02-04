const Kafka = require('node-rdkafka');
const avro = require('avsc');

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

var messageCount = 0;
var stream = Kafka.KafkaConsumer.createReadStream({
  'group.id': 'kafka-test',
  'metadata.broker.list': '192.168.100.153:9092'
  }, 
  {}, 
  {
    topics: ['reddit_posts']
});

stream.on('data', function(message) {
  console.log("");
  console.log('Got message:');

  var buf = new Buffer(message.value, 'binary'); // Read string into a buffer.
  var decodedMessage = reddit_post_type.fromBuffer(buf.slice(5)); // Skip prefix.
  console.log(decodedMessage);
  console.log("");

  var redditMessage = JSON.parse(decodedMessage);
  console.log("JSON:");
  console.log(redditMessage);

  messageCount += 1;
  if(messageCount > 10) {  process.exit(); }
});