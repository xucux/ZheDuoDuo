/** 从 DataURL 或远程 URL 压缩图片（原型：远程受 CORS 限制） */
export function compressDataUrl(dataUrl, maxW = 800, quality = 0.7) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => {
      let w = img.width, h = img.height;
      if (w > maxW) { h = (h * maxW) / w; w = maxW; }
      const canvas = document.createElement('canvas');
      canvas.width = w;
      canvas.height = h;
      canvas.getContext('2d').drawImage(img, 0, 0, w, h);
      const compressed = canvas.toDataURL('image/jpeg', quality);
      resolve({
        dataUrl: compressed,
        meta: {
          width: w,
          height: h,
          quality: Math.round(quality * 100),
          compressedSize: Math.round(compressed.length * 0.75),
        },
      });
    };
    img.onerror = () => reject(new Error('图片解码失败'));
    img.src = dataUrl;
  });
}

export async function fetchAndCompressImage(url, maxW = 800, quality = 0.7) {
  const res = await fetch(url, { mode: 'cors' });
  if (!res.ok) throw new Error(`下载失败 HTTP ${res.status}`);
  const blob = await res.blob();
  if (!blob.type.startsWith('image/')) throw new Error('URL 不是有效图片');
  const dataUrl = await new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
  const result = await compressDataUrl(dataUrl, maxW, quality);
  return {
    ...result,
    meta: {
      ...result.meta,
      sourceUrl: url,
      originalSize: blob.size,
    },
  };
}

export function formatBytes(bytes) {
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(0) + ' KB';
  return (bytes / 1024 / 1024).toFixed(1) + ' MB';
}
