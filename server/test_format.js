import axios from 'axios';

async function testWithResponseFormat() {
  try {
    const response = await axios.post('https://api.deepseek.com/chat/completions', {
      model: 'deepseek-chat',
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: 'Respond in JSON format: {"hello": "world"}' },
        { role: 'user', content: 'Hi' }
      ]
    }, {
      headers: {
        'Authorization': 'Bearer sk-cc2f5ba11c1a4fc5a3aa5968d3f94f5b',
        'Content-Type': 'application/json'
      }
    });
    console.log('RESPONSE WITH FORMAT:', response.data);
  } catch (err) {
    console.error('ERROR WITH FORMAT:', err.response?.status, err.response?.data || err.message);
  }
}

testWithResponseFormat();
