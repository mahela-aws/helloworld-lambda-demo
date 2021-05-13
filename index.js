'use strict';

console.log('Loading function');

exports.handler = (event, context, callback) => {
    //console.log('Received event:', JSON.stringify(event, null, 2));
    const time_stamp = + new Date();

    const { data } = await axios.get(`https://blockchain.info/blocks/${time_stamp}?format=json`);
    const dataSet = data?.blocks || [];
    const blocks = data && data.blocks ? data.blocks : [];
    var AWS = require('aws-sdk');
    AWS.config.update({region: 'us-east-1'});

    for (let i = 0; i < blocks.length; i++) {
        // publish to SNS topic
        // Create publish parameters
        var params = {
          Message: blocks[i],
          TopicArn: process.env.SNS_TOPIC_ARN
        };
        // Create promise and SNS service object
        var publishTextPromise = new AWS.SNS({apiVersion: '2010-03-31'}).publish(params).promise();
        // Handle promise's fulfilled/rejected states
        publishTextPromise.then(
          function(data) {
            console.log(`Message ${params.Message} sent to the topic ${params.TopicArn}`);
            console.log("MessageID is " + data.MessageId);
          }).catch(
            function(err) {
            console.error(err, err.stack);
          });
        console.log(blocks[i]);
    }

};
