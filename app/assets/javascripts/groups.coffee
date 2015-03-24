# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.groups.index').ready ->

$('.groups.show').ready ->
  loadGroupUsers()
  loadGroupSettings()
  loadGroupStats()
  loadGroupLobbies()
  loadGroupMain()
  $(' div.list-group a.list-group-item').on 'click',  ->
    $('div.list-group a.active').removeClass('active')
    $(this).addClass('active')
  $('#update-group-settings').on 'click', ->
    updateGroupSettings()

updateModalContent = (data) ->
  $('#group-name').val(data.name)
  $('#max-users').val(data.settings.max_users)
  $('#avail').val(data.settings.availability)
  $('textarea').val(data.settings.description)
  $('#lobbies').val(data.settings.lobbies)

#Juery UPDATE functions

updateGroupSettings = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'put'
    dataType: 'json'
    data:
      group:
        name: $('#group-name').val()
        settings:
          max_users: $('#max-users').val()
          lobbies: $('#lobbies').val()
          description: $('textarea').val()
          availability: $('select#avail').val()
    success: (data) ->
      $('#my-group-setting-modal').modal('hide')
      passData(data)
      passSettingsData(data)
      render(data, "group-settings-page")

#Jquery GET functions

loadGroupMain = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      passData(data)
      render(data, "group-info-page")

loadGroupUsers = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}/users",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      passUsersData(data)

loadGroupLobbies = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  passLobbiesData()

loadGroupStats = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  passStatsData()

loadGroupSettings = (data) ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      passSettingsData(data)
      updateModalContent(data)

# Creating Templates with data

passData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  $('div.list-group a.group-show').on 'click', ->
    render(data, "group-info-page")

passUsersData = (data) ->
  $('div.list-group a.group-users-show').on 'click', ->
    render(data, "group-users-page")

passLobbiesData = (data) ->
  $('div.list-group a.group-lobbies-show').on 'click', ->
    render(data, "group-lobbies-page")

passStatsData = (data) ->
  $('div.list-group a.group-stats-show').on 'click', ->
    render(data, "group-stats-page")

passSettingsData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  $('div.list-group a.group-settings-show').on 'click', ->
    render(data, "group-settings-page")

#render engine
render = (data, id) ->
  template = Handlebars.compile($('script#' + id).html())
  temp = $(template(data))
  $('div.row div.group-main-wrapper').html(temp)


