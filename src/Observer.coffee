# Observer.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Abstract base class for all observers in the Observer pattern for passing events.
# Observer objects attach themselves to Subjects and listen for updates.

class Observer

	# M E T H O D S

   # Concrete observer classes should implement and use this method.
   update: (subject, type, data) ->


module.exports = Observer
