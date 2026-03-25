import request from 'supertest';
import app from '../Code/src/app';
import path from 'path';

describe('Attachments API', () => {
  let authToken: string;
  let taskId: string;
  let attachmentId: string;

  beforeAll(async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password123' });
    authToken = res.body.accessToken;

    // Get a task to test with
    const dashRes = await request(app)
      .get('/api/dashboard/my-tasks')
      .set('Authorization', `Bearer ${authToken}`);
    if (dashRes.body.length > 0) {
      taskId = dashRes.body[0].id;
    }
  });

  it('should return 401 without auth token', async () => {
    const res = await request(app).get(`/api/tasks/${taskId}/attachments`);
    expect(res.status).toBe(401);
  });

  it('should list attachments for a task', async () => {
    if (!taskId) return;
    const res = await request(app)
      .get(`/api/tasks/${taskId}/attachments`)
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('should return 404 for non-existent task', async () => {
    const res = await request(app)
      .get('/api/tasks/non-existent-id/attachments')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(404);
  });

  it('should upload an attachment', async () => {
    if (!taskId) return;
    const res = await request(app)
      .post(`/api/tasks/${taskId}/attachments`)
      .set('Authorization', `Bearer ${authToken}`)
      .attach('file', Buffer.from('test file content'), 'test.txt');
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body).toHaveProperty('fileName', 'test.txt');
    expect(res.body).toHaveProperty('mimeType');
    attachmentId = res.body.id;
  });

  it('should delete an attachment', async () => {
    if (!attachmentId) return;
    const res = await request(app)
      .delete(`/api/attachments/${attachmentId}`)
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('message', 'Attachment deleted.');
  });
});
