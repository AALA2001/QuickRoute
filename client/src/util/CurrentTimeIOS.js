export default function getCurrentTimeISO() {
    const date = new Date();
    
    const isoString = date.toISOString();
    const microseconds = (date.getMilliseconds() * 1000).toString().padStart(6, '0');
    return `${isoString.slice(0, -1)}.${microseconds}Z`;
}
