FillingQueue = require './filling_queue'

module.exports = class PlayQueue extends FillingQueue

  constructor: (@adQueue, @size, @$imagePlayer, @$videoPlayer) ->
    super(@size)

  fill: ->
    next = @adQueue.pop()
    
    if next
      this.push(next)

  play: =>
    ad = this.pop()

    if not ad
      return setTimeout(this.play, 500)

    this.display(ad)

  sendProofOfPlay: (url) ->
    $.ajax
      type:     'GET'
      url:      url

      success:  ->
        console.log("proof of play sent.")

      error:    ->
        console.log("error sending proof of play.")

  expire: (url) ->
    $.ajax
      type:     'GET'
      url:      url

      success:  ->
        console.log("lease expired.")
      
      error: ->
        console.log("error expiring lease.")

  display: (ad) ->
    console.log("displaying ad: " + ad.asset_url)
    duration = ad.length_in_seconds * 1000

    @$videoPlayer.unbind('ended')

    @$imagePlayer.hide()
    @$videoPlayer.hide()

    if ad.mime_type.match(/^image\//)
      @$imagePlayer.attr('src', ad.asset_url)
      @$imagePlayer.show()
      setTimeout( =>
        this.play()
        this.sendProofOfPlay(ad.proof_of_play_url)
      , duration)
    else if ad.mime_type.match(/^video\//)
      # utilizing JwPlayer to bring in FF support
      if not @loaded
        @jwplayer = jwplayer(@$videoPlayer[0]).setup
          file: ad.asset_url
          image: ad.thumb_url
          width: 1280 # ad.width appears to contain incorrect value
          height: 720 # ad.height appears to contain incorrect value
        @jwplayer.onComplete(=>
          @play()
          @sendProofOfPlay(ad.proof_of_play_url)
        )
        @jwplayer.onError(=>
          @play()
          @expire(ad.expiration.url)
        )
        @jwplayer.setControls(false)
        @jwplayer.setMute(false)
      else
        @jwplayer.load [
          file: ad.asset_url
          image: ad.thumb_url
        ]
      @jwplayer.play()
    else
      @expire(ad.expiration.url)
      @play()
