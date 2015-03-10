# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.users.index').ready ->
  loadUsers('#users_pagination')
  $('[name=clear-modal]').click clearModal
  $('[name=create-user]').click createUser
  $('[name=edit-elm').hide()

$('.users.show').ready ->
  $('[name=update-user]').click updateUser
  $('[name=clear-modal]').click clearModal

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

addUserToTable = (data) ->
  template = Handlebars.compile($('script#users_index_page').html())
  temp = $(template({ id: data.id, email: data.email, username: data.username, display_name: data.display_name, created_at: new Date(data.created_at).toLocaleDateString() }))
  $('div.row div#users_table').append(temp)

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

addUserToGroup = (ev) ->
  user = window.location.pathname.match(/\/users\/(\d+)/)[1]
  $.ajax "/api/v1/users/#{user}/group_memberships",
    type: 'post'

