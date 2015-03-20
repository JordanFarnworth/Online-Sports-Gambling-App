# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.groups.index').ready ->
  loadGroups('#groups_pagination')

$('.groups.show').ready ->
  loadGroup()
  $('[data-toggle="tooltip"]').tooltip()
  $(' div.list-group a.list-group-item').on 'click',  ->
    $('div.list-group a.active').removeClass('active')
    $(this).addClass('active')
    #events for icon navbar on groups#show page
    #Group's Information Page
  $('div.list-group a.group-show').on 'click', ->
    loadGroupMain()
    #Users in this group
  $('div.list-group a.group-users-show').on 'click', ->
    $('div.row div.group-main-wrapper').find('*').remove()
    loadGroupUsers()
    # Group's betting
  $('div.list-group a.group-bets-show').on 'click', ->
    $('div.row div.group-main-wrapper').find('*').remove()
    loadGroupBets()
    # Group's Stats
  $('div.list-group a.group-stats-show').on 'click', ->
    $('div.row div.group-main-wrapper').find('*').remove()
    loadGroupStats()
    # Group's Settings
  $('div.list-group a.group-settings-show').on 'click', ->
    $('div.row div.group-main-wrapper').find('*').remove()
    loadGroupSettings()


loadGroups = (pagination_selector, page = 1) ->
  $.ajax "/api/v1/groups?page=#{page}",
    type: 'get'
    dataType: 'json'
    success: (data, status) ->
      $.each data['results'], (i) ->
        addGroupToList(this)

loadGroup = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->

loadGroupMain = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      passData(data)

loadGroupUsers = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}/users",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      $.each data['results'], (u) ->
        passUserData(this)

loadGroupBets = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  passBetsData()


loadGroupStats = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  passStatsData()


loadGroupSettings = (data) ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      console.log(data.settings)
      passSettingsData(data.settings)


passData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  template = Handlebars.compile($('script#group-info-page').html())
  temp = $(template(data))
  $('div.row div.group-main-wrapper').html(temp)

passUserData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  template = Handlebars.compile($('script#group-users-page').html())
  temp = $(template(data))
  $('div.row div.group-main-wrapper').append(temp)

passBetsData = ->
  template = Handlebars.compile($('script#group-bets-page').html())
  temp = $(template())
  $('div.row div.group-main-wrapper').append(temp)

passStatsData = ->
  template = Handlebars.compile($('script#group-stats-page').html())
  temp = $(template())
  $('div.row div.group-main-wrapper').html(temp)


passSettingsData = (data) ->
  template = Handlebars.compile($('script#group-settings-page').html())
  temp = $(template(data))
  $('div.row div.group-main-wrapper').append(temp)




addGroupToList = (data) ->
  template = Handlebars.compile($('script#groups_index_page').html())
  temp = $(template({ id: data.id, name: data.name, settings: data.settings, created_at: new Date(data.created_at).toLocaleDateString() }))
  $('div.row div.col-md-3 ul.list-group').append(temp)

