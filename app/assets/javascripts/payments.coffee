# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  loadPayments('#initiated_payments')
  loadPayments('#failed_payments')
  loadPayments('#processed_payments')

loadPayments = (selector, page = 1) ->
  elem = $(selector)
  template = Handlebars.compile($('#payment_row_template').html())
  $.ajax inferEndpoint(selector) + "&page=#{page}",
    dataType: 'json'
    type: 'get'
    success: (data) ->
      elem.children('i').remove()
      $.each data['results'], (obj, i) ->
        elem.children('.list-group').append($(template({ uuid: this.uuid, amount: this.amount, created_at: new Date(this.created_at).toLocaleString()})))
      elem.children('.pagination').pagination({ items: data.count, itemsOnPage: data.per_page, currentPage: page, onPageClick: paginatePayments.bind(elem) })

paginatePayments = (page, ev) ->
  ev.preventDefault()
  this.children('.list-group').children('a').remove()
  this.prepend($('<i class="fa fa-cog fa-spin fa-2x"></i>'))
  loadPayments("##{this[0].id}", page)

inferEndpoint = (selector) ->
  '/api/v1/payments?scope=' + selector.match(/#?(.+)_/)[1]