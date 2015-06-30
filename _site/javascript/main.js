var list = document.getElementById("project_list");
var posts = document.getElementById('posts');

list.onclick = function(e) {
    e.stopPropagation();
    if (list.style.display=='none') {
        list.style.display = 'block';
    } else {
        list.style.display = 'none';
    }
}

function more_menu() {
    if (posts.style.right=='-50em') {
        posts.style.right = "0";
    } else {
        posts.style.right = "-50em";
    }
}