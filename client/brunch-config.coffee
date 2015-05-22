exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'js/plottaplot.js': /^app/
        'js/vendor.js': /^bower_components/
    stylesheets:
      joinTo:
        'css/plottaplot.css': /^app/
        'css/vendor.css': /^bower_components/
    templates:
      joinTo: 'js/plottaplot.js'


