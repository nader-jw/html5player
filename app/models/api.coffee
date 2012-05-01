module.exports = class Api
  hasMp4 = navigator.userAgent.indexOf("AppleWebKit") > -1 and navigator.mimeTypes["video/mp4"]

  constructor: (@config) ->
    @request = """{ 
                   "network_id": "#{@config.networkId}",
                   "api_key": "#{@config.apiKey}",
                   "device_id": "VistarMedia0",
                   "number_of_screens": 1, 
                   "display_area": [
                   { 
                     "id": "display-0",
                     "width": #{@config.width},
                     "height": #{@config.height},
                     "supported_media": [
                       "image/gif",
                       "image/jpeg",
                       "image/png" """ + (if hasMp4 then """,
                       "video/mp4",
                       "video/quicktime" """ else "") + """
                     ], 
                     "min_duration": null,
                     "max_duration": null,
                     "allow_audio": true
                   }  
                   ],
                   "latitude": null,
                   "longitude": null,
                   "display_time": 1335550884,
                   "direct_connection": false
                 }"""

  fetch: (params) ->
    $.ajax
      type:         'POST'
      url:          'http://dev.api.vistarmedia.com/api/v1/get_ad/json'
      data:         @request
      
      success:      (data) =>
                      params.success(ad) for ad in data.advertisement

      error:        params.error
      dataType:     'json'
      contentType:  'text/json'