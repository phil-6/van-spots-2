# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true

pin "@googlemaps/markerclusterer", to: "@googlemaps--markerclusterer.js" # @2.5.3
pin "fast-deep-equal" # @3.1.3
pin "kdbush", to: "kdbush.js" # @4.0.2
pin "supercluster" # @8.0.1
