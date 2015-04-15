# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.groups.index').ready ->
  $('#group-input-search').autocomplete autocompleteGroupParams()

$('.groups.show').ready ->
  $('#userInputSearch').autocomplete autocompleteUserParams()
  loadGroupUsers()
  loadGroupSettings()
  loadGroupStats()
  loadGroupLobbies()
  loadGroupMain()
  $('#update-group-settings').on 'click', ->
    updateGroupSettings()
  $('#update-group-users').on 'click', ->
    addToGroup()
    $('#userInputSearch').val("")

updateModalContent = (data) ->
  $('#group-name').val(data.name)
  $('#max-users').val(data.settings.max_users)
  $('#avail').val(data.settings.availability)
  $('textarea').val(data.settings.description)
  $('#lobbies').val(data.settings.lobbies)

#Juery UPDATE functions

addToGroup = () ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}/users",
    type: 'put'
    dataType: 'json'
    data:
      group_membership:
        user_id: $('#userInputSearch').attr('data-user-id'),
        group_id: group ,
        role: $('#user-to-select').val()
    success: (data, status) ->
      $('#add-user').modal('hide')
      loadGroupUsers()


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

loadGroupSettings = () ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  $.ajax "/api/v1/groups/#{group}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      passSettingsData(data)
      updateModalContent(data)

#jquery remove function

removeUser = (gm) ->
  $.ajax "/api/v1/group_memberships/#{gm}",
    type: 'delete'
    dataType: 'json'
    data:{}
    success: ->
      $('#edit-user').modal('hide')
      loadGroupUsers()


updateUserRole = (gm) ->
  $.ajax "/api/v1/group_memberships/#{gm}",
    type: 'put'
    dataType: 'json'
    data:
      group_membership:
        role: $('select#edit-user-role').val()
    success: (data) ->
      $('#edit-user').modal('hide')
      loadGroupUsers()



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
  temp.find('i#open-user-edit-modal').on 'click', ->
    showModal(event)
  $(pane).html(temp)

showModal = (ev) ->
  $('#edit-user').modal('show')
  ele = $(ev.target).parents('div.group-user-row')
  groupMembership = ele.attr('data-group-membership-id')
  role = ele.attr('data-role')
  displayName = ele.attr('data-display-name')
  $('input.edit-user-display-name').val(displayName)
  $('input.edit-user-display-name').prop('disabled', true)
  $('#edit-user-role').val(role.toLowerCase())
  $('#remove-user-button').on 'click', ->
    removeUser(groupMembership)
  $('#update-user-role-button').on 'click', ->
    updateUserRole(groupMembership)


autocompleteGroupParams = ->
  {
    source:(request, response) ->
      $.ajax
        url: "/api/v1/groups",
        dataType: "json"
        data:
          search_term: request.term

        success: (data) ->
          data = $.map data['results'], (obj, i) ->
            {label: obj.name, value: obj.id, obj: obj}
          response data

    select:(event, ui) ->
      event.preventDefault()
      return unless ui.item
      console.log(ui.item)
      $( "#selected-group-index-page" ).removeClass( "hidden" )

  }

autocompleteUserParams = ->
  group = window.location.pathname.match(/\/groups\/(\d+)/)[1]
  {
    source:(request, response) ->
      $.ajax
        url: "/api/v1/groups/#{group}/potential_applicants"
        dataType: "json"
        data:
          search_term: request.term

        success: (data) ->
          data = $.map data['results'], (obj, i) ->
            {label: obj['display_name'], value: obj['id']}
          response data

    select:(event, ui) ->
      event.preventDefault()
      return unless ui.item
      $('#userInputSearch').val(ui.item.label)
      $('#userInputSearch').attr('data-user-id', ui.item.value)
  }
