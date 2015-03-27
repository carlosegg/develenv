##################################################################################
# Puppet profile for install develenv                                            #
#--------------------------------------------------------------------------------#
# Review administratorId, password, profile and develenv_version variables       #
# and apply the profile with:                                                    #
# sudo puppet apply manifests/develenv.pp --modulepath modules --debug --verbose #
##################################################################################

# Configuration profile
#----------------------
#Select a profile (softwaresanoProfile, tidProfile, googleProfile,...)
$tidProfile="http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/tid.properties"
$softwaresanoProfile="http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/softwaresano.properties"
$googleProfile="http://develenv.googlecode.com/svn/trunk/develenv/src/main/filters/google.properties"

#---------------------------------------------------------
# Develenv repository section
# Select repository where develenv is available.
#---------------------------------------------------------
#Select yum repository for install develenv(develenvWithVagrant, develenvInTid, develenvProduction)
$develenvInTid="http://ci-pipeline.hi.inet/develenv/rpms"
# For development develenv in vagrant use
$develenvWithVagrant="file:///vagrant/rpmbuild/RPMS"
#Repo with develenv production repo
$develenvProduction="http://develenvms.softwaresano.com/public/downloads/repos/develenv"
$javaurlrepo = "http://cdn-jenkins-server.hi.inet/develenv/repositories/jdk-rpms/"


#-------------------------------------------------------------------------------
# Review administratorId, password, profile and develenv_version variables
#-------------------------------------------------------------------------------
class { 'develenv':
   administrator    => "develenv",
   develenv_version => 'installed',           # 'installed','latest','25-6557'
   develenvrepo     => $develenvProduction,   # $develenvProduction, $develenvWithVagrant, $develenvInTid
   profile          => $softwaresanoProfile,  # $tidProfile,$softwaresanoProfile,$googleProfile
   password         => "develenv",
}
