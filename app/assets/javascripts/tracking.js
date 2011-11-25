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