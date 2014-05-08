# Selector.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Rubber band style selector machanism that works in 3D.
# The 3D selector is actually composed from three 2D selectors on each side of the cube.

Utility = require('./Utility.coffee')
Palette = require('./Palette.coffee')

class Selector

   # M E M B E R S

   active : false # visible and active when true

   direction : Utility.DIRECTION.TOP # default 2D view is from top

   selectorTop : null # THREE.Line - top (along y axis) view selector
   selectorFront : null # THREE.Line - front (along z axis) view selector
   selectorSide : null # THREE.Line - top (along x axis) view selector

   mouseStart : null # mouse touch down
   mouse : null # mouse moving updates
   mouseEnd : null # mouse take off

   min : null # 3D selection bounds - minimum
   max : null # 3D selection bounds - maximum


   # C O N S T R U C T O R

   # Create selector and add it to the parent in 3D world.
   constructor : (parent) ->

      @mouseStart = new THREE.Vector3()
      @mouse = new THREE.Vector3()
      @mouseEnd = new THREE.Vector3()

      @min = new THREE.Vector3()
      @max = new THREE.Vector3()

      # top view
      @selectorTop = @createSelector(Utility.DIRECTION.TOP)
      parent.add(@selectorTop)

      # front view
      @selectorFront = @createSelector(Utility.DIRECTION.FRONT)
      parent.add(@selectorFront)

      # side view
      @selectorSide = @createSelector(Utility.DIRECTION.SIDE)
      parent.add(@selectorSide)

      @setActive(false)


   # M E T H D O S   

   # Set selector active/visible on/off.
   # All side components work together.
   setActive : (@active) ->

      @selectorTop.visible = @active
      @selectorFront.visible = @active
      @selectorSide.visible = @active

      return @active


   # Set direction.
   setDirection : (@direction) ->

      console.log "Selector.setDirection " + @direction


   # Check if currently active/visible.
   isActive : => return @active   


   # Toggle selector on/off
   toggle : => return @setActive(not @active)


   # Called at the start of the selection.
   start : (@mouse) ->

      @setActive(true) # automatically enable
      
      # two options: start new selection or adjust existing...

      if not @contains(mouse, @direction)

         # mouse outside the selector - restart anew
         @mouseStart = mouse

      else    

         # mouse inside the selector - make adjustment

         # determine which corner is closest to the mouse

         switch @direction
            when Utility.DIRECTION.TOP
               @mouseStart = @getStart(mouse, @selectorTop)
            when Utility.DIRECTION.FRONT
               @mouseStart = @getStart(mouse, @selectorFront)
            when Utility.DIRECTION.SIDE
               @mouseStart = @getStart(mouse, @selectorSide)


   getStart : (mouse, selector) ->
   
      # determine which corner is closest to the mouse

      # TODO Set up array + loop...
      distanceTo0 = mouse.distanceTo(selector.geometry.vertices[0])
      distanceTo1 = mouse.distanceTo(selector.geometry.vertices[1])
      distanceTo2 = mouse.distanceTo(selector.geometry.vertices[2])
      distanceTo3 = mouse.distanceTo(selector.geometry.vertices[3])

      shortest = Math.min(distanceTo0, distanceTo1, distanceTo2, distanceTo3)

      # make the closest corner the end point and the opposite one the start point

      if shortest is distanceTo0 then start = selector.geometry.vertices[2].clone()
      if shortest is distanceTo1 then start = selector.geometry.vertices[3].clone()
      if shortest is distanceTo2 then start = selector.geometry.vertices[0].clone()
      if shortest is distanceTo3 then start = selector.geometry.vertices[1].clone()

      return start


   # Called when selection in progress to update mouse position.
   update : (@mouse) ->

      switch @direction
         when Utility.DIRECTION.TOP

            # Modifying : Top

            @selectorTop.geometry.vertices[0].x = @mouseStart.x
            @selectorTop.geometry.vertices[0].y = 100
            @selectorTop.geometry.vertices[0].z = @mouseStart.z

            @selectorTop.geometry.vertices[1].x = @mouse.x
            @selectorTop.geometry.vertices[1].y = 100
            @selectorTop.geometry.vertices[1].z = @mouseStart.z

            @selectorTop.geometry.vertices[2].x = @mouse.x
            @selectorTop.geometry.vertices[2].y = 100
            @selectorTop.geometry.vertices[2].z = @mouse.z

            @selectorTop.geometry.vertices[3].x = @mouseStart.x
            @selectorTop.geometry.vertices[3].y = 100
            @selectorTop.geometry.vertices[3].z = @mouse.z

            @selectorTop.geometry.vertices[4].x = @mouseStart.x
            @selectorTop.geometry.vertices[4].y = 100
            @selectorTop.geometry.vertices[4].z = @mouseStart.z

            # Adjusting : Front

            @selectorFront.geometry.vertices[0].x = @mouseStart.x
            @selectorFront.geometry.vertices[0].z = 100

            @selectorFront.geometry.vertices[1].x = @mouse.x
            @selectorFront.geometry.vertices[1].z = 100

            @selectorFront.geometry.vertices[2].x = @mouse.x
            @selectorFront.geometry.vertices[2].z = 100

            @selectorFront.geometry.vertices[3].x = @mouseStart.x
            @selectorFront.geometry.vertices[3].z = 100

            @selectorFront.geometry.vertices[4].x = @mouseStart.x
            @selectorFront.geometry.vertices[4].z = 100

            # Adjusting : Side

            @selectorSide.geometry.vertices[0].x = 100
            @selectorSide.geometry.vertices[0].z = @mouseStart.z

            @selectorSide.geometry.vertices[1].x = 100
            @selectorSide.geometry.vertices[1].z = @mouseStart.z

            @selectorSide.geometry.vertices[2].x = 100
            @selectorSide.geometry.vertices[2].z = @mouse.z

            @selectorSide.geometry.vertices[3].x = 100
            @selectorSide.geometry.vertices[3].z = @mouse.z

            @selectorSide.geometry.vertices[4].x = 100
            @selectorSide.geometry.vertices[4].z = @mouseStart.z

         when Utility.DIRECTION.FRONT

            # Modifying : FRONT

            @selectorFront.geometry.vertices[0].x = @mouseStart.x
            @selectorFront.geometry.vertices[0].y = @mouseStart.y
            @selectorFront.geometry.vertices[0].z = 100

            @selectorFront.geometry.vertices[1].x = @mouse.x
            @selectorFront.geometry.vertices[1].y = @mouseStart.y
            @selectorFront.geometry.vertices[1].z = 100

            @selectorFront.geometry.vertices[2].x = @mouse.x
            @selectorFront.geometry.vertices[2].y = @mouse.y
            @selectorFront.geometry.vertices[2].z = 100

            @selectorFront.geometry.vertices[3].x = @mouseStart.x
            @selectorFront.geometry.vertices[3].y = @mouse.y
            @selectorFront.geometry.vertices[3].z = 100

            @selectorFront.geometry.vertices[4].x = @mouseStart.x
            @selectorFront.geometry.vertices[4].y = @mouseStart.y
            @selectorFront.geometry.vertices[4].z = 100

            # Adjusting : TOP

            @selectorTop.geometry.vertices[0].x = @mouseStart.x
            @selectorTop.geometry.vertices[0].y = 100

            @selectorTop.geometry.vertices[1].x = @mouse.x
            @selectorTop.geometry.vertices[1].y = 100

            @selectorTop.geometry.vertices[2].x = @mouse.x
            @selectorTop.geometry.vertices[2].y = 100

            @selectorTop.geometry.vertices[3].x = @mouseStart.x
            @selectorTop.geometry.vertices[3].y = 100

            @selectorTop.geometry.vertices[4].x = @mouseStart.x
            @selectorTop.geometry.vertices[4].y = 100

            # Adjusting : SIDE

            @selectorSide.geometry.vertices[0].x = 100
            @selectorSide.geometry.vertices[0].y = @mouseStart.y

            @selectorSide.geometry.vertices[1].x = 100
            @selectorSide.geometry.vertices[1].y = @mouse.y

            @selectorSide.geometry.vertices[2].x = 100
            @selectorSide.geometry.vertices[2].y = @mouse.y

            @selectorSide.geometry.vertices[3].x = 100
            @selectorSide.geometry.vertices[3].y = @mouseStart.y

            @selectorSide.geometry.vertices[4].x = 100
            @selectorSide.geometry.vertices[4].y = @mouseStart.y


         when Utility.DIRECTION.SIDE

            # Modifying : SIDE

            @selectorSide.geometry.vertices[0].x = 100
            @selectorSide.geometry.vertices[0].y = @mouseStart.y
            @selectorSide.geometry.vertices[0].z = @mouseStart.z

            @selectorSide.geometry.vertices[1].x = 100
            @selectorSide.geometry.vertices[1].y = @mouse.y
            @selectorSide.geometry.vertices[1].z = @mouseStart.z

            @selectorSide.geometry.vertices[2].x = 100
            @selectorSide.geometry.vertices[2].y = @mouse.y
            @selectorSide.geometry.vertices[2].z = @mouse.z

            @selectorSide.geometry.vertices[3].x = 100
            @selectorSide.geometry.vertices[3].y = @mouseStart.y
            @selectorSide.geometry.vertices[3].z = @mouse.z

            @selectorSide.geometry.vertices[4].x = 100
            @selectorSide.geometry.vertices[4].y = @mouseStart.y
            @selectorSide.geometry.vertices[4].z = @mouseStart.z

            # Adjusting : TOP

            @selectorTop.geometry.vertices[0].y = 100
            @selectorTop.geometry.vertices[0].z = @mouseStart.z

            @selectorTop.geometry.vertices[1].y = 100
            @selectorTop.geometry.vertices[1].z = @mouseStart.z

            @selectorTop.geometry.vertices[2].y = 100
            @selectorTop.geometry.vertices[2].z = @mouse.z

            @selectorTop.geometry.vertices[3].y = 100
            @selectorTop.geometry.vertices[3].z = @mouse.z

            @selectorTop.geometry.vertices[4].y = 100
            @selectorTop.geometry.vertices[4].z = @mouseStart.z

            # Adjusting : FRONT

            @selectorFront.geometry.vertices[0].y = @mouseStart.y
            @selectorFront.geometry.vertices[0].z = 100

            @selectorFront.geometry.vertices[1].y = @mouseStart.y
            @selectorFront.geometry.vertices[1].z = 100

            @selectorFront.geometry.vertices[2].y = @mouse.y
            @selectorFront.geometry.vertices[2].z = 100

            @selectorFront.geometry.vertices[3].y = @mouse.y
            @selectorFront.geometry.vertices[3].z = 100

            @selectorFront.geometry.vertices[4].y = @mouseStart.y
            @selectorFront.geometry.vertices[4].z = 100


      @selectorTop.geometry.verticesNeedUpdate = true
      @selectorFront.geometry.verticesNeedUpdate = true
      @selectorSide.geometry.verticesNeedUpdate = true


   # Called at the end of the selection.
   end : (mouseEnd) ->

      @mouseEnd = mouseEnd
      @updateBounds()


   updateBounds : ->

      @min.x = Math.min( @getMinX(@selectorTop), @getMinX(@selectorFront) )
      @max.x = Math.max( @getMaxX(@selectorTop), @getMaxX(@selectorFront) )

      @min.y = Math.min( @getMinY(@selectorFront), @getMinY(@selectorSide) )
      @max.y = Math.max( @getMaxY(@selectorFront), @getMaxY(@selectorSide) )

      @min.z = Math.min( @getMinZ(@selectorTop), @getMinZ(@selectorSide) )
      @max.z = Math.max( @getMaxZ(@selectorTop), @getMaxZ(@selectorSide) )

      # DEBUG
      # Utility.printVector3(@min)
      # Utility.printVector3(@max)


   # Return true if given point is within the selector, false otherwise.
   # NOTE For each individual direction only two coordinates are checked.
   # NOTE In case of direction ALL, all three coordinates are tested.
   contains : (point, direction) ->

      inside = true

      switch direction
         when Utility.DIRECTION.ALL
            if point.x < @min.x or point.x > @max.x then inside = false
            if point.y < @min.y or point.y > @max.y then inside = false
            if point.z < @min.z or point.z > @max.z then inside = false
         when Utility.DIRECTION.TOP
            if point.x < @min.x or point.x > @max.x then inside = false
            if point.z < @min.z or point.z > @max.z then inside = false
         when Utility.DIRECTION.FRONT
            if point.x < @min.x or point.x > @max.x then inside = false
            if point.y < @min.y or point.y > @max.y then inside = false
         when Utility.DIRECTION.SIDE
            if point.z < @min.z or point.z > @max.z then inside = false
            if point.y < @min.y or point.y > @max.y then inside = false

      return inside

   
   getMinX : (selector) ->

      vertices = selector.geometry.vertices
      minX = vertices[0].x

      for i in [1..4]
         if vertices[i].x < minX then minX = vertices[i].x

      return minX


   getMaxX : (selector) ->

      vertices = selector.geometry.vertices
      maxX = vertices[0].x

      for i in [1..4]
         if vertices[i].x > maxX then maxX = vertices[i].x

      return maxX


   getMinY : (selector) ->

      vertices = selector.geometry.vertices
      minY = vertices[0].y

      for i in [1..4]
         if vertices[i].y < minY then minY = vertices[i].y

      return minY


   getMaxY : (selector) ->

      vertices = selector.geometry.vertices
      maxY = vertices[0].y

      for i in [1..4]
         if vertices[i].y > maxY then maxY = vertices[i].y

      return maxY


   getMinZ : (selector) ->

      vertices = selector.geometry.vertices
      minZ = vertices[0].z

      for i in [1..4]
         if vertices[i].z < minZ then minZ = vertices[i].z

      return minZ


   getMaxZ : (selector) ->

      vertices = selector.geometry.vertices
      maxZ = vertices[0].z

      for i in [1..4]
         if vertices[i].z > maxZ then maxZ = vertices[i].z

      return maxZ


   # Create selector rectangle line for given direction.
   createSelector : (direction) ->

      SIZE = 100

      geometry = new THREE.Geometry()

      # five points in each case, last one is the first one

      switch direction
         when Utility.DIRECTION.TOP
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( -SIZE, +SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( -SIZE, +SIZE, -SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, -SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, +SIZE ) )
         when Utility.DIRECTION.FRONT
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( -SIZE, +SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( -SIZE, -SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, -SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, +SIZE ) )
         when Utility.DIRECTION.SIDE
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, -SIZE, +SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, -SIZE, -SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, -SIZE ) )
            geometry.vertices.push( new THREE.Vector3( +SIZE, +SIZE, +SIZE ) )

      selector = new THREE.Line(geometry,
                                new THREE.LineBasicMaterial( { color : Palette.SELECTOR.getHex() } ),
                                THREE.LineStrip)

module.exports = Selector
