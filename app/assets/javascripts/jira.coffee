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
    $('.report').html('')
    return

  $('#group_by').live 'change', ->
    groupings = []
    $('#s2id_group_by > ul > li > div').each ->
      groupings.push $(this).text()
    $('#ordered_group_by').val groupings
  return


$(document).ready(ready)
$(document).on('page:load', ready)
