# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.groups.index').ready ->
  loadGroups('#groups_pagination')


loadGroups = (pagination_selector, page = 1) ->
#  $('.row').prepend($('<i class="fa fa-cog fa-spin fa-2x"></i>'))
  $.ajax "/api/v1/groups?page=#{page}",
    type: 'get'
    dataType: 'json'
    success: (data, status) ->
      $.each data['results'], (i) ->
        addGroupToList(this)




addGroupToList = (data) ->
  template = Handlebars.compile($('script#groups_index_page').html())
  temp = $(template({ id: data.id, name: data.name, settings: data.settings, created_at: new Date(data.created_at).toLocaleDateString() }))
  $('div.row div.col-md-3 ul.list-group').append(temp)

