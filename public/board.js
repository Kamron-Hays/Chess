$(document).ready(function()
{
  let status = $('#status').text().trim();
  let input = $('#input').val();
  let start = "";

  if ( input == "machine" )
  {
    $('#input').val("");
    // Wait 1 second before submitting machine response.
    setTimeout(submit, 1000);
  }

  $('button').on('click', function()
  {
    let name = $(this).attr("name");
    $('#input').val(name);
    $('#board').submit();
  });

  $('.square').on('click', function()
  {
    let name = $(this).attr("name");
    $('#input').val(name);
    $('#board').submit();
  });
  
  function submit()
  {
    $('#board').submit();
  }
});
