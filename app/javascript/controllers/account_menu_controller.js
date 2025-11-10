import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this._onDocumentClick = this._onDocumentClick.bind(this)
  }

  disconnect() {
    // Ensure no stray listeners remain if the element is removed while open
    document.removeEventListener("click", this._onDocumentClick)
  }

  toggle(e) {
    e?.preventDefault()
    const isHidden = this.menuTarget.classList.contains("hidden")

    // close other account menus
    document.querySelectorAll('[data-account-menu-target="menu"]').forEach(m => m.classList.add("hidden"))

    if (isHidden) {
      this.menuTarget.classList.remove("hidden")
      document.addEventListener("click", this._onDocumentClick)
      this.buttonTarget?.setAttribute("aria-expanded", "true")
    } else {
      this.menuTarget.classList.add("hidden")
      document.removeEventListener("click", this._onDocumentClick)
      this.buttonTarget?.setAttribute("aria-expanded", "false")
    }
  }

  _onDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      document.removeEventListener("click", this._onDocumentClick)
      this.buttonTarget?.setAttribute("aria-expanded", "false")
    }
  }
}
