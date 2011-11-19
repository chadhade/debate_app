$(function() {
  setTimeout(updateArguments, 5000);
});
function updateArguments() {
  var voting_params_string = "voting_params=";
  $(".votes").each(function() {
    var arg_id = $(this).attr("data-argument_id");
	var for_time = $(".votes_for_count", this).attr("data-time");
	var against_time = $(".votes_against_count", this).attr("data-time");
	voting_params_string = voting_params_string + arg_id + ":" + for_time + ":" + against_time + "@";
  });
 
  var arguments_params_string = "arguments_params=";
  $(".debate").each(function() {  
    var debate_id = $(this).attr("data-id");
    if ($(".argument", this).length > 0) {
      var after = $(".argument:last", this).attr("data-time");
    } else {
      var after = "0";
    }
	arguments_params_string = arguments_params_string + debate_id + ":" + after + "@";
  });
  
  $.getScript("/arguments.js?" + arguments_params_string + "&" + voting_params_string);
  setTimeout(updateArguments, 5000);
}

function startTracking() {
	var debater_id = $("#tracking").attr("data-debater_id");
	var debate_id = $(".debate").attr("data-id");
	$.ajax({
      type: "POST",
      url: "/debaters/" + debater_id + "/trackings.js?debate_id=" + debate_id,
      success: function(){
        alert("started tracking debate");
      }
    });
}
