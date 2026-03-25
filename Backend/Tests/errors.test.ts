import {
  AppError,
  notFoundError,
  unauthorizedError,
  forbiddenError,
  badRequestError,
  conflictError,
} from '../Code/src/utils/errors';

describe('AppError', () => {
  it('sets message, statusCode, and code', () => {
    const err = new AppError('Something went wrong', 500, 'SERVER_ERROR');
    expect(err.message).toBe('Something went wrong');
    expect(err.statusCode).toBe(500);
    expect(err.code).toBe('SERVER_ERROR');
    expect(err).toBeInstanceOf(Error);
    expect(err).toBeInstanceOf(AppError);
  });

  it('defaults statusCode to 500 when not provided', () => {
    const err = new AppError('Oops');
    expect(err.statusCode).toBe(500);
  });
});

describe('Error factory functions', () => {
  it('notFoundError returns 404', () => {
    const err = notFoundError('Task');
    expect(err.statusCode).toBe(404);
    expect(err.message).toMatch(/task not found/i);
    expect(err.code).toBe('NOT_FOUND');
  });

  it('notFoundError uses default resource name', () => {
    const err = notFoundError();
    expect(err.message).toMatch(/resource not found/i);
  });

  it('unauthorizedError returns 401', () => {
    const err = unauthorizedError();
    expect(err.statusCode).toBe(401);
    expect(err.code).toBe('UNAUTHORIZED');
  });

  it('unauthorizedError accepts custom message', () => {
    const err = unauthorizedError('Token expired');
    expect(err.message).toBe('Token expired');
  });

  it('forbiddenError returns 403', () => {
    const err = forbiddenError();
    expect(err.statusCode).toBe(403);
    expect(err.code).toBe('FORBIDDEN');
  });

  it('badRequestError returns 400', () => {
    const err = badRequestError('Invalid input');
    expect(err.statusCode).toBe(400);
    expect(err.message).toBe('Invalid input');
    expect(err.code).toBe('BAD_REQUEST');
  });

  it('conflictError returns 409', () => {
    const err = conflictError('Already exists');
    expect(err.statusCode).toBe(409);
    expect(err.code).toBe('CONFLICT');
  });
});
