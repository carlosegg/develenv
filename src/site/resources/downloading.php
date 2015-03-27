<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="es" lang="es">
  <head>

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>develenv-
   <?php
     $develenvVersion=exec('cat index.html |grep "projectVersion"|sed s:".*\: ":"":g|sed s:"<.*":"":g');
     echo  $develenvVersion;
     $route=htmlspecialchars($_GET["route"]);
     $size=htmlspecialchars($_GET["size"]);
     $component=htmlspecialchars($_GET["component"]);
     $downloadUrl="http://downloads.softwaresano.com/" . $route;


   ?>
</title>
    <style type="text/css" media="all">
      @import url("./css/maven-base.css");
      @import url("./css/maven-theme.css");
      @import url("./css/site.css");
    </style>
    <link rel="stylesheet" href="./css/print.css" type="text/css" media="print" />
    <meta name="author" content="Carlos Enrique Gómez Gómez" />
    <meta name="Date-Revision-yyyymmdd" content="20110227" />
    <meta http-equiv="Content-Language" content="es" />
    <?php 
     echo '<meta http-equiv="refresh" content="2;url=' .  $downloadUrl . '"/>';
    ?>
	
    
<script type="text/javascript">
  document.domain="softwaresano.com";
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-8116005-4']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
<script type="text/javascript">
   function cargaTotal(){
          setTimeout('window.location="<?php echo $downloadUrl?>"',5000);
   }

</script>


</head>
  <body class="composite" >
  <!-- body class="composite" onload="cargaTotal()" -->
   <!--iframe width="0" height="0" frameborder="0" src="<?php echo $downloadUrl?>"></iframe -->
    <div id="banner">
                  <a href="http://www.softwaresano.com" id="bannerLeft">
                                                <script type="text/javascript" src="http://www.softwaresano.com/widgets/head.php"></script><script type="text/javascript" src="/widgets/head.php"></script>
                </a>

                    <div class="clear">
        <hr/>
      </div>
    </div>
    <div id="breadcrumbs">
            
        
                <div class="xleft">
        <span id="publishDate">Publicado el: <?php
        $publishDate=exec('cat index.html |grep "Publicado el:"|sed s:".*\: ":"":g|sed s:"<.*":"":g');
        echo  $publishDate;?></span>
                  &nbsp;| <span id="projectVersion">Versión:<?php
echo $develenvVersion;
?></span>
                      </div>
            <div class="xright">                    <a href="team-list.html" title="Contacto">Contacto</a>
            |
                        <a href="http://develenv.softwaresano.com" class="externalLink" title="Blog">Blog</a>
            |
                        <a href="maven-repositories.html" title="Repositorios de maven">Repositorios de maven</a>
            |
                        <a href="/sites/" class="externalLink" title="Sites">Sites</a>
            |
                        <a href="/jenkins/" class="externalLink" title="Jenkins">Jenkins</a>
            |
                        <a href="/sonar" class="externalLink" title="Sonar">Sonar</a>
            |
                        <a href="/nexus" class="externalLink" title="Nexus">Nexus</a>
            |
                        <a href="/selenium" class="externalLink" title="Selenium">Selenium</a>
              
        
      </div>
      <div class="clear">
        <hr/>
      </div>
    </div>
    <div id="leftColumn">
      <div id="navcolumn">
             
        
                                <h5>Descargas</h5>
                  <ul>
                  <li class="none">
                          <a href="downloads/releases.html" title="Releases">Releases</a>
            </li>
		  <li class="none">
                          <a href="virtualMachines.html" title="Máquina Virtual con develenv">Máquina Virtual con develenv</a>
            </li>
                  <li class="none">
                          <a href="changes-report.html" title="Release Notes">Release Notes</a>
            </li>
                  <li class="none">
                          <a href="license.html" title="Licencia">Licencia</a>
            </li>
          </ul>
                       <h5>develenv</h5>
                  <ul>
                  <li class="none">
            <strong>Introducción</strong>
          </li>
                  <li class="none">
                          <a href="development.html" title="Compilación">Compilación</a>
            </li>
                  <li class="none">
                          <a href="installation.html" title="Instalación">Instalación</a>
            </li>
                  <li class="none">
                          <a href="administrationGuide.html" title="Manual del administrador">Manual del administrador</a>
            </li>
                  <li class="none">
                          <a href="plugins.html" title="Plugins">Plugins</a>
            </li>
                  <li class="none">
                          <a href="samples.html" title="Ejemplos">Ejemplos</a>
            </li>
                  <li class="none">
                          <a href="improvements.html" title="Futuros desarrollos">Futuros desarrollos</a>
            </li>
          </ul>
                       <h5>Desarrollo</h5>
                  <ul>
                  <li class="none">
                          <a href="source-repository.html" title="Fuentes">Fuentes</a>
            </li>
                  <li class="none">
                          <a href="integration.html" title="Integración continua">Integración continua</a>
            </li>
                  <li class="none">
                          <a href="changelog.html" title="Control de cambios">Control de cambios</a>
            </li>
                  <li class="none">
                          <a href="improvements.html" title="Futuras Mejoras">Futuras Mejoras</a>
            </li>
          </ul>
                       <h5>Documentación del proyecto</h5>
                  <ul>
                                                                                                                                                                                                                                                                                    <li class="expanded">
                          <a href="project-info.html" title="Información del proyecto">Información del proyecto</a>
                    <ul>
                      <li class="none">
            <strong>Bienvenido a</strong>
          </li>
                      <li class="none">
                          <a href="integration.html" title="Continuous Integration">Continuous Integration</a>
            </li>
                      <li class="none">
                          <a href="dependencies.html" title="Dependencies">Dependencies</a>
            </li>
                      <li class="none">
                          <a href="dependency-convergence.html" title="Dependency Convergence">Dependency Convergence</a>
            </li>
                      <li class="none">
                          <a href="issue-tracking.html" title="Issue Tracking">Issue Tracking</a>
            </li>
                      <li class="none">
                          <a href="license.html" title="Licencia">Licencia</a>
            </li>
                      <li class="none">
                          <a href="mail-lists.html" title="Mailing Lists">Mailing Lists</a>
            </li>
                      <li class="none">
                          <a href="plugin-management.html" title="Plugin Management">Plugin Management</a>
            </li>
                      <li class="none">
                          <a href="plugins.html" title="Project Plugins">Project Plugins</a>
            </li>
                      <li class="none">
                          <a href="project-summary.html" title="Project Summary">Project Summary</a>
            </li>
                      <li class="none">
                          <a href="team-list.html" title="Project Team">Project Team</a>
            </li>
                      <li class="none">
                          <a href="source-repository.html" title="Source Repository">Source Repository</a>
            </li>
              </ul>
        </li>
                                                                                                                          <li class="collapsed">
                          <a href="project-reports.html" title="Informes del proyecto">Informes del proyecto</a>
                  </li>
          </ul>
                                 <h5>Módulos</h5>
                  <ul>
                  <li class="none">
                          <a href="hudson/index.html" title="Jenkins">Jenkins</a>
            </li>
                  <li class="none">
                          <a href="nexus/index.html" title="Nexus">Nexus</a>
            </li>
                  <li class="none">
                          <a href="sonar/index.html" title="Sonar">Sonar</a>
            </li>
                  <li class="none">
                          <a href="developer/index.html" title="Developer">Developer</a>
            </li>
          </ul>
                                                                                                                   <a href="http://www.softwaresano.com/" title="pimpam" class="poweredBy">
        <script type="text/javascript" src="http://www.softwaresano.com/widgets/builtBy.php"></script><script type="text/javascript" src="/widgets/builtBy.php"></script>
      </a>
                       
        
            </div>
    </div>
    <div id="bodyColumn">
      <div id="contentBox">
        <!-- Generado con el arquetipo: standalone-archetype --><!-- http://pimpam.googlecode.com --><div class="section"><h2>Descargando <?php echo $component;
if ( $size != "" ){
     echo "(" . $size . "B)";
  }


?><a name="develenv"></a></h2><!-- ~~~~~~~~~~ --><p>Descargando <a href="<?php echo $downloadUrl?>"><b><?php 
echo $component;

?></b></a><?php 
if ( $size != "" ){
     echo "(" . $size . "B)";
  }
?>. <p>Si en unos instantes no empieza la descarga pulsa <a target="_blank" href="<?php echo $downloadUrl?>">aqu&#xed;</a>.(NOTA: El inicio de la descarga puede retrasarse si se accede  a trav&eacute;s de un proxy que revisa el contenido de la descarga)</p><p>Una vez descargado <a href="<?php echo $downloadUrl?>"><b><?php echo $component 
?></b> </a>se han de seguir los siguientes pasos:</p><!-- ~~~~~~~~~~~~~~ --><ul>
<li><a href="./downloadOk.php?artifact=<?php
echo $component;
?>">Comprobar integridad de la descarga</a></li>
<li><a href="./installation.html"> Instalar <b>develenv</b></a></li><li><a class="externalLink" href="http://code.google.com/p/develenv/wiki/newProject"> Crear del primer proyecto con <b>develenv</b></a></li></ul><div class="section"><h3>Documentaci&#xf3;n<a name="Documentacin"></a></h3><!-- ~~~~~~~~~~~~~~ --><ul><li><a href="./developer/index.html"> Entorno para el desarrollador</a></li><li><a href="./useSample.html"> Gu&#xed;a de desarrollo de un proyecto java</a></li><li><a href="./sonar/index.html"> M&#xe9;tricas con sonar</a></li><li><a href="./hudson/index.html"> Integraci&#xf3;n cont&#xed;nua con Jenkins</a></li><li><a href="./nexus/index.html"> Servidor de componentes java con nexus</a></li><li><a href="./samples.html"> Ejemplos de aplicaciones que utilizan <b>develenv</b></a></li><li><a href="./administrationGuide.html"> Gu&#xed;a del administrador</a></li></ul></div><div class="section"><h3><a href="./changes-report.html">Releases</a><a name="Releases"></a></h3><!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --><p>En las <a href="./changes-report.html">releases notes</a> se describen las funcionalidades que implementan las diferentes versiones de <i>develenv</i>. Para descargarse una release pulsa <a href="./downloads/releases.html">aqu&#xed;</a>, y <a href="./downloads/snapshots.html">aqu&#xed;</a> para descargarse la &#xfa;ltima snapshot.</p></div></div>
      </div>
    </div>
    <div class="clear">
      <hr/>
    </div>
    <div id="footer">
      <div class="xright">Copyright &#169;                    2011
                        <a href="http://develenv.softwaresano.com">SoftwareSano</a>.
            All Rights Reserved.      
        
      </div>
      <div class="clear">
        <hr/>
      </div>
    </div>
  <script type="text/javascript" src="http://www.softwaresano.com/widgets/foot.php"></script><script type="text/javascript" src="/widgets/foot.php"></script><script type="text/javascript" src="http://www.softwaresano.com/widgets/foot.php"></script><script type="text/javascript" src="/widgets/foot.php"></script>
</body>
</html>
