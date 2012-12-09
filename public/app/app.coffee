# /*global console,Backbone,Handlebars,io*/
"use strict"

root_url = '/'
api_url = root_url + 'api/'

position = null
toilets = null

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

# class BaseView extends Backbone.View
#   constructor: (options) ->
#     @bindings = []
# 
#     super options
# 
#   bind_to: (model, event, callback) ->
#     model.bind event, callback, @
# 
#     @bindings.push {model: model, event: event, callback: callback}
# 
#   unbind_all: ->
#     _.each @bindings, (binding) ->
#       binding.model.unbind binding.event, binding.callback
# 
#     @bindings = []
# 
#   close: () ->
#     @unbind_all()
#     @unbind()
#     @remove()

###################################################

ToiletList = Backbone.Collection.extend
  model: Toilet
  url: ''

  parse: (resp)  ->
    console.log resp

    return resp

  set_url: () ->
    @url = api_url + 'nearest.json' #?lat=' + position.coords.latitude + '&long=' + position.coords.longitude

  # all: (callback) ->
  #   $.ajax
  #     type: "GET"
  #     url: @url
  #     # dataType: "jsonp"
  #     complete: (xhr, data) =>
  #       console.log 'complete'
  #       console.log data
  #     success: (data) =>
  #       console.log 'success'
  #       console.log data
  #     error: (xhr, textStatus, err) ->
  #       console.log 'error'
  #       console.log xhr
  #       data = xhr.responseText
  
Toilet = Backbone.Model.extend
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
  #   base = root_url + '?lat=' + position.coords.latitude + '&long=' + position.coords.longitude
  #   
  #   return base if @isNew()
  #   return base + '/' + this.id

###################################################

HomeView = Backbone.View.extend
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
        position = pos

        @position_found()
  
  render: ->
    @$el.html @template(@model.data)
    @.wireup_navs()
    @

###################################################

ListView = Backbone.View.extend
  el: $('#main')
  model: null

  initialize: ->
    @template = Handlebars.getTemplate("list")

    @model = {
      data: {
        lat: position.coords.latitude,
        long: position.coords.longitude
        toilets: toilets
      }
    }

    @render()
    @reload_data()

  events:
    'click .reload': 'reload_data'

  reload_data: ->
    @collection = new ToiletList
    @collection.set_url()
    # @collection.all()
    @collection.fetch({
      success: (collection, response, options) =>
        toilets = @collection

        @model.data.toilets = @collection

        console.log 'test'

        @render()
      error: (collection, xhr, options) =>
        console.log collection
        console.log xhr
        console.log options
    })
 
  render: ->
    @$el.html @template(@model.data)
    @.wireup_navs()
    @

###################################################

MapView = Backbone.View.extend
  el: $('#main')
  model: null
  map: null
  markers: null

  initialize: ->
    @template = Handlebars.getTemplate("map")

    @model = {
      data: {
        lat: position.coords.latitude,
        long: position.coords.longitude
        toilets: toilets
      }
    }

    @render()

    @map_init()
    @map_plot()

    @reload_data()

  map_init: ->
    @map = new google.maps.Map(
      document.getElementById('map_canvas'),
      {
        zoom: 13,
        center: new google.maps.LatLng(
          position.coords.latitude,
          position.coords.longitude
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

    if toilets
      @markers = []

      for toilet in toilets
        @markers.push new google.maps.Marker({
          position: new google.maps.LatLng(
            toilet.lat,
            toilet.long
          ),
          map: map,
          icon: 'assets/img/toilet.png'
        })

  reload_data: ->
    @collection = new Toilets
    @collection.set_url()
    @collection.fetch { dataType : 'jsonp', success: () =>
      toilets = @collection

      @model.data.toilets = @collection

      @render()
      @map_plot()
    }

  render: ->
    @$el.html @template(@model.data)
    @.wireup_navs()
    @

###################################################

ToiletView = Backbone.View.extend
  el: $('#main')

  initialize: ->
    @template = Handlebars.getTemplate('toilet')

    if toilets
      @show_model()
    else
      toilets = new Toilets
      toilets.set_url()
      toilets.fetch { dataType : 'jsonp', success: () =>
        @show_model()
      }
  
  show_model: ->
    @model = toilets.where({id: @options.toilet_id})
    
    if @model
      @render()
    else
      app.navigate '', true

  render: ->
    @$el.html @template(@model.toJSON().data)
    @.wireup_navs()
    @

  events:
    'click .back': window.history.back

###################################################

GenericView = Backbone.View.extend
  el: $('#main')

  initialize: ->
    @template = Handlebars.getTemplate(@options.template)
    @render()

  render: ->
    @$el.html @template()
    @.wireup_navs()
    @

###################################################

About = Backbone.Model.extend
  defaults:
    data: {}

# Start view
AboutView = Backbone.View.extend
  el: $('#main')

  os: null

  initialize: ->
    @model = new About
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

App = Backbone.Router.extend
  el: $('#main')
  states: null
  current_view: null

  initialize: ->

  routes:
    "index.html": "index"
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

Backbone.history.start pushState: true, root: root_url

protect_links()
