window.onbeforeunload = OnBeforeUnLoad;
function OnBeforeUnLoad () {
  $.getScript(window.location.pathname + "/leaving.js");
  return "Goodbye";
}
