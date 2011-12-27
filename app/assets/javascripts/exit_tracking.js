window.onbeforeunload = OnBeforeUnLoad;
function OnBeforeUnLoad () {
  $.getScript(window.location.pathname + "/leaving.js");
  return "If you decide to stay, please refresh the page!";
}
