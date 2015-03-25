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
  $.ajax "/api/v1/groups/#{group}/users?include[]=user",
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
  render(data, "group-info-page", '#group_show_pane')

passUsersData = (data) ->
  render(data, "group-users-page", '#group_users_pane')

passLobbiesData = (data) ->
  render(data, "group-lobbies-page", '#group_lobbies_pane')

passStatsData = (data) ->
  render(data, "group-stats-page", '#group_stats_pane')

passSettingsData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  render(data, "group-settings-page", '#group_settings_pane')

#render engine
render = (data, id, pane) ->
  $(pane + ' i').remove()
  template = Handlebars.compile($('script#' + id).html())
  temp = $(template(data))
  $(pane).html(temp)


