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
  setDate = ->
    $('#from').val $(this).data("from")
    $('#to').val $(this).data("to")
    return

  $('.set-date').click setDate

$(document).ready(ready)
$(document).on('page:load', ready)
