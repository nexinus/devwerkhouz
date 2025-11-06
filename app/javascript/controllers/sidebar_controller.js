// simple global toggle (keep minimal)
window.toggleSidebar = function() {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar) return;
    sidebar.classList.toggle('w-64');
    sidebar.classList.toggle('w-16');
  
    // show/hide labels
    document.querySelectorAll('#sidebar [data-label]').forEach(el => {
      el.classList.toggle('hidden');
    });
  
    // swap new prompt versions
    const top = document.getElementById('newPromptTop');
    const compact = document.getElementById('newPromptCompact');
    if (sidebar.classList.contains('w-16')) {
      top?.classList.add('hidden');
      compact?.classList.remove('hidden');
    } else {
      top?.classList.remove('hidden');
      compact?.classList.add('hidden');
    }
  };
  