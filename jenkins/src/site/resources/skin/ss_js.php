<?php
header('Content-type: text/javascript');
?>
/**
 * Canon for Jenkins Javascript Overrides
 *
 * Leverages Jankins-included Prototype.js
 *
 * @author Rackspace Web Team
 * @version 0.1
 */

function insertAfter(newNode, referenceNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
}

document.observe("dom:loaded", function () {
    document.getElementById('jenkins-name-icon').src='/docs/img/jenkins_by_develenv.png'
    document.getElementById('jenkins-home-link').href='/docs/'
    var softwaresano_logo=new Element('span').update('<div id="side-panel-footer" class="col-md-11"><a href="http://www.softwaresano.com"><img src="http://pimpam.googlecode.com/files/viewJenkins.png" width="100%"/></a></div>');
    insertAfter(softwaresano_logo,document.getElementById('side-panel-content'))
    var menuTools='<div id="menu-outer"><div id="menu-table"> <ul id="horizontal-list"><li><a href="/sonar/"          > Sonar</a></li>'
    menuTools=menuTools+'<li><a href="/nexus/"          > Nexus</a></li>'
    menuTools=menuTools+'<li><a href="/grid/console"    > Selenium Grid</a></li>'
    menuTools=menuTools+'<li><a href="/develenv/repos/" > Repositories</a></li>'
    menuTools=menuTools+'<li><a href="/devpi/develenv/dev/+simple/" > Devpi Repository</a></li>'
    menuTools=menuTools+'<li><a href="/develenv/dp/"    > Deployment Pipeline</a></li>'
    menuTools=menuTools+'<li><a href="/sites"           > Sites</a></li>'
    menuTools=menuTools+'<li><a href="/develenv/admin/" > Admin</a></li>'
    menuTools=menuTools+'<li><a  href="/docs/" > Help</a></li>'
    menuTools=menuTools+'</ul></div></div>'
    divMenu=new Element('span').update(menuTools)
    var sp2=document.getElementById('page-body')
    var parentDiv = sp2.parentNode;
    parentDiv.insertBefore(divMenu, sp2);
});
