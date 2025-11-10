import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const application = Application.start()
application.debug = false
window.Stimulus = application

// Eager-load controllers from this folder (convention: *_controller.js)
eagerLoadControllersFrom("controllers", application)

export { application }