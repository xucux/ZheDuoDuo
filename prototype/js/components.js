export const NavBar = {
  props: ['title'],
  emits: ['back'],
  template: `
    <div class="px-4 py-3 bg-[var(--surface)] border-b border-[var(--border)] flex items-center gap-3">
      <button @click="$emit('back')" class="w-9 h-9 rounded-full flex items-center justify-center text-ink-secondary hover:bg-surface-2"><i class="fa-solid fa-arrow-left"></i></button>
      <h3 class="font-semibold text-ink flex-1">{{ title }}</h3>
    </div>
  `
};

