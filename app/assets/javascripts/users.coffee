# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# route to event handler mappings

$('.users.index').ready ->
  loadUsers('#users_pagination')
  $('#clear-modal').click clearModal
  $('#create-user').click createUser

$('.users.show').ready ->
  getUser()
  getUserGroups()
  $('#update-user').click updateUser
  $('#clear-modal').click clearModal
  $('a[name=add-group-membership]').on 'click', (ev) ->
    ev.preventDefault()
    $('div[name=groups-list-div]').slideDown()
  $('button[name=add-group-membership-confirm]').on 'click', addUserToGroup
# event handlers
  $('[name=clear-modal]').click clearModal
  $('[name=create-user]').click createUser
  $('[name=update-user]').click updateUser
  $('[name=edit-elm').hide()
  $('[name=user-information-panel]').bind 'mouseover', ->
    $('[name=edit-elm').fadeIn()
    return

loadUsers = (pagination_selector, page = 1) ->
  $('#users_table').prepend($('<i class="fa fa-cog fa-spin fa-2x"></i>'))
  $('#users_table .list-group').remove()
  $.ajax "/api/v1/users?page=#{page}",
    type: 'get'
    dataType: 'json'
    success: (data, status) ->
      $('#users_table i').remove()
      $.each data['results'], (i) ->
        addUserToTable(this)
      $(pagination_selector).pagination({ items: data.count, itemsOnPage: data.per_page, currentPage: page, onPageClick: handleUserPagination })

getUser = ->
  user = window.location.pathname.match(/\/users\/(\d+)/)[1]
  $.ajax "/api/v1/users/#{user}",
    type: 'get'
    dataType: 'json'
    success: (data) ->
      showUserInfo(data)
      $('#display_name').val(data.display_name)
      $('#username').val(data.username)
      $('#email').val(data.email)

getUserGroups = ->
  user = window.location.pathname.match(/\/users\/(\d+)/)[1]
  $.ajax "/api/v1/users/#{user}/group_memberships?include[]=group",
    type: "get"
    dataType: "json"
    success: (data) ->
      $.each data, ->
        addGrouptotable(this.group)

addGrouptotable = (data) ->
  processData(data)
  template = Handlebars.compile($('script#user-groups-panel').html())
  temp = $(template(data))

  modaltemplate = Handlebars.compile($('script#user-groups-modal').html())
  modaltemp = $(modaltemplate(data))
  $('div.row div.user-group-panel div.list-group').append(temp)



addUserToTable = (data) ->
  template = Handlebars.compile($('script#users_index_page').html())
  temp = $(template({ id: data.id, email: data.email, username: data.username, display_name: data.display_name, created_at: new Date(data.created_at).toLocaleDateString() }))
  $('div.row div#users_table').append(temp)

showUserInfo = (data) ->
  processData(data)
  showTemplateForData("users_show_page", data)


# Preprocess data before you send it to render
processData = (data) ->
  data.created_at = new Date(data.created_at).toLocaleDateString()

# Render template (id) with data
showTemplateForData = (id, data) ->
  # generalized version for rerendering a particular template with new data
  template = Handlebars.compile($("script#" + id).html())
  temp = $(template(data))
  $("." + id).html(temp)

clearModal = (ev) ->
  clearModalContents() if confirm('Are you sure you want to clear all fields?')


clearModalContents = () ->
  $('#display_name').val('')
  $('#username').val('')
  $('#email').val('')
  $('#password').val('')
  $('#password_confirmation').val('')
  $('[name=admin-checkbox]').prop('checked', false)

handleUserPagination = (page, ev) ->
  ev.preventDefault()
  loadUsers('#users_pagination', page)


createUser = (ev) ->
  $.ajax "/api/v1/users",
    type: 'post',
    dataType: 'json',
    data:
      user:
        display_name: $('#display_name').val(),
        username: $('#username').val(),
        email: $('#email').val(),
        password: $('#password').val(),
#        password_confirmation: $('#password_confirmation').val()
    success: (data) ->
      $('[name=new-user-modal]').modal('hide')
      clearModalContents
      addUserToTable(data)


    error: (data) ->
      console.log(data.responseText)
      alert(data.username.join())


updateUser = (ev) ->
  user = window.location.pathname.match(/\/users\/(\d+)/)[1]
  $.ajax "/api/v1/users/#{user}",
    type: 'put'
    dataType: 'json'
    data:
      user:
        display_name: $('#display_name').val()
        username: $('#username').val()
        email: $('#email').val()
    success: (data) ->
      $('[name=update-user-modal]').modal('hide')
      showUserInfo(data)
      if (data.id == ENV.current_user)
        $('.logged-in-user').text(data.display_name)


addUserToGroup = (ev) ->
  sel = $('select[name=groups-list] option:selected')
  user = window.location.pathname.match(/\/users\/(\d+)/)[1]
  $.ajax "/api/v1/group_memberships",
    type: 'post'
    dataType: 'json'
    data: { group_membership: { user_id: user, group_id: sel.val() } }
    success: (data, status) ->
      console.log('success')
