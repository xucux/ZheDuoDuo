/** Tailwind CDN 须在加载后读取此配置 */
window.tailwind = window.tailwind || {};
tailwind.config = {
  theme: {
    extend: {
      colors: {
        brand: { DEFAULT: '#46C01B', dark: '#3AA816', light: '#E8F8E0', muted: '#B8E6A3' },
        surface: { DEFAULT: 'var(--surface)', 2: 'var(--surface-2)', 3: 'var(--surface-3)' },
        ink: { DEFAULT: 'var(--text)', secondary: 'var(--text-secondary)', muted: 'var(--text-muted)' },
        page: 'var(--bg)',
      },
      boxShadow: {
        phone: '0 25px 50px -12px rgba(0,0,0,.35)',
        card: '0 2px 12px rgba(0,0,0,.08)',
      },
      borderRadius: { phone: '40px' },
    },
  },
};
