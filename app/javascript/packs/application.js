// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

require("trix")
require("@rails/actiontext")

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