# Palette.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Experimental color palette manager and auto generator.
# Also stores interface color constants.

class Palette

   # C O N S T A N T S

   @BACKGROUND : new THREE.Color( 0x202020 ) # used to display and clear background
   @HIGHLIGHT : new THREE.Color( 0xFFFFFF ) # used to highlight selected data points
   @SELECTOR : new THREE.Color( 0xCC0000 ) # color used for the rubber band/box outline
   @BUTTON : new THREE.Color( 0xCCCCCC )  # button normal color
   @BUTTON_SELECTED : new THREE.Color( 0xFF9C00 )  # button selected color

   # M E M B E R S

   # automatically generated palette

   colors : null # array of THREE.Color

   # C O N S T R U C T O R

   # Create color palette of given size.
   constructor: (size) ->

      @colors = new Array()
      @generate(size)

   # M E T H O D S

   # Automatically generate a palette.
   generate: (size) ->

      hue = 0
      saturation = 0.7
      lightness = 0.45

      step = 1 / size

      for i in [0...size]
         hue = (i + 1) * step
         color = new THREE.Color()
         color.setHSL(hue, saturation, lightness)
         @colors.push(color)


   # Return generated array.
   getColors: -> return @colors


   # Debug utility. Prints out all palette colors.
   print: ->

      i = 0
      for c in @colors
         css = c.getStyle()
         hsl = c.getHSL()
         hue = hsl.h.toFixed(1)
         saturation = hsl.s.toFixed(1)
         lightness = hsl.l.toFixed(1)
         console.log i++ + " > " + hue + " : " + saturation + " : " + lightness + " | " + css


module.exports = Palette