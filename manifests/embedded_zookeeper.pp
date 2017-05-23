define nifi::embedded_zookeeper (
  Array[String] $members =[],
  $client_port = 2181
){

 if ! empty($members) {

   $members_array= $members.map |$index, $member| {
     $real_index = $index + 1
     ["server.${real_index}", "${member}:2888:3888"]
   }
   $zookeeper_members_hash = hash(flatten($members_array))

   #write my id
   $members.each |$index, $member|{
     $real_index=$index+1
     #set zookeeper myid
     # echo $id > .state/zookeeper/myid
     if $::fqdn == $member {
       file {"${::nifi::nifi_conf_dir}/state/":
         ensure => 'directory',
         owner => 'nifi',
         group => 'nifi',
         mode => '0755'
       } ->
       file {"${::nifi::nifi_conf_dir}/state/zookeeper":
         ensure => 'directory',
         owner => 'nifi',
         group => 'nifi',
         mode => '0755'
       } ->
       file {"${::nifi::nifi_conf_dir}/state/zookeeper/myid":
           ensure => 'present',
           content => "$real_index",
           owner => 'nifi',
           group => 'nifi',
           mode => '0644'
         }
     }
   }
 }else {
   $zookeeper_members_hash = {
     "zookeeper.1" => "%"
   }
 }

  file {"${nifi::nifi_conf_dir}/zookeeper.properties":
    owner=>'nifi',
    group => 'nifi',
    mode => '644',
    content => template('nifi/zookeeper.properties.erb')
  }
}