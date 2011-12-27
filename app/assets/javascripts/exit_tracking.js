window.onbeforeunload = OnBeforeUnLoad;
function OnBeforeUnLoad () {
  $.getScript(window.location.pathname + "/leaving.js");
  return "DeBunky says ALWAYS CLICK LEAVE PAGE!";
}
