# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.roles').ready ->
  $('[data-toggle="tooltip"]').tooltip()
$('.roles.show').ready ->
  loadUsers()
  $('[name=add-user-to-role]').click addUserToRole
  $('#user').autocomplete autocompleteParams()
  $('button[data-target="#add_user_to_role_modal"]').click ->
    targ = $('#user')
    targ.val('')
    targ.removeAttr('data-user-id')
    targ.prop('disabled', false)

  $('#add_user_to_role_modal').on 'shown.bs.modal', (ev) ->
    $('#user').focus()

loadUsers = (page = 1, ev = null) ->
  ev.preventDefault() if ev
  $('#role_users').prepend($('<i class="fa fa-cog fa-spin fa-2x"></i>'))
  $('#role_users .list-group a').remove()
  role = window.location.pathname.match(/roles\/(\d+)/)[1]
  $.ajax "/api/v1/roles/#{role}/users?page=#{page}",
    type: 'get'
    dataType: 'json'
    success: (data, status) ->
      $('#role_users i').remove()
      $.each data['results'], (i) ->
        placeUserTemplate this.user.id, this.user.display_name, new Date(this.updated_at).toLocaleDateString(), this.id
      $('#role_users_pagination').pagination({ items: data.count, itemsOnPage: data.per_page, currentPage: page, onPageClick: loadUsers })

placeUserTemplate = (user_id, name, date, membership_id) ->
  template = Handlebars.compile($('script#role_users_template').html())
  temp = $(template({ id: user_id, name: name, date: date, membership_id: membership_id, can_assign_roles: ENV.permissions.assign_roles }))
  $('#role_users .list-group').append(temp)
  temp.find('[name=remove-user-from-role]').click deleteMembership

deleteMembership = (ev) ->
  bootbox.confirm 'Are you sure you want to remove this user from the role?', (result) ->
    return unless result
    targ = $(ev.target)
    role = window.location.pathname.match(/roles\/(\d+)/)[1]
    mem_id = targ.attr('data-role-membership-id')
    $.ajax
      type: 'delete'
      url: "/api/v1/roles/#{role}/role_memberships/#{mem_id}"
      data: {}
      success: ->
        targ.parents('.list-group-item').remove()

addUserToRole = (ev) ->
  targ = $('#user')
  return unless targ.attr('data-user-id')
  role = window.location.pathname.match(/roles\/(\d+)/)[1]
  $.ajax
    type: 'post'
    url: "/api/v1/roles/#{role}/role_memberships"
    data:
      role_membership:
        user_id: targ.attr('data-user-id')
    success: (data, status) ->
      $('#add_user_to_role_modal').modal('hide')
      placeUserTemplate(data.user.id, data.user.display_name, new Date(data.updated_at).toLocaleDateString(), data.id)

autocompleteParams = ->
  {
  source:(request, response) ->
    $.ajax
      url: "/api/v1/users"
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
    targ = $('#user')
    targ.val(ui.item.label)
    targ.attr('data-user-id', ui.item.value)
    targ.prop('disabled', true)
  }