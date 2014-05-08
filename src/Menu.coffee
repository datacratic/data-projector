# Menu.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Main application menu on the left side of the application window.

Panel = require('./Panel.coffee')

class Menu extends Panel

   # E V E N T S

   @EVENT_TOGGLE_ALL_ON : "EVENT_TOGGLE_ALL_ON"
   @EVENT_TOGGLE_ALL_OFF : "EVENT_TOGGLE_ALL_OFF"

   @EVENT_TOGGLE_ID : "EVENT_TOGGLE_ID"
   @EVENT_CLUSTER_ID : "EVENT_CLUSTER_ID"

   # C O N S T A N T S

   @TOGGLE_ON : "[+]"
   @TOGGLE_OFF : "[-]"
   @TOGGLE_MIX : "[/]"

   # M E M B E R S

   clusters : 0 # total number of clusters

   selected : -1 # currently selected cluster

   colors : null # set of colors to use


   # C O N S T R U C T O R
   
   constructor : (id) ->

      super(id)


   # E V E N T   H A N D L E R S

   # Toggle visibility of all clusters at once. 
   onToggleAll : (event) =>

      state = $("#toggleAll").text()

      switch state

         when Menu.TOGGLE_OFF, Menu.TOGGLE_MIX # turn all on

            $("#toggleAll").text(Menu.TOGGLE_ON)

            for i in [0...@clusters]
               $("#t" + String(i)).text(Menu.TOGGLE_ON)

            @notify(Menu.EVENT_TOGGLE_ALL_ON)   

         when Menu.TOGGLE_ON # turn all off

            $("#toggleAll").text(Menu.TOGGLE_OFF)

            for i in [0...@clusters]
               $("#t" + String(i)).text(Menu.TOGGLE_OFF)

            @notify(Menu.EVENT_TOGGLE_ALL_OFF)   


   onToggle : (event) =>

      identifier = event.target.id 
      id = identifier.replace("t", "")
      index = parseInt(id)

      @doToggle(index)
      @notify(Menu.EVENT_TOGGLE_ID, { id : index })


   onCluster : (event) =>

      # retrieve clicked cluster number
      index = parseInt(event.target.id.replace("b", ""))

      if @selected is index then @selected = -1 # unselect
      else @selected = index # select

      @updateSwatches()
      @updateButtons()

      @notify(Menu.EVENT_CLUSTER_ID, { id : index })


   # Flip toggle given by its index. 
   doToggle : (index) ->

      tag = "#t" + String(index)
      state = $(tag).text()

      switch state

         when Menu.TOGGLE_ON
            $(tag).text(Menu.TOGGLE_OFF)

         when Menu.TOGGLE_OFF
            $(tag).text(Menu.TOGGLE_ON)

      @updateMasterToggle()


   # M E T H O D S

   # Create dynamically menu for given number of clusters.
   # Use given set of colors for color coding to match visualization. 
   create : (@clusters, @colors) ->

      # button IDs are b0, b1, b2...
      # toggle IDs are t0, t1, t2...
      # swatch IDs are c0, c1, c2...

      for i in [0...@clusters]
         html = "<span class='toggle' id='t#{i}'>[+]</span><span class='button' id='b#{i}'> Cluster</span><span class='color' id='c#{i}'> #{i} </span><br/>"
         $("#menu").append(html) 

      $("#toggleAll").click(@onToggleAll)

      for i in [0...@clusters]
         $("#t" + String(i)).click( @onToggle )
         $("#b" + String(i)).click( @onCluster )

      @updateSwatches()  


   # Count how many toggles are on.
   togglesOn : ->

      result = 0

      for i in [0...@clusters]
         tag = "#t" + String(i)
         state = $(tag).text()
         if state is Menu.TOGGLE_ON then result++

      return result

      

   # Based on the state of all cluster toggles, set the master toggle.
   updateMasterToggle : () ->      

      shown = @togglesOn()

      switch shown
         when 0 then $("#toggleAll").text(Menu.TOGGLE_OFF)
         when @clusters then $("#toggleAll").text(Menu.TOGGLE_ON)
         else $("#toggleAll").text(Menu.TOGGLE_MIX)


   # Swatches have IDs: c0, c1, c2...
   updateSwatches : ->

      for i in [0...@clusters]
         if i is @selected
            $("#c" + String(i)).css( 'color', Palette.HIGHLIGHT.getStyle() )
         else
            $("#c" + String(i)).css( 'color', @colors[i].getStyle() )


   # Cluster buttons have IDs: b0, b1, b2...
   updateButtons : ->

      for i in [0...@clusters]
         if i is @selected
            $("#b" + String(i)).css( 'color', Palette.HIGHLIGHT.getStyle() )
         else
            $("#b" + String(i)).css( 'color', Palette.BUTTON.getStyle() )


module.exports = Menu
