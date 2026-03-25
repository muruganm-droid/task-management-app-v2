import request from 'supertest';
import app from '../Code/src/app';

describe('AI Voice Assistant API - POST /api/ai/parse-task', () => {
  let authToken: string;
  let projectId: string;

  beforeAll(async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password123' });
    authToken = res.body.accessToken;

    // Get a project ID
    const dashRes = await request(app)
      .get('/api/dashboard/my-tasks')
      .set('Authorization', `Bearer ${authToken}`);
    if (dashRes.body.length > 0) {
      projectId = dashRes.body[0].projectId;
    }
  });

  it('should return 401 without auth token', async () => {
    const res = await request(app)
      .post('/api/ai/parse-task')
      .send({ transcript: 'Create a task', projectId: 'some-id' });
    expect(res.status).toBe(401);
  });

  it('should return 400 without transcript', async () => {
    const res = await request(app)
      .post('/api/ai/parse-task')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ projectId });
    expect(res.status).toBe(400);
  });

  it('should return 400 without projectId', async () => {
    const res = await request(app)
      .post('/api/ai/parse-task')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ transcript: 'Create a task' });
    expect(res.status).toBe(400);
  });

  // Note: This test requires a valid OPENAI_API_KEY in .env
  // Skip in CI environments without the key
  it.skip('should parse a voice transcript into task fields', async () => {
    if (!projectId) return;
    const res = await request(app)
      .post('/api/ai/parse-task')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        transcript: 'Create a high priority task called fix login bug due tomorrow and assign it to John',
        projectId,
      });
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('title');
    expect(res.body).toHaveProperty('description');
    expect(res.body).toHaveProperty('priority');
    expect(res.body).toHaveProperty('dueDate');
    expect(res.body).toHaveProperty('assignees');
  });
});
