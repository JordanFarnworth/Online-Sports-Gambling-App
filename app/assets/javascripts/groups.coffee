# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.groups.index').ready ->

$('.groups.show').ready ->
  loadGroupMain()
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
  $('div.list-group a.group-lobbies-show').on 'click', ->
    $('div.row div.group-main-wrapper').find('*').remove()
    loadGroupLobbies()
    # Group's Stats
  $('div.list-group a.group-stats-show').on 'click', ->
#    $('div.row div.group-main-wrapper').find('*').remove()
    loadGroupStats()
    # Group's Settings
  $('div.list-group a.group-settings-show').on 'click', ->
    $('div.row div.group-main-wrapper').find('*').remove()
    loadGroupSettings()
  $('[data-toggle="tooltip"]').tooltip()


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
      passUsersData(data)


loadGroupLobbies = ->
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
      passSettingsData(data)


      # Creating Templates with data

passData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  render(data, "group-info-page")

passUsersData = (data) ->
#  debugger
#  $.each data['results'], (u) ->
#    u.created_at = new Date(data.created_at).toLocaleDateString()
  render(data, "group-users-page")

passBetsData = (data) ->
  render(data, "group-lobbies-page")

passStatsData = (data) ->
  render(data, "group-stats-page")

passSettingsData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  render(data, "group-settings-page")

render = (data, id) ->
  template = Handlebars.compile($('script#' + id).html())
  temp = $(template(data))
  $('div.row div.group-main-wrapper').html(temp)

