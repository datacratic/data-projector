# Info.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Controls application info console on the right side of the application window.

Panel = require('./Panel.coffee')

class Info extends Panel


   # C O N S T R U C T O R

   # Create info console panel.
   constructor: (id) ->

      super(id)


   # M E T H O D S

   # Display given message keeping the existing text intact.
   display: (message) ->

      $('#message').append(message + "<br/>")


   # Clear the info console.
   clear: ->
      
      $('#message').text("")


module.exports = Info