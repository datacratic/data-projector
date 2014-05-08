# Storage.coffee
# Tomasz (Tomek) Zemla
# tomek@datacratic.com

# Class that provides access to application storage. Technically this is server
# based storage accessed asynchronously, but with custom Node based server this
# can be run in the context of the single machine with local storage.

# Storage provides services to retrieve the data file for visualization and to
# save the screenshots of the rendered images. It also does the initial scan of
# the data to extract some basic info about it like the number of clusters present.

# SEE server.coffee

Subject = require('./Subject.coffee')

class Storage extends Subject

   # E V E N T S

   @EVENT_DATAFILE_READY : "EVENT_DATAFILE_READY" # fired when data file name was received
   @EVENT_JSON_READY : "EVENT_JSON_READY" # fired when JSON data source was downloaded
   @EVENT_DATA_READY : "EVENT_DATA_READY" # fired when JSON data was processed and ready for use
   @EVENT_SCREENSHOT_OK : "EVENT_SCREENSHOT_OK" # fired when screenshot was saved OK

   # M E M B E R S

   datafile : null # name of the data file to be used
   data : null # JSON data

   points : 0 # counts data points loaded
   clusterIDs : null # array of cluster IDs loaded
   clusters : 0 # number of unique clusters

   saved : 0 # save screenshot counter


   # C O N S T R U C T O R

   constructor : ->

      super()

      @clusterIDs = new Array()


   # E V E N T   H A N D L E R S


   # Server response to filename request.
   onDatafile : (@datafile) =>
   
      @notify(Storage.EVENT_DATAFILE_READY)
      @requestJSON(@datafile)


   # Called when data arrives.
   onJSON : (@data) =>

      @notify(Storage.EVENT_JSON_READY)
      # process JSON data
      $.each(@data.points, @processPoint)
      @notify(Storage.EVENT_DATA_READY)



   # Server response to saving image on disk.
   onSaveResponse : (message) =>
   
      console.log "DataProjector.onSaveResponse " + message   
      @notify(Storage.EVENT_SCREENSHOT_OK)


   # M E T H O D S   


   # This is a two step process. First data file name is retrieved. Then data itself.
   requestData : ->

      @requestDatafile()


   # Get the name of the data file to use in visualization.
   requestDatafile : -> @onDatafile "data.json"


   # Use jQuery JSON loader to fetch data.
   requestJSON : (@datafile) ->

      # attach random value to avoid browser cache problem
      file = @datafile + "?" + String(Math.round(Math.random() * 99999))
      $.getJSON(file, @onJSON)


   # Save copy of the given image to storage.
   saveImage : (base64Image) ->

      $.post('/upload', { id : ++@saved, image : base64Image }, @onSaveResponse)


   # Called for each data point loaded in JSON file.
   # Initial scan of loaded data to extract some info about it.
   processPoint : (nodeName, nodeData) =>

      unless nodeData.cid in @clusterIDs
         @clusterIDs.push(nodeData.cid)
         @clusters = @clusterIDs.length

      @points++


   # Get the data file name.
   getDatafile : -> return @datafile


   # Get the JSON data.
   getData : -> return @data   


   # Get number of unique clusters found in data.
   getClusters : -> return @clusters


   # Get number of points found in data.
   getPoints : -> return @points


   # Get number of saved screenshots.
   getSaved : -> return @saved


module.exports = Storage
      