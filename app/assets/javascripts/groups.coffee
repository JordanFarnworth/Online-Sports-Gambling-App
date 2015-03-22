# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.groups.index').ready ->

$('.groups.show').ready ->
  loadGroupMain()
  loadGroupUsers()
  loadGroupSettings()
  loadGroupStats()
  loadGroupLobbies()
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
      loadGroupSettings()



loadGroupMain = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      passData(data)
      $('div.list-group a.group-show').on 'click', ->
        passData(data)

loadGroupUsers = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}/users",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      $('div.list-group a.group-users-show').on 'click', ->
        passUsersData(data)


loadGroupLobbies = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $('div.list-group a.group-lobbies-show').on 'click', ->
    passLobbiesData()


loadGroupStats = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $('div.list-group a.group-stats-show').on 'click', ->
    passStatsData()


loadGroupSettings = (data) ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      passSettingsData(data)
      $('div.list-group a.group-settings-show').on 'click', ->
        passSettingsData(data)
      updateModalContent(data)


      # Creating Templates with data

passData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  render(data, "group-info-page")

passUsersData = (data) ->
  render(data, "group-users-page")

passLobbiesData = (data) ->
  render(data, "group-lobbies-page")

passStatsData = (data) ->
  render(data, "group-stats-page")

passSettingsData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()
  render(data, "group-settings-page")

  #render engine
render = (data, id) ->
  template = Handlebars.compile($('script#' + id).html())
  temp = $(template(data))
  $('div.row div.group-main-wrapper').html(temp)

