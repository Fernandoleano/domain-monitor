import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.close()
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  close(event) {
    if (event && this.element.contains(event.target)) return
    this.menuTarget.classList.add("hidden")
  }
  
  // Close when hitting escape
  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
