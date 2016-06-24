---
title: Posts
layout: page
---
# Posts

<div class='row'>
    <div class='col-19'>
        <table class='posts-table'>
        {% tablerow post in site.posts cols:6 %}
        <p style='position:absolute; top:1px;'><a href="{{ post.url }}">{{post.title}}</a></p><br/>
        {{ post.excerpt }}
        {% endtablerow %}
        </table>
    </div>
</div>
