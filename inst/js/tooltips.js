function activeTooltips() {
  $('[data-toggle="tooltip"]').tooltip('destroy')
  $('[data-toggle="tooltip"]').tooltip({container: 'body', html: true})
}