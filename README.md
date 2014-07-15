data-projector
==============

See http://datacratic.com/site/blog/visualizing-high-dimensional-data-browser-svd-t-sne-and-threejs for details on this project.

To rebuild from coffeescript source:

    $ npm install
    $ node_modules/.bin/browserify -t coffeeify src/DataProjector.coffee > DataProjector.js
