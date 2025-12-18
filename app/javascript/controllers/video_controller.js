import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["placeholder", "frame"]

  play() {
    this.placeholderTarget.classList.add("hidden")
    this.frameTarget.classList.remove("hidden")
    this.frameTarget.innerHTML = `
      <iframe 
        width="100%" 
        height="100%" 
        src="https://www.youtube.com/embed/LXb3EKWsInQ?autoplay=1&mute=0" 
        title="Domain Monitor Demo" 
        frameborder="0" 
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
        allowfullscreen
        class="absolute inset-0 w-full h-full rounded-2xl"
      ></iframe>
    `
  }
}
