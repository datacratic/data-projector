data-projector
==============

See http://datacratic.com/site/blog/visualizing-high-dimensional-data-browser-svd-t-sne-and-threejs for details on this project.

A live demo of this code is available here: http://opensource.datacratic.com/data-projector/

To rebuild from coffeescript source:

    $ npm install
    $ node_modules/.bin/browserify -t coffeeify src/DataProjector.coffee > DataProjector.js
