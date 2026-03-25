import request from 'supertest';
import app from '../Code/src/app';
import prisma from '../Code/src/models/prisma';

// Use a real test DB or mock Prisma.
// For this test suite we mock Prisma to keep tests isolated.

jest.mock('../Code/src/models/prisma', () => ({
  __esModule: true,
  default: {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(),
      findUnique: jest.fn(),
      deleteMany: jest.fn(),
      delete: jest.fn(),
    },
  },
}));

const mockPrisma = prisma as jest.Mocked<typeof prisma>;

beforeEach(() => jest.clearAllMocks());

// ─── Register ────────────────────────────────────────────────────────────────

describe('POST /api/auth/register', () => {
  it('returns 201 with user and tokens on valid input', async () => {
    (mockPrisma.user.findUnique as jest.Mock).mockResolvedValue(null);
    (mockPrisma.user.create as jest.Mock).mockResolvedValue({
      id: 'u1', name: 'Jane', email: 'jane@test.com', avatarUrl: null, bio: null, createdAt: new Date(),
    });
    (mockPrisma.refreshToken.create as jest.Mock).mockResolvedValue({});

    const res = await request(app).post('/api/auth/register').send({
      name: 'Jane', email: 'jane@test.com', password: 'Password1',
    });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('user');
    expect(res.body).toHaveProperty('tokens.accessToken');
    expect(res.body.user).not.toHaveProperty('password');
  });

  it('returns 409 when email already exists', async () => {
    (mockPrisma.user.findUnique as jest.Mock).mockResolvedValue({ id: 'u1', email: 'jane@test.com' });

    const res = await request(app).post('/api/auth/register').send({
      name: 'Jane', email: 'jane@test.com', password: 'Password1',
    });

    expect(res.status).toBe(409);
    expect(res.body.message).toMatch(/already exists/i);
  });

  it('returns 400 for missing name', async () => {
    const res = await request(app).post('/api/auth/register').send({
      email: 'jane@test.com', password: 'Password1',
    });
    expect(res.status).toBe(400);
  });

  it('returns 400 for weak password (no uppercase)', async () => {
    const res = await request(app).post('/api/auth/register').send({
      name: 'Jane', email: 'jane@test.com', password: 'password1',
    });
    expect(res.status).toBe(400);
  });

  it('returns 400 for invalid email format', async () => {
    const res = await request(app).post('/api/auth/register').send({
      name: 'Jane', email: 'not-an-email', password: 'Password1',
    });
    expect(res.status).toBe(400);
  });
});

// ─── Login ───────────────────────────────────────────────────────────────────

describe('POST /api/auth/login', () => {
  it('returns 401 for non-existent email', async () => {
    (mockPrisma.user.findUnique as jest.Mock).mockResolvedValue(null);

    const res = await request(app).post('/api/auth/login').send({
      email: 'nobody@test.com', password: 'Password1',
    });

    expect(res.status).toBe(401);
    expect(res.body.message).toMatch(/invalid email or password/i);
  });

  it('returns 400 for missing fields', async () => {
    const res = await request(app).post('/api/auth/login').send({ email: 'jane@test.com' });
    expect(res.status).toBe(400);
  });
});

// ─── Logout ──────────────────────────────────────────────────────────────────

describe('POST /api/auth/logout', () => {
  it('returns 200 and deletes refresh token when provided', async () => {
    (mockPrisma.refreshToken.deleteMany as jest.Mock).mockResolvedValue({ count: 1 });

    const res = await request(app).post('/api/auth/logout').send({ refreshToken: 'some-token' });

    expect(res.status).toBe(200);
    expect(res.body.message).toMatch(/logged out/i);
    expect(mockPrisma.refreshToken.deleteMany).toHaveBeenCalledWith({ where: { token: 'some-token' } });
  });

  it('returns 200 even without a refresh token', async () => {
    const res = await request(app).post('/api/auth/logout').send({});
    expect(res.status).toBe(200);
  });
});

// ─── Health ──────────────────────────────────────────────────────────────────

describe('GET /api/health', () => {
  it('returns 200 with status ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });
});

// ─── 404 ─────────────────────────────────────────────────────────────────────

describe('Unknown routes', () => {
  it('returns 404 for undefined routes', async () => {
    const res = await request(app).get('/api/does-not-exist');
    expect(res.status).toBe(404);
  });
});
