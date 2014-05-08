# Toolbar.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Application top of the window menu toolbar.

Utility = require('./Utility.coffee')
Panel = require('./Panel.coffee')
Palette = require('./Palette.coffee')

class Toolbar extends Panel

   # E V E N T S

   @EVENT_MENU : "EVENT_MENU"
   @EVENT_INFO : "EVENT_INFO"
   @EVENT_PERSPECTIVE : "EVENT_PERSPECTIVE"
   @EVENT_ORTHOGRAPHIC : "EVENT_ORTHOGRAPHIC"
   @EVENT_DUAL : "EVENT_DUAL"
   @EVENT_RESET : "EVENT_RESET"
   @EVENT_CLEAR : "EVENT_CLEAR"
   @EVENT_BOX : "EVENT_BOX"
   @EVENT_VIEWPORT : "EVENT_VIEWPORT"
   @EVENT_SELECT : "EVENT_SELECT"
   @EVENT_VIEW_TOP : "EVENT_VIEW_TOP"
   @EVENT_VIEW_FRONT : "EVENT_VIEW_FRONT"
   @EVENT_VIEW_SIDE : "EVENT_VIEW_SIDE"
   @EVENT_SPIN_LEFT : "EVENT_SPIN_LEFT"
   @EVENT_SPIN_STOP : "EVENT_SPIN_STOP"
   @EVENT_SPIN_RIGHT : "EVENT_SPIN_RIGHT"
   @EVENT_ANIMATE : "EVENT_ANIMATE"


   # M E M B E R S
   
   dispatcher : null # map of IDs and event handlers

   # C O N S T R U C T O R

   constructor : (id) ->

      super(id)

      @createDispatcher()

      for item in @dispatcher
         $(item.id).click({ type : item.type }, @onClick)

      document.addEventListener('keydown', @onKeyDown, false)

      @initialize()


   # E V E N T   H A N D L E R S

   # Called when key pressed.
   onKeyDown : (event) =>

      # console.log event.keyCode + " : " + event.shiftKey

      modifier = Utility.NO_KEY # default

      if event.shiftKey then modifier = Utility.SHIFT_KEY

      for item in @dispatcher
         if (item.key is event.keyCode) and (item.modifier is modifier) then @notify(item.type)



   onClick : (event) =>
      @notify(event.data.type)


   # M E T H O D S

   # Create centralized event registration and dispatch map
   createDispatcher : =>

      # NOTE key == 0 means no shortcut assigned

      @dispatcher = [ { id : "#menuButton", key : 77, modifier : Utility.NO_KEY, type : Toolbar.EVENT_MENU },
                      { id : "#infoButton", key : 73, modifier : Utility.NO_KEY, type : Toolbar.EVENT_INFO },
                      { id : "#perspectiveButton", key : 80, modifier : Utility.NO_KEY, type : Toolbar.EVENT_PERSPECTIVE },
                      { id : "#orthographicButton", key : 79, modifier : Utility.NO_KEY, type : Toolbar.EVENT_ORTHOGRAPHIC },
                      { id : "#dualButton", key : 68, modifier : Utility.NO_KEY, type : Toolbar.EVENT_DUAL },
                      { id : "#resetButton", key : 82, modifier : Utility.NO_KEY, type : Toolbar.EVENT_RESET },
                      { id : "#clearButton", key : 67, modifier : Utility.NO_KEY, type : Toolbar.EVENT_CLEAR },
                      { id : "#boxButton", key : 66, modifier : Utility.NO_KEY, type : Toolbar.EVENT_BOX },
                      { id : "#viewportButton", key : 86, modifier : Utility.NO_KEY, type : Toolbar.EVENT_VIEWPORT },
                      { id : "#selectButton", key : 83, modifier : Utility.NO_KEY, type : Toolbar.EVENT_SELECT },
                      { id : "#viewTopButton", key : 49, modifier : Utility.NO_KEY, type : Toolbar.EVENT_VIEW_TOP },
                      { id : "#viewFrontButton", key : 50, modifier : Utility.NO_KEY, type : Toolbar.EVENT_VIEW_FRONT },
                      { id : "#viewSideButton", key : 51, modifier : Utility.NO_KEY, type : Toolbar.EVENT_VIEW_SIDE },
                      { id : "#spinLeftButton", key : 37, modifier : Utility.NO_KEY, type : Toolbar.EVENT_SPIN_LEFT },
                      { id : "#spinStopButton", key : 32, modifier : Utility.NO_KEY, type : Toolbar.EVENT_SPIN_STOP },
                      { id : "#spinRightButton", key : 39, modifier : Utility.NO_KEY, type : Toolbar.EVENT_SPIN_RIGHT },
                      { id : "#animateButton", key : 65, modifier : Utility.NO_KEY, type : Toolbar.EVENT_ANIMATE },
                    ]

   initialize : =>

      @setButtonSelected("#menuButton", true)
      @setButtonSelected("#infoButton", true)

      @setButtonSelected("#perspectiveButton", false)
      @setButtonSelected("#orthographicButton", false)
      @setButtonSelected("#dualButton", true)

      @setButtonSelected("#boxButton", true)
      @setButtonSelected("#viewportButton", true)

      @setButtonSelected("#selectButton", false)

      @setButtonSelected("#viewTopButton", true)
      @setButtonSelected("#viewFrontButton", false)
      @setButtonSelected("#viewSideButton", false)

      @setButtonSelected("#spinLeftButton", false)
      @setButtonSelected("#spinStopButton", true)
      @setButtonSelected("#spinRightButton", false)

      @setButtonSelected("#animateButton", false)


   setButtonSelected : (id, selected) =>

      color = Palette.BUTTON.getStyle()
      if selected then color = Palette.BUTTON_SELECTED.getStyle()

      $(id).css('color', color)


   blinkButton : (id) =>

      @setButtonSelected(id, true)
      window.setTimeout(@unblinkButton, 200, id)


   unblinkButton : (id) =>
   
      console.log "Toolbar.unblinkButton " + id
      @setButtonSelected(id, false)


   setMenuButtonSelected : (selected) =>

      @setButtonSelected("#menuButton", selected)


   setInfoButtonSelected : (selected) =>

      @setButtonSelected("#infoButton", selected)


   setCameraButtonSelected : (selected1, selected2, selected3) =>

      @setButtonSelected("#perspectiveButton", selected1)
      @setButtonSelected("#orthographicButton", selected2)
      @setButtonSelected("#dualButton", selected3)


   blinkResetButton : =>
   
      @blinkButton("#resetButton")


   blinkClearButton : =>
   
      @blinkButton("#clearButton")


   setBoxButtonSelected : (selected) =>

      @setButtonSelected("#boxButton", selected)


   setViewportButtonSelected : (selected) =>

      @setButtonSelected("#viewportButton", selected)


   setSelectButtonSelected : (selected) =>

      @setButtonSelected("#selectButton", selected)


   setViewButtonSelected : (selected1, selected2, selected3) =>

      @setButtonSelected("#viewTopButton", selected1)
      @setButtonSelected("#viewFrontButton", selected2)
      @setButtonSelected("#viewSideButton", selected3)


   setSpinButtonSelected : (selected1, selected2, selected3) =>

      @setButtonSelected("#spinLeftButton", selected1)
      @setButtonSelected("#spinStopButton", selected2)
      @setButtonSelected("#spinRightButton", selected3)


   setAnimateButtonSelected : (selected) =>

      @setButtonSelected("#animateButton", selected)




module.exports = Toolbar
