# Projector.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Projector class displays the data visualization.
# Images are rendered in WebGL on HTML5 Canvas using Three.js library.

# TODO Extend selection to work in ORTHOGRAPHIC and PERSPECTIVE, not only DUAL mode.

Subject = require('./Subject.coffee')
Utility = require('./Utility.coffee')
Palette = require('./Palette.coffee')
Selector = require('./Selector.coffee')

class Projector extends Subject

   # E V E N T S

   @EVENT_DATA_LOADED : "EVENT_DATA_LOADED"
   @EVENT_POINTS_SELECTED : "EVENT_POINTS_SELECTED"
   @EVENT_CLUSTER_SELECTED : "EVENT_CLUSTER_SELECTED"

   # C O N S T A N T S

   # three view/display modes
   @VIEW : { NONE: -1, PERSPECTIVE: 0, ORTHOGRAPHIC: 1, DUAL: 2 }

   # spin clock or counter clockwise
   @SPIN : { LEFT: -1, NONE: 0, RIGHT: +1 }

   @SPIN_STEP : Utility.DEGREE / 10 # 0.1 degree - default step

   # M E M B E R S

   # these are pseudo constants which are redefined when browser resizes
   SCREEN_WIDTH : window.innerWidth
   SCREEN_HEIGHT : window.innerHeight

   mode : Projector.VIEW.DUAL # starting default

   storage : null # reference to the data storage

   colors : null # Array<THREE.Color> generated color values for visualization

   scene : null # THREE.Scene

   # perspective (3D) and orthographic (2D) projection cameras

   cameraPerspective : null # THREE.PerspectiveCamera
   cameraOrthographic : null # THREE.OrthographicCamera

   renderer : null # THREE.WebGLRenderer

   # mouse tracking variables
   mouse : new THREE.Vector3() # current mouse coordinates when selecting
   mouseStart : new THREE.Vector3() # mouse down coordinates when selecting
   mouseEnd : new THREE.Vector3() # mouse up coordinates when selecting
   dragging : false # true when rubber banding...

   selector : null # Selector

   # visual helpers for data display
   box : null # THREE.Mesh - data cage  
   viewport : null # parent of selectable view rectangles
   direction : Utility.DIRECTION.TOP # default 2D view is from top
   view1 : null # THREE.Line - 2D orthographic view box - top
   view2 : null # THREE.Line - 2D orthographic view box - front
   view3 : null # THREE.Line - 2D orthographic view box - side

   # visual representations of loaded data
   points : null # Array<THREE.Geometry>
   particles : null # Array<THREE.ParticleSystem>
   clusters : null # array of particle systems one per cluster

   selected : -1 # currently selected cluster

   controls : null # THREE.TrackballControls

   timeStamp : 0

   # C O N S T R U C T O R

   # Create projector.
   # Constructor creates all initial setup to make projector ready for data.
   constructor: ->

      super()

      @addUIListeners() # listen for UI events

      @scene = new THREE.Scene() # 3D world

      @createPerspectiveCamera() # left side (dual mode): 3D perspective camera
      @createOrthographicCamera() # right side (dual mode): 2D ortographic projection camera

      @createControls() # trackball simulation controls

      @createBox() # bounding box for the data

      @cameraPerspective.lookAt( @box.position )
      @cameraOrthographic.lookAt( @box.position )

      @createViews()
      @updateView(true)

      @selector = new Selector(@box) # 3D rubber band selector

      @createRenderingEngine() # set up WebGL renderer on canvas

      @onWindowResize(null)

      @animate() # start rendering loop!


   # E V E N T   H A N D L E R S

   # Make updates related to window size changes.
   # Also used when view configuration is switched.
   onWindowResize : (event) =>

      @SCREEN_WIDTH = window.innerWidth
      @SCREEN_HEIGHT = window.innerHeight

      console.log "Screen #{@SCREEN_WIDTH} x #{@SCREEN_HEIGHT}"

      if @renderer?

         @renderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT )

         switch @mode

            when Projector.VIEW.PERSPECTIVE
               @cameraPerspective.aspect = @SCREEN_WIDTH / @SCREEN_HEIGHT
               @cameraPerspective.updateProjectionMatrix()

            when Projector.VIEW.ORTHOGRAPHIC
               @cameraOrthographic.left   = - (@SCREEN_WIDTH / 8)
               @cameraOrthographic.right  = + (@SCREEN_WIDTH / 8)
               @cameraOrthographic.top    = + (@SCREEN_HEIGHT / 8)
               @cameraOrthographic.bottom = - (@SCREEN_HEIGHT / 8)
               @cameraOrthographic.updateProjectionMatrix()

            when Projector.VIEW.DUAL
               # left side
               @cameraPerspective.aspect = 0.5 * @SCREEN_WIDTH / @SCREEN_HEIGHT
               @cameraPerspective.updateProjectionMatrix()
               # right side
               @cameraOrthographic.left   = - (@SCREEN_WIDTH / 10)
               @cameraOrthographic.right  = + (@SCREEN_WIDTH / 10)
               @cameraOrthographic.top    = + (@SCREEN_HEIGHT / 5)
               @cameraOrthographic.bottom = - (@SCREEN_HEIGHT / 5)
               @cameraOrthographic.updateProjectionMatrix()

      @controls.handleResize()


   onMouseDown : (event) =>

      if @mode is Projector.VIEW.DUAL

         event.preventDefault()

         if event.shiftKey

            @dragging = true
            @updateMouse3D()
            @mouseStart.copy(@mouse)
            @selector.start(@mouseStart.clone())
            
            event.stopPropagation()


   onMouseMove : (event) =>

      if @mode is Projector.VIEW.DUAL

         event.preventDefault()

         if @dragging

            @updateMouse3D()
            @selector.update(@mouse)

            event.stopPropagation()


   onMouseUp : (event) =>

      if @mode is Projector.VIEW.DUAL

         event.preventDefault()

         if @dragging

            @dragging = false
            @updateMouse3D()
            @mouseEnd.copy(@mouse)
            @selector.end(@mouseEnd.clone())
            @updateSelection()

            event.stopPropagation()


   # Toggle next cluster during the animated walk through.
   onTimer : (index) =>

      @toggleClusterVisibility(index)
      if ++index is @storage.getClusters() then index = 0
      if @animateOn then @startTimer(index)


   # M E T H O D S

   # Set the current mode.
   setMode : (@mode) =>

      @onWindowResize(null)


   # Use given color set for visualization.
   setColors : (@colors) =>


   # Toggle box visibility. Return current state.
   toggleBox : => return (@box.visible = not @box.visible)


   # Toggle viewport visibility. Return current state.
   toggleViewport : => return @updateView(not @viewport.visible)


   toggleSelector : =>
   
      state = @selector.toggle()
      @updateSelection()
      return state


   # Get the base 64 encoded image of the current state of the projector.
   getImage : =>

      return document.getElementById("renderer").toDataURL("image/png")


   # Hook up to browser and mouse events.
   addUIListeners : =>

      window.addEventListener('resize', @onWindowResize, false)

      # container will hold WebGL canvas

      $('#container').mousedown(@onMouseDown)
      $('#container').mousemove(@onMouseMove)
      $('#container').mouseup(@onMouseUp)


   # Proper 3D camera.
   createPerspectiveCamera : =>

      # NOTE Cameras aspect ratio setup matches the half screen viewports for initial dual mode

      @cameraPerspective = new THREE.PerspectiveCamera( 50, 0.5 * @SCREEN_WIDTH / @SCREEN_HEIGHT, 150, 1000 )
      @cameraPerspective.position.set(0, 0, 550)
      @scene.add( @cameraPerspective )


   # Flat, 2D, no perspective camera.
   createOrthographicCamera : =>

      @cameraOrthographic = new THREE.OrthographicCamera( - (@SCREEN_WIDTH / 8),
                                                          + (@SCREEN_WIDTH / 8),
                                                          + (@SCREEN_HEIGHT / 4),
                                                          - (@SCREEN_HEIGHT / 4),
                                                          250, 750 )
      @cameraOrthographic.position.set(0, 500, 0)
      @scene.add( @cameraOrthographic )


   # Initialize simulated trackball navigation controls
   createControls : =>

      @controls = new THREE.TrackballControls( @cameraPerspective )

      @controls.rotateSpeed = 1.0
      @controls.zoomSpeed = 1.0
      @controls.panSpeed = 0.8

      @controls.noZoom = false
      @controls.noPan = false

      @controls.staticMoving = true
      @controls.dynamicDampingFactor = 0.3

      @controls.addEventListener('change', @render)


   # Bounding box where the data is displayed.
   createBox : =>

      @box = new THREE.Mesh(new THREE.CubeGeometry(200, 200, 200),
                            new THREE.MeshBasicMaterial({ color: 0x404040, wireframe: true }))
      @scene.add(@box)


   # Create a set of highlights that indicate ortographic projection in perspective view.
   # Each rectangle simply indicates where 2D view is within the 3D space.
   createViews : =>

      @viewport = new THREE.Object3D()

      # top view
      geometry1 = new THREE.Geometry()
      geometry1.vertices.push( new THREE.Vector3( +100, +101, +100 ) )
      geometry1.vertices.push( new THREE.Vector3( -100, +101, +100 ) )
      geometry1.vertices.push( new THREE.Vector3( -100, +101, -100 ) )
      geometry1.vertices.push( new THREE.Vector3( +100, +101, -100 ) )
      geometry1.vertices.push( new THREE.Vector3( +100, +101, +100 ) )

      @view1 = new THREE.Line(geometry1, new THREE.LineBasicMaterial(), THREE.LineStrip)

      # front view
      geometry2 = new THREE.Geometry()
      geometry2.vertices.push( new THREE.Vector3( +100, +100, +101 ) )
      geometry2.vertices.push( new THREE.Vector3( -100, +100, +101 ) )
      geometry2.vertices.push( new THREE.Vector3( -100, -100, +101 ) )
      geometry2.vertices.push( new THREE.Vector3( +100, -100, +101 ) )
      geometry2.vertices.push( new THREE.Vector3( +100, +100, +101 ) )

      @view2 = new THREE.Line(geometry2, new THREE.LineBasicMaterial(), THREE.LineStrip)

      # side view
      geometry3 = new THREE.Geometry()
      geometry3.vertices.push( new THREE.Vector3( +101, +100, +100 ) )
      geometry3.vertices.push( new THREE.Vector3( +101, -100, +100 ) )
      geometry3.vertices.push( new THREE.Vector3( +101, -100, -100 ) )
      geometry3.vertices.push( new THREE.Vector3( +101, +100, -100 ) )
      geometry3.vertices.push( new THREE.Vector3( +101, +100, +100 ) )

      @view3 = new THREE.Line(geometry3, new THREE.LineBasicMaterial(), THREE.LineStrip)

      @viewport.add(@view1) # top
      @viewport.add(@view2) # front
      @viewport.add(@view3) # side

      @box.add(@viewport)


   createRenderingEngine : =>

      # basically canvas in WebGL mode
      @renderer = new THREE.WebGLRenderer( { antialias: true, preserveDrawingBuffer: true } )
      @renderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT )
      @renderer.setClearColor( Palette.BACKGROUND.getHex(), 1 )
      @renderer.domElement.style.position = "relative"
      @renderer.domElement.id = "renderer"
      @renderer.autoClear = false

      # container is the display area placeholder in HTML
      container = $('#container').get(0)
      container.appendChild( @renderer.domElement )


   # Load JSON data to visualize.
   load : (@storage) =>

      data = @storage.getData() # JSON
      clusters = @storage.getClusters() # number of clusters

      # create point clouds first for each cluster

      @points = new Array()

      for c in [0...clusters]
         @points[c] = new THREE.Geometry()
         @points[c].colorsNeedUpdate = true


      # process JSON data
      $.each(data.points, @processPoint)

      # create particle systems for each cluster (with point clouds within)

      @particles = new Array()

      for p in [0...clusters]
         material = new THREE.ParticleBasicMaterial( { size: 1.0, sizeAttenuation: false, vertexColors: true } )
         @particles[p] = new THREE.ParticleSystem( @points[p], material )
         @box.add( @particles[p] ) # put them in the data cage

      @notify(Projector.EVENT_DATA_LOADED)



   # Called for each data point loaded in JSON file.
   processPoint : (nodeName, nodeData) =>

      # cluster index
      index = parseInt(nodeData.cid)

      vertex = new THREE.Vector3()
      vertex.x = parseFloat( nodeData.x )
      vertex.y = parseFloat( nodeData.y )
      vertex.z = parseFloat( nodeData.z )
      @points[index].vertices.push( vertex )

      # NOTE Although initially all points in the same cluster have the same color
      # they do take individual colors during the selection interactions therefore
      # each point needs its own individual color object instead of shared one...

      color = @colors[index].clone()
      @points[index].colors.push( color )


   # Rendering loop - animate calls itself forever.
   animate : =>

      requestAnimationFrame( @animate )
      @controls.update()
      @render()


   # Rendering done on each frame.
   # Rendering configuration depends on the current view mode.
   render : =>

      @renderer.clear()

      switch @mode

         # one viewport: perspective camera only
         when Projector.VIEW.PERSPECTIVE 
            if @spin isnt Projector.SPIN.NONE then @spinCamera()
            @cameraPerspective.lookAt( @box.position )
            # RENDERING
            @renderer.setViewport( 0, 0, @SCREEN_WIDTH, @SCREEN_HEIGHT )
            @renderer.render( @scene, @cameraPerspective )

         # one viewport: orthographic camera only
         when Projector.VIEW.ORTHOGRAPHIC
            # RENDERING
            @cameraOrthographic.rotation.z = 0
            @renderer.setViewport( 0, 0, @SCREEN_WIDTH, @SCREEN_HEIGHT )
            @renderer.render( @scene, @cameraOrthographic )

         # dual perspective and orthographic cameras view
         when Projector.VIEW.DUAL
            # synchronize camera with rotation
            if @spin isnt Projector.SPIN.NONE then @spinCamera()
            @cameraPerspective.lookAt( @box.position )
            # RENDERING
            # left side viewport: perspective camera
            @renderer.setViewport( 0, 0, @SCREEN_WIDTH/2, @SCREEN_HEIGHT )
            @renderer.render( @scene, @cameraPerspective )
            # right side viewport: orthographic camera
            @cameraOrthographic.rotation.z = 0
            @renderer.setViewport( @SCREEN_WIDTH/2, 0, @SCREEN_WIDTH/2, @SCREEN_HEIGHT )
            @renderer.render( @scene, @cameraOrthographic )


   updateSelection : =>

      # algorithm:
      # loop through all clusters
      # if cluster is visible then process it
      # for each point check if it's inside selection
      # if inside (and selector is active) set color to highlight
      # else set color to original cluster color

      counter = 0

      for i in [0...@storage.getClusters()]
         if @particles[i].visible
            cloud = @points[i]
            all = cloud.vertices.length
            for j in [0...all]
               vertex = cloud.vertices[j]
               color = cloud.colors[j]
               if @selector.isActive() and @selector.contains(vertex, Utility.DIRECTION.ALL) 
                  color.setHex(Palette.HIGHLIGHT.getHex())
                  counter++
                  # Utility.printVector3(vertex)
               else
                  color.setHex(@colors[i].getHex())

            cloud.colorsNeedUpdate = true;

      @notify(Projector.EVENT_POINTS_SELECTED, { points : counter })


   updateMouse3D : =>

      # NOTE This works only in DUAL mode
      # TODO Extend this to other modes

      ratio = 100 / 250 # ?

      switch @direction
         when Utility.DIRECTION.TOP
            @mouse.x = (event.pageX - (3 * @SCREEN_WIDTH / 4)) * ratio
            @mouse.y = 100
            @mouse.z = (event.pageY - (@SCREEN_HEIGHT / 2)) * ratio
         when Utility.DIRECTION.FRONT
            @mouse.x = (event.pageX - (3 * @SCREEN_WIDTH / 4)) * ratio
            @mouse.y = - (event.pageY - (@SCREEN_HEIGHT / 2)) * ratio
            @mouse.z = 100
         when Utility.DIRECTION.SIDE
            @mouse.x = 100
            @mouse.y = - (event.pageY - (@SCREEN_HEIGHT / 2)) * ratio
            @mouse.z = - (event.pageX - (3 * @SCREEN_WIDTH / 4)) * ratio


   # Returns 3D camera to its starting orientation and optionally position.
   # Position is only reset if location argument is true.
   resetCamera : (location) =>

      if location then TweenLite.to( @cameraPerspective.position, 1, {x:0, y:0, z:550} )
      TweenLite.to( @cameraPerspective.rotation, 1, {x:0, y:0, z:0} )
      TweenLite.to( @cameraPerspective.up, 1, {x:0, y:1, z:0} )


   # Set the visibility of orthographic view (top, front, side) indicator.
   updateView : (visible) =>

      @viewport.visible = visible

      # NOTE Changing visibility of the viewport alone does not work as the change
      # of visibility of the parent is an ongoing bug/issue of the ThreeJS library...
      # ...so toggle all three separately

      if @viewport.visible
         switch @direction
            when Utility.DIRECTION.TOP
               @setViewsVisible(true, false, false)
               @cameraOrthographic.position.set(0, 500, 0)
            when Utility.DIRECTION.FRONT
               @setViewsVisible(false, true, false)
               @cameraOrthographic.position.set(0, 0, 500)
            when Utility.DIRECTION.SIDE
               @setViewsVisible(false, false, true)
               @cameraOrthographic.position.set(500, 0, 0)
         @cameraOrthographic.lookAt(@box.position)
      else
         @setViewsVisible(false, false, false)

      return @viewport.visible   


   # Set visibility of view indicators.
   setViewsVisible : (top, front, side) =>      

         @view1.visible = top
         @view2.visible = front
         @view3.visible = side


   changeView : (@direction) =>

      @updateView(@viewport.visible)
      @selector.setDirection(@direction)


   toggleAnimation : =>
   
      @animateOn = not @animateOn

      if @animateOn
         @setAllClustersVisible(false)
         @startTimer(0)
      else
         @setAllClustersVisible(true)

      return @animateOn   


   setSpin : (@spin) =>

      switch @spin

         when Projector.SPIN.LEFT
            @resetCamera(false)

         when Projector.SPIN.NONE
            @timeStamp = 0

         when Projector.SPIN.RIGHT
            @resetCamera(false)


   # Spin camera in a circle around the center.
   spinCamera : =>

      STEP = @getSpinStep()

      cx = @cameraPerspective.position.x
      cy = -1 * @cameraPerspective.position.z
      radians = Math.atan2(cy, cx)
      radius = Math.sqrt(cx * cx + cy * cy)

      switch @spin

         when Projector.SPIN.LEFT
            radians += STEP
            if radians > Math.PI then radians = radians - (2 * Math.PI)

         when Projector.SPIN.RIGHT
            radians -= STEP
            if radians < -Math.PI then radians = (2 * Math.PI) + radians

      x = radius * Math.cos(radians)
      y = radius * Math.sin(radians)

      @cameraPerspective.position.x = x
      @cameraPerspective.position.z = -1 * y


   # Adjust the rotation step depending on time elapsed between the frames.
   getSpinStep : =>

      step = Projector.SPIN_STEP # default

      if @timeStamp isnt 0
         date = new Date()
         timeNow = date.getTime()
         delta = timeNow - @timeStamp
         @timeStamp = timeNow
         step = delta * step / 10

      return step   


   # Toggle visibility of the cluster given by its index.
   toggleClusterVisibility : (index) =>

      @particles[index].visible = not @particles[index].visible


   setAllClustersVisible : (visible) =>

      p.visible = visible for p in @particles


   # Select or unselect cluster of given index.
   toggleClusterSelection : (index) =>

      # clear old selected
      if @selected > -1
         # restore color coding on previous selection
         hexColor = @colors[@selected].getHex()
         @updatePoints(@selected, hexColor)

      if @selected is index
         # unselecting
         @selected = -1
      else 
         # selecting
         @selected = index
         # highlight new selected
         @updatePoints(@selected, Palette.HIGHLIGHT.getHex())

      if @selected > -1
         @notify(Projector.EVENT_CLUSTER_SELECTED, { id : index })
      else 
         @notify(Projector.EVENT_CLUSTER_SELECTED, { id : -1 })


   # Color code given points cloud (cluster).
   updatePoints : (index, color) =>

      cloud = @points[index]
      all = cloud.vertices.length

      for i in [0...all]
         cloud.colors[i].setHex(color)

      @points[index].colorsNeedUpdate = true


   startTimer : (index) =>

      @toggleClusterVisibility(index)
      window.setTimeout(@onTimer, 2 * Utility.SECOND, index)


   # Count visible clusters.
   clustersVisible : =>

      result = 0

      result++ for cloud in @particles when cloud.visible

      return result


module.exports = Projector