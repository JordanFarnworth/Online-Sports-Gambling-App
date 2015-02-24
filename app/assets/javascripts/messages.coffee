# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.messages.index, .messages.show').ready ->
  loadInboxMessages()
  loadSentMessages()
  $('#messages_selector').on 'change', (ev) ->
    if $('#messages_selector').val() == 'inbox'
      $('#message_inbox_container').addClass('active')
      $('#message_sent_container').removeClass('active')
    else
      $('#message_sent_container').addClass('active')
      $('#message_inbox_container').removeClass('active')

loadInboxMessages = ->
  loadMessages('#message_inbox_container', '#message_inbox_pagination', 'inbox')

loadSentMessages = ->
  loadMessages('#message_sent_container', '#message_sent_pagination', 'sent')

loadMessages = (selector, pagination_selector, endpoint, page = 1) ->
  $(selector).prepend($('<i class="fa fa-cog fa-spin fa-2x"></i>'))
  $(selector + ' ul li').remove()
  $(selector + ' div').remove()
  $.ajax "/api/v1/messages?scope=#{endpoint}&include[]=sender&page=#{page}",
    type: 'get'
    dataType: 'json'
    success: (data, status) ->
      template = Handlebars.compile($('script#message_sidebar_template').html())
      $(selector + ' i').remove()
      $.each data['results'], (i) ->
        temp = $(template({ id: this.id, subject: this.subject, sender: this.sender.display_name, body: this.body, preview: this.body.substring(0, 100), created_at: new Date(this.created_at).toLocaleDateString() }))
        $(pagination_selector).before(temp)
      $(pagination_selector).pagination({ items: data.count, itemsOnPage: data.per_page, currentPage: page, onPageClick: (if selector == '#message_inbox_container' then handleInboxPagination else handleSentPagination) })

handleInboxPagination = (page, ev) ->
  ev.preventDefault()
  loadMessages('#message_inbox_container', '#message_inbox_pagination', 'inbox', page)

handleSentPagination = (page, ev) ->
  ev.preventDefault()
  loadMessages('#message_sent_container', '#message_sent_pagination', 'sent', page)