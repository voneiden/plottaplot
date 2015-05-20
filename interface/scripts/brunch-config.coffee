exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'js/plotaplot.js': /^app/
        'js/vendor.js': /^bower_components/
    stylesheets:
      joinTo:
        'css/plotaplot.css': /^app/
        'css/vendor.css': /^bower_components/
    templates:
      joinTo: 'js/plottaplot.js'


