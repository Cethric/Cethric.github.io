/**
 * Created by blakerogan on 25/06/2015.
 */

function load_page() {
    var lp = document.getElementById("project_selection");
    var selection = lp.options[lp.selectedIndex].value;
    if (selection == "Projects") {
        parent.location.href = "http://cethric.github.io/" + selection + ".html";
    } else {
        parent.location.href = "http://cethric.github.io/" + selection + "/index.html";
    }
}