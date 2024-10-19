export default function decodeJWT(token) {
    const urlDecodedToken = decodeURIComponent(token);
    const parts = urlDecodedToken.split('.');

    if (parts.length !== 3) {
      throw new Error('Invalid JWT format');
    }

    const base64UrlPayload = parts[1];
    const base64Payload = base64UrlPayload.replace(/-/g, '+').replace(/_/g, '/');

    const jsonPayload = decodeURIComponent(atob(base64Payload).split('').map(function (c) {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));

    return JSON.parse(jsonPayload);
  }