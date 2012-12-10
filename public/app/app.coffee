# /*global console,Backbone,Handlebars,io*/
"use strict"

window.root_url = '/'
window.api_url = window.root_url + 'api/'

window.position = null
window.toilets = null

###################################################

# Close extension
Backbone.View.prototype.remove = ->
  # view specific hook
  if @beforeClose
    @beforeClose()

  @$el.empty()
  @undelegateEvents()
  @unbind()

Backbone.View.prototype.wireup_navs = ->
  that = @

  @$el.find('a[role=nav]').each () ->
    $(@).on 'click', (e) ->
      e.preventDefault()

      app.navigate($(@).attr('href'), true)

      false

class BaseView extends Backbone.View
  constructor: (options) ->
    @bindings = []

    super options

  bind_to: (model, event, callback) ->
    model.bind event, callback, @

    @bindings.push {model: model, event: event, callback: callback}

  unbind_all: ->
    _.each @bindings, (binding) ->
      binding.model.unbind binding.event, binding.callback

    @bindings = []

  close: () ->
    @unbind_all()
    @unbind()
    @remove()

###################################################
  
class Toilet extends Backbone.Model
  defaults:
    id: null

    lat: 0
    long: 0

    description: ''
    owner: ''
    address: {
      street: '',
      number: '',
      postal: '',
      city: ''
    }

    distance: 0

  # url: () ->
  #   base = window.root_url + '?lat=' + position.coords.latitude + '&long=' + position.coords.longitude
  #   
  #   return base if @isNew()
  #   return base + '/' + this.id

class ToiletList extends Backbone.Collection
  model: Toilet

  url: ->
    return_url = window.api_url + 'nearest.json'

    if window.position
      return_url += '?lat=' + position.coords.latitude + '&long=' + position.coords.longitude

    return_url
      

###################################################

class HomeView extends Backbone.View
  el: $('#main')
  model: null

  initialize: ->
    @template = Handlebars.getTemplate("index")
    @detect()

    @model = {data: {}}

    @render()

  position_found: ->
    app.navigate "list", true

  detect: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (pos) =>
        window.position = pos

        @position_found()
      , (err) =>
        if err.code == 1
          alert "Error: Wij kregen geen toegnag tot uw exacte locatie!"
        else if err.code == 2
          alert "Error: Uw exacte locatie is niet beschikbaar!"
      , {timeout: 5000}
    else
      alert 'Uw toestel heeft geen GPS / geolocatie mogelijkheden'
  
  render: ->
    @$el.html @template(@model.data)
    @.wireup_navs()
    @

###################################################

class ListView extends BaseView
  el: $('#main')
  model: null

  initialize: ->
    @template = Handlebars.getTemplate("list")

    @model = {
      data: {
        lat: window.position.coords.latitude,
        long: window.position.coords.longitude
      }
    }

    unless window.toilets
      @collection = new ToiletList
      @bind_to @collection, 'reset', @render
      @collection.fetch()
    else
      @collection = window.toilets

    @render()

  events:
    'click .reload': 'reload_data'

  reload_data: (e) ->
    e.preventDefault()

    @collection.fetch()

    false

  #   @collection = new ToiletList
  #   @collection.fetch {
  #     success: (collection, response, options) =>
  #       toilets = @collection
  #       console.log collection
  #       console.log @collection

  #       @model.data.toilets = @collection.toJSON()

  #       @render()
  #     error: (collection, xhr, options) =>
  #       console.log 'error'
  #       console.log xhr
  #       console.log options
  #   }
 
  render: ->
    @model.data.toilets = @collection.toJSON()
    window.toilets = @collection

    @$el.html @template(@model.data)
    @.wireup_navs()
    @

###################################################

class MapView extends BaseView
  el: $('#main')
  model: null
  map: null
  markers: null

  initialize: ->
    @template = Handlebars.getTemplate("map")

    @model = {
      data: {
        lat: window.position.coords.latitude,
        long: window.position.coords.longitude
        toilets: if window.toilets then window.toilets.toJSON() else null
      }
    }

    unless window.toilets
      @collection = new ToiletList
      @bind_to @collection, 'reset', @render
      @collection.fetch()
    else
      @collection = window.toilets

    @render()

  map_init: ->
    @map = new google.maps.Map(
      document.getElementById('map_canvas'),
      {
        zoom: 13,
        center: new google.maps.LatLng(
          window.position.coords.latitude,
          window.position.coords.longitude
        ),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      }
    )

  map_clear_markers: ->
    if @markers
      for marker in @markers
        marker.setMap null

  map_plot: ->
    @map_clear_markers()

    if @collection.length > 0
      @markers = []

      @collection.each (toilet) =>
        map_position = new google.maps.LatLng(
          parseFloat(toilet.get('lat')),
          parseFloat(toilet.get('long'))
        )

        marker = new google.maps.Marker({
          position: map_position
          map: @map,
          icon: '/assets/img/toilet.png'
        })

        @markers.push marker

  events:
    'click .reload': 'reload_data'

  reload_data: (e) ->
    e.preventDefault()

    @collection.fetch()

    false
    # @collection = new ToiletList
    # @collection.fetch {
    #   success: () =>
    #     window.toilets = @collection

    #     @model.data.toilets = @collection.toJSON()

    #     @render()
    #     @map_plot()
    # }

  render: ->
    @model.data.toilets = @collection.toJSON()
    window.toilets = @collection

    @$el.html @template(@model.data)
    @.wireup_navs()

    @map_init()
    @map_plot()

    @

###################################################

class ToiletView extends BaseView
  el: $('#main')

  initialize: ->
    @template = Handlebars.getTemplate('toilet')

    unless window.toilets
      @collection = new ToiletList
      @bind_to @collection, 'reset', @show_model
      @collection.fetch()
    else
      @collection = window.toilets

      @show_model()
  
  show_model: ->
    @model = @collection.get(@options.toilet_id)

    window.toilets = @collection

    if @model
      @render()
    else
      app.navigate '', true

  render: ->
    @$el.html @template(@model.toJSON())
    @.wireup_navs()
    @

  back_to_list: (e) ->
    e.preventDefault()

    window.history.back()

    return false

  events:
    'click .back': 'back_to_list'

###################################################

class GenericView extends BaseView
  el: $('#main')

  initialize: ->
    @template = Handlebars.getTemplate(@options.template)
    @render()

  render: ->
    @$el.html @template()
    @.wireup_navs()
    @

###################################################

class AboutView extends BaseView
  el: $('#main')

  os: null

  initialize: ->
    @template = Handlebars.getTemplate("about")

    @os = @detect navigator.userAgent

    alert @os

    @render()

  detect: (ua) ->
    if(ua.match(/(Android)\s+([\d.]+)/))
      return 'android'
    else
      return 'ios'
  
  render: ->
    @$el.html @template(@model.toJSON().data)
    @

  # render_thanks: ->
  #   @template = Handlebars.getTemplate("poll/thanks")
  #   @render()

###################################################

class App extends Backbone.Router
  el: $('#main')
  states: null
  current_view: null

  initialize: ->

  routes:
    "": "index"
    "map": "map"
    "list": "list"
    "toilet/:id": "toilet"
    "about": "about"
    ":page": "generic"

  before: ->
    if @current_view? then @current_view.remove()

  position_required: ->
    unless position
      app.navigate '', true

      return false

    true

  index: ->
    @before()

    @current_view = new HomeView

  list: ->
    @before()

    if @position_required()
      @current_view = new ListView

  map: ->
    @before()
    
    if @position_required()
      @current_view = new MapView

  toilet: (toilet_id) ->
    @before()

    @current_view = new ToiletView toilet_id: toilet_id

  about: ->
    @before()

    @current_view = new AboutView

  generic: (page) ->
    @before()

    @current_view = new GenericView template: page

###################################################

protect_links = ->
	for link, i in document.getElementsByTagName('a')
    link.onclick = ->
      location.href = this

###################################################

app = new App()
app.navigate()

Backbone.history.start pushState: true, root: window.root_url

protect_links()
