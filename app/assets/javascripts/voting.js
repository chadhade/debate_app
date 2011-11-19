function upVote(argument_id, vote) {
  incrementVotesFor(argument_id);
  	$.ajax({
      type: "POST",
      url: "/votes.js?argument_id=" + argument_id + "&vote=" + vote
    });
}
function incrementVotesFor(argument_id) {
  $(".votes_for_count[data-argument_id="+argument_id+"]").text(parseInt($(".votes_for_count[data-argument_id="+argument_id+"]").text())+1);
}

function downVote(argument_id, vote) {
  incrementVotesAgainst(argument_id);
  	$.ajax({
      type: "POST",
      url: "/votes.js?argument_id=" + argument_id + "&vote=" + vote
    });
}
function incrementVotesAgainst(argument_id) {
  $(".votes_against_count[data-argument_id="+argument_id+"]").text(parseInt($(".votes_against_count[data-argument_id="+argument_id+"]").text())+1);
}

