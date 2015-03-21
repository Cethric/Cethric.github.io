function projectExpander() {
    var expander = document.getElementById("menubarProj")
    var children = expander.children;
    for (var childID in children) {
        var child = expander.children[childID];
        if (child != "undefined") {
            if (child.style.display == "none") {
                child.style.display = "block";
                document.getElementById("projExpander").innerHTML = "-"
            } else {
                child.style.display = "none";
                document.getElementById("projExpander").innerHTML = "+"
            }
        }
    }
}