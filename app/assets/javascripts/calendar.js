function updateCalendar() {
  var employeeCode = $('#employee_code').val();
  var selectedMonth = $('#selected_month').val();
  var year = $('#year').val();

  $.ajax({
    url: '/attendances/calendar_view',
    type: 'GET',
    data: { employee_code: employeeCode, selected_month: selectedMonth, year: year },
    success: function(data) {
      // Update calendar with new events
      var calendarEl = document.getElementById('calendar');
      var calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        events: data.events
      });
      calendar.render();
    },
    error: function(error) {
      console.error('Error updating calendar:', error);
    }
  });
}
