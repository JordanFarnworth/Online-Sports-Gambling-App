# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.messages.index, .messages.show').ready ->
  loadInboxMessages()
  loadSentMessages()
  $('.message-listing').click renderMessage
  $('button[name=new-message]').click openMessageModal
  $('#recipients').autocomplete autocompleteParams()
  $('#messages_selector').on 'change', (ev) ->
    if $('#messages_selector').val() == 'inbox'
      $('#message_inbox_container').parent('.tab-pane').addClass('active')
      $('#message_sent_container').parent('.tab-pane').removeClass('active')
    else
      $('#message_sent_container').parent('.tab-pane').addClass('active')
      $('#message_inbox_container').parent('.tab-pane').removeClass('active')

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
        temp = $(template({ id: this.id, subject: this.subject, sender: this.sender.display_name, body: this.body, preview: this.body.substring(0, 100), created_at: new Date(this.created_at).toLocaleString() }))
        $(selector).append(temp)
        temp.find('a:first').click renderMessage
      $(pagination_selector).pagination({ edges: 0, displayedPages: 3, items: data.count, itemsOnPage: data.per_page, currentPage: page, onPageClick: (if selector == '#message_inbox_container' then handleInboxPagination else handleSentPagination) })

handleInboxPagination = (page, ev) ->
  ev.preventDefault()
  loadMessages('#message_inbox_container', '#message_inbox_pagination', 'inbox', page)

handleSentPagination = (page, ev) ->
  ev.preventDefault()
  loadMessages('#message_sent_container', '#message_sent_pagination', 'sent', page)

renderMessage = (ev) ->
  ev.preventDefault()
  targ = $(ev.target)
  targ = targ.parents('a:first') unless targ.is('a')
  $('.message-listing').removeClass('active')
  targ.addClass('active')

  template = Handlebars.compile($('script#message_template').html())
  $('#message_pane').html($(template({ subject: targ.data('subject'), sender: targ.data('sender'), body: targ.data('body'), created_at: targ.data('created-at') })))

openMessageModal = (ev) ->
  $('[name=new-message-modal]').modal()

autocompleteParams = ->
  {
    source:(request, response) ->
      $.ajax
        url: "/api/v1/messages/recipients"
        dataType: "json"
        data:
          search_term: request.term

        success: (data) ->
          data = $.map data, (obj, i) ->
            {label: obj['display_name'], value: obj['id']}
          response data

    select:(event, ui) ->
      event.preventDefault()
      return unless ui.item

      template = Handlebars.compile($('#recipient_template').html())
      comp = $(template({ name: ui.item.label, id: ui.item.value }))
      $('#recipients').val('')
      $('.input-box').prepend(comp)
  }