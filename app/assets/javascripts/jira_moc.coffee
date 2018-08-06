# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

AJS.$(document).ready ->
  AJS.$('.aui-date-picker').each ->
    AJS.$(this).datePicker 'overrideBrowserDefault': true
    return

  AJS.$(".aui-select2").each ->
    AJS.$(this).auiSelect2()
    return

ready = ->
  $('.set-date').click ->
    $('#from').val $(this).data("from")
    $('#to').val $(this).data("to")
    return

  $('#clear').click ->
    $('.aui-select2').select2 'val', ''
    $('#report').html('')
    return

  if 'localStorage' of window and window['localStorage'] != null
    if 'myTable' of localStorage and window.location.hash == '#reportMOC'
#      $('#s2id_group_by').html localStorage.getItem('groupByReportMOC')
#      $('#s2id_group_by').trigger('change')
      $('#report').html localStorage.getItem('reportMOC')

$(window).unload ->
  if 'localStorage' of window and window['localStorage'] != null
#    localStorage.setItem 'groupByReportMOC', $('#s2id_group_by').html()
#    localStorage.setItem 'groupingsReportMOC', getGroupings
    localStorage.setItem 'reportMOC', $('#report').html()
  return

getGroupings = ->
  groupings = []
  $('#s2id_group_by > ul > li > div').each ->
    groupings.push $(this).text()
  return groupings

$(document).ready(ready)
$(document)
  .on('page:load', ready)

  .on 'submit', '#query_form', (event) ->
    event.preventDefault()
    groupings = []
    $('#s2id_group_by > ul > li > div').each ->
      groupings.push $(this).text()
    $('#ordered_group_by').val groupings
    location.hash = 'reportMOC'
    $('#apply').click()
