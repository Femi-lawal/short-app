import { test, expect } from '@playwright/test';

test.describe('Health Checks', () => {
  test('health endpoint returns ok', async ({ request }) => {
    const response = await request.get('/health');
    expect(response.ok()).toBeTruthy();
    const body = await response.json();
    expect(body.status).toBe('ok');
  });

  test('readiness endpoint returns ok', async ({ request }) => {
    const response = await request.get('/readiness');
    expect(response.ok()).toBeTruthy();
  });

  test('metrics endpoint returns prometheus format', async ({ request }) => {
    const response = await request.get('/metrics');
    expect(response.ok()).toBeTruthy();
    const text = await response.text();
    expect(text).toContain('http_requests_total');
  });
});

test.describe('API v1 - Short URLs', () => {
  test('GET /api/v1/short_urls returns list', async ({ request }) => {
    const response = await request.get('/api/v1/short_urls');
    expect(response.ok()).toBeTruthy();
    const body = await response.json();
    expect(body.success).toBe(true);
    expect(Array.isArray(body.data)).toBeTruthy();
  });

  test('POST /api/v1/short_urls creates a short URL', async ({ request }) => {
    const response = await request.post('/api/v1/short_urls', {
      data: { short_url: { full_url: `https://example.com/test-${Date.now()}` } }
    });
    expect(response.status()).toBe(201);
    const body = await response.json();
    expect(body.success).toBe(true);
    expect(body.data.short_code).toBeTruthy();
  });

  test('POST /api/v1/short_urls returns 422 for invalid URL', async ({ request }) => {
    const response = await request.post('/api/v1/short_urls', {
      data: { short_url: { full_url: 'not-a-valid-url' } }
    });
    expect(response.status()).toBe(422);
  });

  test('GET /:short_code redirects to original URL', async ({ request }) => {
    // First create a URL
    const createResponse = await request.post('/api/v1/short_urls', {
      data: { short_url: { full_url: `https://example.com/redirect-${Date.now()}` } }
    });
    const { data } = await createResponse.json();
    
    // Then test redirect
    const response = await request.get(`/${data.short_code}`, { maxRedirects: 0 });
    expect(response.status()).toBe(301);
  });

  test('GET /invalid-code returns 404', async ({ request }) => {
    const response = await request.get('/nonexistent999');
    expect(response.status()).toBe(404);
  });
});
