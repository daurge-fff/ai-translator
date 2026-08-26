import axios from 'axios';

async function testAdminIncidents() {
  try {
    const res = await axios.get('http://127.0.0.1:3000/api/admin/incidents', {
      headers: {
        'Authorization': 'Bearer mock-token'
      }
    });
    console.log('✅ ADMIN INCIDENTS LOG:');
    console.log(res.data);
  } catch (e) {
    console.error('ADMIN INCIDENTS ERROR:', e.response?.data || e.message);
  }
}

testAdminIncidents();
