---
title: Projects
layout: default
permalink: /projects
---
<div class='row'>
<h1> Projects </h1>
</div>
<div class='row'>
<div class='col-19'>
    <table class='project_list w8'>
    {% tablerow project in site.data.projects % cols:6 %}
        {% assign image = "url(images/imageDefault-01.svg)" %}
        {% if project.image != 'none' %}
            {% assign image = {{project.image | append:")" | prepend:"url("}} %}
        {% endif %}
        <div style='background-image:{{image}}' class='project_item' onclick="">
            <div class='project_excerpt'>
                <a href="{{ project.url }}" >{{ project.summary | remove: '<p>' | remove: '</p>' }}</a>
            </div>
            <span class='project_link'>{{ project.title }}</span>
        </div>
    {% endtablerow %}
    </table>
</div>
</div>
