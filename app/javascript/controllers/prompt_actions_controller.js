import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="prompt-actions"
export default class extends Controller {
  connect() {
    this.modal = document.getElementById('copy-action-modal')
    this.preview = document.getElementById('cam-prompt-preview')
    this.result = document.getElementById('cam-result')
    this.clickHandler = this.handleDocumentClick.bind(this)
    document.addEventListener('click', this.clickHandler)
  }

  disconnect() {
    document.removeEventListener('click', this.clickHandler)
  }

  handleDocumentClick(e) {
    const btn = e.target.closest('.copy-btn, .execute-btn')
    if (!btn) return

    const text = btn.dataset.text || ''
    const promptId = btn.dataset.promptId
    this.modal.dataset.text = text
    if (promptId) this.modal.dataset.promptId = promptId
    this.preview.textContent = text
    this.result.classList.add('hidden')
    this.modal.classList.remove('hidden')
    this.modal.classList.add('flex')

    if (btn.classList.contains('execute-btn')) {
      this.addExecButton()
    }
  }

  closeModal() {
    this.modal.classList.add('hidden')
    this.modal.classList.remove('flex')
    delete this.modal.dataset.text
    delete this.modal.dataset.promptId
  }

  async copyToClipboard() {
    const text = this.modal.dataset.text || ''
    try {
      await navigator.clipboard.writeText(text)
      this.result.textContent = 'Copied to clipboard ✔'
      this.result.classList.remove('hidden')
    } catch (err) {
      this.result.textContent = 'Failed to copy — copy manually.'
      this.result.classList.remove('hidden')
    }
  }

  addExecButton() {
    if (document.getElementById('cam-exec-server-btn')) return
    const container = this.modal.querySelector('.flex')
    const execBtn = document.createElement('button')
    execBtn.id = 'cam-exec-server-btn'
    execBtn.className = 'px-3 py-2 rounded bg-green-600 text-white'
    execBtn.textContent = 'Execute on server (ChatGPT)'
    execBtn.addEventListener('click', () => this.executeOnServer())
    container.prepend(execBtn)
  }

  async executeOnServer() {
    const id = this.modal.dataset.promptId
    if (!id) return
    this.result.textContent = 'Running…'
    this.result.classList.remove('hidden')

    try {
      const tokenMeta = document.querySelector('meta[name=\"csrf-token\"]')
      const token = tokenMeta ? tokenMeta.content : ''
      const res = await fetch(`/prompts/${id}/execute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token, 'Accept': 'application/json' },
        body: JSON.stringify({})
      })
      const data = await res.json()
      if (data.ok) {
        this.result.innerHTML = `<strong>Assistant:</strong><pre class=\"whitespace-pre-wrap mt-2\">${this.escapeHtml(data.assistant)}</pre>`
      } else {
        this.result.textContent = 'Error: ' + (data.error || 'Unknown error')
      }
    } catch (err) {
      this.result.textContent = 'Network or server error.'
    }
  }

  escapeHtml(unsafe) {
    return (unsafe || '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
  }
}
