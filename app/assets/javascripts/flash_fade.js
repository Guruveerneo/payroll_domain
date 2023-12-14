$(document).ready(function(){
  // Function to fade out flash messages
  function fadeOutFlash(selector) {
    setTimeout(function(){
      $(selector).fadeOut('slow');
    }, 3000);
  }

  // Fade out flash messages after page load
  fadeOutFlash('.flash-notice');
  fadeOutFlash('.flash-success');
  fadeOutFlash('.flash-alert');
});