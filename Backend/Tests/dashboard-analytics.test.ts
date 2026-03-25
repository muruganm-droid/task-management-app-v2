import request from 'supertest';
import app from '../Code/src/app';

describe('Dashboard Analytics API - GET /api/dashboard/analytics', () => {
  let authToken: string;

  beforeAll(async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password123' });
    authToken = res.body.accessToken;
  });

  it('should return 401 without auth token', async () => {
    const res = await request(app).get('/api/dashboard/analytics');
    expect(res.status).toBe(401);
  });

  it('should return analytics data', async () => {
    const res = await request(app)
      .get('/api/dashboard/analytics')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('completionRate');
    expect(res.body).toHaveProperty('totalTasks');
    expect(res.body).toHaveProperty('completedTasks');
    expect(res.body).toHaveProperty('overdueTasks');
    expect(res.body).toHaveProperty('avgCompletionDays');
    expect(res.body).toHaveProperty('tasksByPriority');
    expect(res.body).toHaveProperty('tasksByStatus');
    expect(res.body).toHaveProperty('teamWorkload');
    expect(res.body).toHaveProperty('weeklyStats');
    expect(Array.isArray(res.body.tasksByPriority)).toBe(true);
    expect(Array.isArray(res.body.tasksByStatus)).toBe(true);
    expect(Array.isArray(res.body.teamWorkload)).toBe(true);
    expect(Array.isArray(res.body.weeklyStats)).toBe(true);
  });

  it('should return completion rate as a number between 0 and 100', async () => {
    const res = await request(app)
      .get('/api/dashboard/analytics')
      .set('Authorization', `Bearer ${authToken}`);
    expect(typeof res.body.completionRate).toBe('number');
    expect(res.body.completionRate).toBeGreaterThanOrEqual(0);
    expect(res.body.completionRate).toBeLessThanOrEqual(100);
  });
});
