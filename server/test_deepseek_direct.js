import axios from 'axios';

async function testDeepSeekDirect() {
  try {
    const response = await axios.post('https://api.deepseek.com/chat/completions', {
      model: 'deepseek-chat',
      messages: [
        { role: 'user', content: 'Hello' }
      ]
    }, {
      headers: {
        'Authorization': 'Bearer sk-cc2f5ba11c1a4fc5a3aa5968d3f94f5b',
        'Content-Type': 'application/json'
      }
    });
    console.log('DEEPSEEK DIRECT RESPONSE:', response.data);
  } catch (err) {
    console.error('DEEPSEEK DIRECT ERROR:', err.response?.status, err.response?.data || err.message);
  }
}

testDeepSeekDirect();
