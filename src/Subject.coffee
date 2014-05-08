# Subject.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Abstract base class for all subjects in the Observer pattern for passing events.
# Subject provides interface for attaching and detaching Observer objects.

class Subject

   # M E M B E R S

   observers : null # list of listeners


   # C O N S T R U C T O R

   constructor: () ->

      @observers = new Array()


   # M E T H O D S

   # Attach observer to this subject.
   attach: (o) ->

      @observers.push(o)


   # Remove observer from this subject.
   detach: (o) ->

      index = @observers.indexOf(o)
      if index >= 0 then @observers.splice(index, 1)


   # Notify all observers.
   notify: (type, data = null) ->

      for o in @observers
         o.update(@, type, data)


module.exports = Subject
