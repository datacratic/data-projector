# Utility.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Collection of static helper methods of various sorts and other constants.

class Utility

   # C O N S T A N T S   

   # three orthographic view directions (ALL is used when all three need to be considered)
   @DIRECTION : { ALL: 0, TOP: 1, FRONT: 2, SIDE: 3 }

   @DEGREE : Math.PI / 180 # one degree

   @SECOND : 1000 # second in milliseconds

   # modifier keys used in shortcuts
   @NO_KEY : "NO_KEY"
   @SHIFT_KEY : "SHIFT_KEY"
   @CTRL_KEY : "CTRL_KEY"
   @ALT_KEY : "ALT_KEY"


   # S T A T I C   M E T H O D S   

   # Debug utility. Prints out THREE.Vector3 component values.
   @printVector3: (vector) ->

      console.log vector.x.toFixed(1) + " : " + vector.y.toFixed(1) + " : " + vector.z.toFixed(1)

module.exports = Utility