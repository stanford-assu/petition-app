import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

window.addEventListener("trix-file-accept", function(event) {
    const maxFileSize = 2 * 1024 * 1024 // 2MB 
    if (event.file.size > maxFileSize) {
        event.preventDefault()
        alert("Only support attachment files upto size 1MB!")
    }

    const acceptedTypes = ['image/jpeg', 'image/png', 'application/pdf']
    if (!acceptedTypes.includes(event.file.type)) {
      event.preventDefault()
      alert("Only support attachment of JPEG, PNG, PDF files")
    }

  })