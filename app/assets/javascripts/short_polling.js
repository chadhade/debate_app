$(function() {
  setTimeout(updateArguments, 5000);
});
function updateArguments() {
  var debate_id = $(".debate").attr("data-id");
 
  var voting_params_string = "voting_params=";
  $(".votes").each(function() {
    var arg_id = $(this).attr("data-argument_id");
	var for_time = $(".votes_for_count", this).attr("data-time");
	var against_time = $(".votes_against_count", this).attr("data-time");
	voting_params_string = voting_params_string + arg_id + ":" + for_time + ":" + against_time + "@";
  });
 
  if ($(".argument").length > 0) {
    var after = $(".argument:last").attr("data-time");
  } else {
    var after = "0";
  }
  $.getScript("/arguments.js?debate_id=" + debate_id + "&after=" + after + "&" + voting_params_string);
  setTimeout(updateArguments, 5000);
}

function incrementVotesFor(argument_id) {
  $(".votes_for_count[data-argument_id="+argument_id+"]").text(parseInt($(".votes_for_count[data-argument_id="+argument_id+"]").text())+1);
}

function incrementVotesAgainst(argument_id) {
  $(".votes_against_count[data-argument_id="+argument_id+"]").text(parseInt($(".votes_against_count[data-argument_id="+argument_id+"]").text())+1);
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
