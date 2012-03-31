voteable = new Array();

function upVote(argument_id, vote, debate_id, current_votes) {
  // incrementVotesFor(argument_id);
	if (voteable[debate_id] == true && current_votes <= 0 && argvoteable[argument_id] != 1) {
		if (current_votes == 0) {argvoteable[argument_id] = 1}
		$.ajax({
	      	type: "POST",
	      	url: "/votes.js?argument_id=" + argument_id + "&vote=" + vote + "&debate_id=" + debate_id
	    });
	}
}
function incrementVotesFor(argument_id) {
  $(".votes_for_count[data-argument_id="+argument_id+"]").text(parseInt($(".votes_for_count[data-argument_id="+argument_id+"]").text())+1);
}

function downVote(argument_id, vote, debate_id, current_votes) {
  // incrementVotesAgainst(argument_id);
  	if (voteable[debate_id] == true && current_votes <= 0 && argvoteable[argument_id] != 1) {
		if (current_votes == 0) {argvoteable[argument_id] = 1}
		$.ajax({
	      	type: "POST",
	      	url: "/votes.js?argument_id=" + argument_id + "&vote=" + vote + "&debate_id=" + debate_id
	    });
	}
}
function incrementVotesAgainst(argument_id) {
  $(".votes_against_count[data-argument_id="+argument_id+"]").text(parseInt($(".votes_against_count[data-argument_id="+argument_id+"]").text())-1);
}

function upVoteTopic(topic_id) {
	$.ajax({
      	type: "POST",
      	url: "/votes/topicvote.js?topic_id=" + topic_id
    });
}
