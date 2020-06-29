function activeTooltips() {
  $('.tooltip').remove()
  $('[data-toggle="tooltip"]').tooltip({container: 'body', html: true})
}