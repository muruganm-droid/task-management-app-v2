import request from 'supertest';
import app from '../Code/src/app';

describe('Kanban DnD API', () => {
  let authToken: string;
  let taskId: string;

  beforeAll(async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password123' });
    authToken = res.body.accessToken;

    const dashRes = await request(app)
      .get('/api/dashboard/my-tasks')
      .set('Authorization', `Bearer ${authToken}`);
    if (dashRes.body.length > 0) {
      taskId = dashRes.body[0].id;
    }
  });

  describe('PUT /api/tasks/bulk-status', () => {
    it('should return 401 without auth token', async () => {
      const res = await request(app)
        .put('/api/tasks/bulk-status')
        .send({ taskIds: ['id1'], status: 'DONE' });
      expect(res.status).toBe(401);
    });

    it('should return 400 with missing fields', async () => {
      const res = await request(app)
        .put('/api/tasks/bulk-status')
        .set('Authorization', `Bearer ${authToken}`)
        .send({});
      expect(res.status).toBe(400);
    });

    it('should update multiple tasks status', async () => {
      if (!taskId) return;
      const res = await request(app)
        .put('/api/tasks/bulk-status')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ taskIds: [taskId], status: 'IN_PROGRESS' });
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message');
    });
  });

  describe('PUT /api/tasks/reorder', () => {
    it('should return 401 without auth token', async () => {
      const res = await request(app)
        .put('/api/tasks/reorder')
        .send({ taskId: 'id1', newPosition: 0 });
      expect(res.status).toBe(401);
    });

    it('should return 400 with missing fields', async () => {
      const res = await request(app)
        .put('/api/tasks/reorder')
        .set('Authorization', `Bearer ${authToken}`)
        .send({});
      expect(res.status).toBe(400);
    });

    it('should reorder a task', async () => {
      if (!taskId) return;
      const res = await request(app)
        .put('/api/tasks/reorder')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ taskId, newStatus: 'TODO', newPosition: 0 });
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('id', taskId);
    });
  });
});
