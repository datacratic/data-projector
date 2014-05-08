# Panel.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Base abstract class for all UI panels. There are four classes derived from Panel:
# Menu - main application menu (left)
# Console - main output/info area (right)
# ToolBar - top window control
# StatusBar - bottom window helper

Subject = require('./Subject.coffee')

class Panel extends Subject

   # E V E N T S

   @EVENT_PANEL_SHOWN : "EVENT_PANEL_SHOWN"
   @EVENT_PANEL_HIDDEN : "EVENT_PANEL_HIDDEN"

   visible: true # default

   # C O N S T R U C T O R

   # Create panel. The id parameter is the id of the element in HTML (example: "#Menu")
   constructor: (@id) ->

      super()


   # Show this panel.
   show: ->

      $(@id).show()
      @visible = true
      @notify(Panel.EVENT_PANEL_SHOWN)


   # Hide this panel.
   hide: ->

      $(@id).hide()
      @visible = false
      @notify(Panel.EVENT_PANEL_HIDDEN)


   # Toggle visibility.
   toggle: ->

      if @visible then @hide() else @show()
      return @visible   


module.exports = Panel