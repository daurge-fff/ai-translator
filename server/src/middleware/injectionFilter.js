const INJECTION_PATTERNS = [
  /ignore\s+(all\s+)?(previous\s+)?instructions/i,
  /forget\s+(all\s+)?(previous\s+)?instructions/i,
  /забудь\s+(все\s+)?(предыдущие\s+)?инструкции/i,
  /ты\s+теперь\s+/i,
  /act\s+as\s+a\s+/i,
  /reveal\s+(your\s+)?system\s+prompt/i,
  /покажи\s+свой\s+системный\s+промпт/i,
  /system\s*:/i,
  /\[system\]/i
];

export const securityIncidentsLog = [];

export function injectionFilterMiddleware(req, res, next) {
  const { sourceText, source_text, userContext, user_context } = req.body || {};
  const textToCheck = (sourceText || source_text || '') + ' ' + (userContext || user_context || '');

  let isSuspicious = false;
  let matchedPattern = null;

  for (const pattern of INJECTION_PATTERNS) {
    if (pattern.test(textToCheck)) {
      isSuspicious = true;
      matchedPattern = pattern.toString();
      break;
    }
  }

  if (isSuspicious) {
    const incident = {
      id: Date.now().toString(),
      timestamp: new Date().toISOString(),
      user: req.user?.email || 'anonymous',
      deviceId: req.headers['x-device-id'] || 'unknown',
      ip: req.ip || req.headers['x-forwarded-for'] || '127.0.0.1',
      snippet: textToCheck.slice(0, 100),
      pattern: matchedPattern,
      severity: 'high'
    };
    securityIncidentsLog.unshift(incident);
    if (securityIncidentsLog.length > 100) securityIncidentsLog.pop();

    console.warn(`[SECURITY BLOCKED] ${req.user?.email}: ${matchedPattern}`);
    return res.status(403).json({
      error: 'Request blocked: suspicious content detected',
      code: 'INJECTION_DETECTED'
    });
  }

  next();
}
