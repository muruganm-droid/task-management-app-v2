import { Request, Response } from 'express';
import { authenticate } from '../Code/src/middleware/authenticate';
import { signAccessToken } from '../Code/src/utils/jwt';

function mockReq(authHeader?: string): Partial<Request> {
  return { headers: { authorization: authHeader } } as Partial<Request>;
}

function mockRes(): Partial<Response> {
  return {} as Partial<Response>;
}

describe('authenticate middleware', () => {
  it('calls next with error when no Authorization header', () => {
    const next = jest.fn();
    authenticate(mockReq() as Request, mockRes() as Response, next);
    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 401 }));
  });

  it('calls next with error when header does not start with Bearer', () => {
    const next = jest.fn();
    authenticate(mockReq('Basic abc123') as Request, mockRes() as Response, next);
    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 401 }));
  });

  it('calls next with error when token is invalid', () => {
    const next = jest.fn();
    authenticate(mockReq('Bearer bad.token.here') as Request, mockRes() as Response, next);
    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 401 }));
  });

  it('attaches userId and userEmail and calls next() when token is valid', () => {
    const next = jest.fn();
    const token = signAccessToken({ userId: 'u1', email: 'u@test.com' });
    const req = mockReq(`Bearer ${token}`) as Request & { userId: string; userEmail: string };

    authenticate(req, mockRes() as Response, next);

    expect(next).toHaveBeenCalledWith(); // no error arg
    expect(req.userId).toBe('u1');
    expect(req.userEmail).toBe('u@test.com');
  });
});
