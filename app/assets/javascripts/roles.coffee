# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.roles').ready ->
  $('[data-toggle="tooltip"]').tooltip()
$('.roles.show').ready ->
  loadUsers()

loadUsers = (page = 1, ev = null) ->
  ev.preventDefault() if ev
  $('#role_users').prepend($('<i class="fa fa-cog fa-spin fa-2x"></i>'))
  $('#role_users .list-group a').remove()
  role = window.location.pathname.match(/roles\/(\d+)/)[1]
  $.ajax "/api/v1/roles/#{role}/users?page=#{page}",
    type: 'get'
    dataType: 'json'
    success: (data, status) ->
      template = Handlebars.compile($('script#role_users_template').html())
      $('#role_users i').remove()
      $.each data['results'], (i) ->
        temp = $(template({ id: this.id, name: this.display_name, date: new Date(this.created_at).toLocaleDateString() }))
        $('#role_users .list-group').append(temp)
      $('#role_users_pagination').pagination({ items: data.count, itemsOnPage: data.per_page, currentPage: page, onPageClick: loadUsers })