# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.messages.index, .messages.show').ready ->
  loadInboxMessages()
  loadSentMessages()
  $('.message-listing').click renderMessage
  $('button[name=new-message]').click openMessageModal
  $('#recipients').autocomplete autocompleteParams()
  $('[name=clear-message-modal]').click clearModal
  $('[name=create-message]').click createMessage
  $('[name=delete-message]').click deleteMessage
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
        recips = mapRecipients(this.participants)
        temp = $(template({ id: this.id, subject: this.subject, sender: this.sender.display_name, \
          body: this.body, preview: this.body.substring(0, 100), recipients: recips, \
          created_at: new Date(this.created_at).toLocaleString(), is_sender: this.sender.id == ENV.current_user, \
          truncated_recipients: mapRecipients(this.participants).substring(0, 100) + (if recips.length > 100 then '...' else ''), \
          unread: this.state == 'unread' }))
        $(selector).append(temp)
        temp.find('a:first').click renderMessage
      $(pagination_selector).pagination({ edges: 0, displayedPages: 3, items: data.count, itemsOnPage: data.per_page, currentPage: page, onPageClick: (if selector == '#message_inbox_container' then handleInboxPagination else handleSentPagination) })

mapRecipients = (recips) ->
  r = $(recips).map (val, i) ->
    this.display_name

  r.toArray().join ', '

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
  $('#message_pane').html($(template({ subject: targ.data('subject'), sender: targ.data('sender'), \
    recipients: targ.data('recipients'), body: targ.data('body').split('\n').join('<br>'), created_at: targ.data('created-at') })))

  if targ.data('unread')
    $.ajax
      url: "/api/v1/messages/#{targ.data('id')}"
      data:
        message:
          state: 'read'
      type: 'put'
      success: ->
        targ.attr('data-unread', false)
        targ.find('i[name=unread-marker]:first').remove()

openMessageModal = (ev) ->
  $('[name=new-message-modal]').modal()

clearModal = (skip_confirmation = false) ->
  unless skip_confirmation
    return unless confirm('Are you sure you want to clear this message?')
  $('#message').val('')
  $('#recipients').val('')
  $('#subject').val('')
  $('[name=remove-recipient]').parents('li:first').remove()

addErrorMessage = (selector, message) ->
  selector.addClass('has-error')
  selector.append($('<span class="help-block">' + message + '</span>'))

validateMessage = ->
  $('.has-error').removeClass('has-error')
  $('span.help-block').remove()
  recips = $.map $('[name=recipient]'), (val, i) ->
    parseInt($(val).val())
  addErrorMessage($('label[for=recipients]').parents('div.form-group:first'), 'must include a valid recipient') if recips.length == 0 || (recips.length == 1 && recips[0] == ENV.current_user)

  addErrorMessage($('#subject').parents('div.form-group:first'), 'must be lengthier than 3 characters') if $('#subject').val().length < 3
  addErrorMessage($('#message').parents('div.form-group:first'), 'must be lengthier than 3 characters') if $('#message').val().length < 3
  return $('.help-block').length == 0

createMessage = (ev) ->
  return unless validateMessage()
  recips = $.map $('[name=recipient]'), (val, i) ->
    parseInt($(val).val())

  $.ajax '/api/v1/messages',
    type: 'post'
    dataType: 'json'
    data:
      message:
        subject: $('#subject').val()
        body: $('#message').val()
        sender_id: ENV.current_user
        message_participants_attributes:
          recips.map (val, i) ->
            { user_id: val }
    success: (data) ->
      $('[name=new-message-modal]').css('display', 'none')
      clearModal(true)
      $('[name=message-success-modal]').modal()

deleteMessage = (ev) ->
  return unless $('.message-listing.active').length == 1 # Don't show dialog unless a message is selected
  bootbox.confirm 'Are you sure you want to delete this message?', (result) ->
    return unless result
    targ = $('a.message-listing.active:first')
    $.ajax
      url: "/api/v1/messages/#{targ.data('id')}"
      dataType: 'json'
      data: {}
      type: 'delete'
      success: (data) ->
        targ.parents('div:first').remove()
        $('#message_pane div').remove()

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
      #$('.input-box').prepend(comp)
      $('.ac-token-list').append(comp)
      $(comp).find('[name=remove-recipient]').click (ev) ->
        $(ev.target).parents('li:first').remove()
  }