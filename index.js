
console.log('Loading function');

  const axios = require("axios");
  const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

exports.handler = async (event) => {
  const time_stamp = +new Date();

  const sns = new SNSClient({ region: "us-east-1" });

  const { data } = await axios.get(
    `https://blockchain.info/blocks/${time_stamp}?format=json`
  );
  const dataSet = data && data.blocks ? data.blocks : [];

  for (const d of dataSet) {
    // publish to SNS topic
    // Create publish parameters
    var params = {
      Message: JSON.stringify(d),
      TopicArn: process.env.SNS_TOPIC_ARN,
    };

    try {
      const data = await sns.send(new PublishCommand(params));
      console.log("Message sent to the topic");
      console.log("MessageID is " + data.MessageId);
    } catch (err) {
      console.error(err, err.stack);
    }
  }

  return {
      'statusCode': 200,
      'headers': {'Content-Type': 'application/json'},
      'body': "Execution finished successfully!"
  }
};
