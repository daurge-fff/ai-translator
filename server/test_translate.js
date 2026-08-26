import axios from 'axios';

async function test() {
  try {
    const res = await axios.post('http://127.0.0.1:3000/api/translate', {
      sourceText: 'футбол',
      sourceLang: 'Russian',
      targetLang: 'English',
      userContext: 'пишу американцу в Slack'
    }, {
      headers: {
        'Authorization': 'Bearer mock-token',
        'x-device-id': 'test-device-uuid'
      }
    });
    console.log('✅ TEST RESULT SUCCESS:', res.data);
  } catch (e) {
    console.error('TEST ERROR:', e.response?.status, e.response?.data || e.message);
  }
}

test();
