<?php
header('Content-type: text/css');
?>
<style media="screen" type="text/css">
  h1 {
    text-align:center;
  }
#centeredmenu {
   float:left;
   width:100%;
   background:#fff;
   border-bottom:4px solid #000;
   overflow:hidden;
   position:relative;
}
#centeredmenu ul {
   clear:left;
   float:left;
   list-style:none;
   margin:0;
   padding:0;
   position:relative;
   left:50%;
   text-align:center;
}
#centeredmenu ul li {
   display:block;
   float:left;
   list-style:none;
   margin:0;
   padding:0;
   position:relative;
   right:50%;
}
#centeredmenu ul li a {
   display:block;
   margin:0 0 0 1px;
   padding:3px 10px;
   background:#ddd;
   color:#000;
   text-decoration:none;
   line-height:1.3em;
}
#horizontal-list li a:hover {
   background:#369;
   color:#fff;
}
#horizontal-list li a.active,
#horizontal-list li a.active:hover {
   color:#fff;
   background:#000;
   font-weight:bold;
}
#jenkins .yui-button.danger button {
   background-color: #d24939;
   color: #3366FF;
   border: 1px solid #be3a2b;
}
#menu-outer {
  height: 40px;
  margin-bottom: 0px;
}

#menu-table {
  display: table;
  margin: 0 auto;
}

ul#horizontal-list {
  min-width: 696px;
  list-style: none;
  padding: 5px;
	}

ul#horizontal-list li {
  display: inline;
  margin: 5px;
	}

</style>
