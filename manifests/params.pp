# == Class nifi::params
#
# This class is meant to be called from nifi.
# It sets variables according to platform.
#
class nifi::params {
  case $::osfamily {
    'RedHat', 'Amazon': {
      $package_name = 'nifi'
      $service_name = 'nifi'
      $package_version = 'present'
      $nifi_conf_dir = '/opt/nifi/conf'
      $custom_properties_file = '/opt/nifi/flow/custom.properties'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
  $nifi_properties ={
    'nifi.flow.configuration.file' => '/opt/nifi/flow/flow.xml.gz',
    'nifi.templates.directory'=> '/opt/nifi/flow/templates',
    'nifi.variable.registry.properties' => '/opt/nifi/flow/custom.properties',
    'nifi.web.http.port' => '8080',
    'nifi.web.https.port' => '8443',
    'nifi.web.http.host' => $::fqdn,
    'nifi.web.https.host' => $::fqdn,
    'nifi.web.http.network.interface_default' => '',
    'nifi.security.user.authorizer' => 'file-provider',
    'nifi.cluster.is.node' => 'false',
  }

}
