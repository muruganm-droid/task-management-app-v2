import request from 'supertest';
import app from '../Code/src/app';

// These tests assume a running test database with seeded data.
// Run `npm run db:seed` before executing tests.

describe('Search API - GET /api/search', () => {
  let authToken: string;

  beforeAll(async () => {
    // Login to get auth token
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password123' });
    authToken = res.body.accessToken;
  });

  it('should return 401 without auth token', async () => {
    const res = await request(app).get('/api/search');
    expect(res.status).toBe(401);
  });

  it('should search tasks by query', async () => {
    const res = await request(app)
      .get('/api/search?q=test&type=tasks')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('tasks');
    expect(Array.isArray(res.body.tasks)).toBe(true);
  });

  it('should search projects by query', async () => {
    const res = await request(app)
      .get('/api/search?q=test&type=projects')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('projects');
    expect(Array.isArray(res.body.projects)).toBe(true);
  });

  it('should search both tasks and projects', async () => {
    const res = await request(app)
      .get('/api/search?q=test&type=tasks,projects')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('tasks');
    expect(res.body).toHaveProperty('projects');
  });

  it('should filter tasks by status', async () => {
    const res = await request(app)
      .get('/api/search?type=tasks&status=TODO')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    if (res.body.tasks.length > 0) {
      expect(res.body.tasks.every((t: { status: string }) => t.status === 'TODO')).toBe(true);
    }
  });

  it('should filter tasks by priority', async () => {
    const res = await request(app)
      .get('/api/search?type=tasks&priority=HIGH')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    if (res.body.tasks.length > 0) {
      expect(res.body.tasks.every((t: { priority: string }) => t.priority === 'HIGH')).toBe(true);
    }
  });
});
