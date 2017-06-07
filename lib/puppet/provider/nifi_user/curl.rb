Puppet::Type.type(:nifi_user).provide(:curl) do
  require 'json'
  require 'erb'

  #check curl command exists
  confine :true => begin
    system("curl -V")
  end

  initvars

  commands :curl => 'curl'
  #commands :java  => 'java'
  mk_resource_methods


  def exists?
      existing_user = get_user(@resource[:name])
      ! existing_user.nil?
  end

  def get_user(identity)
    #ver=java('-version')
    #puts("java version: #{ver}")
    #curl -X GET api_url/tenants/search-result?q=user -H 'cache-control: no-cache'
    # example response
    #{
    # "users": [
    #   {
    #     "revision": {
    #   "version": 0
    # },
    #   "id": "65a6839c-015c-1000-ffff-ffffee0e468c",
    #   "permissions": {
    #   "canRead": true,
    # "canWrite": true
    # },
    #   "component": {
    #   "id": "65a6839c-015c-1000-ffff-ffffee0e468c",
    #   "identity": "username"
    # }
    # }
    # ],
    #   "userGroups": []
    # }
    #

    search_command = ['-k', '-X', 'GET', '--cert', @resource[:auth_cert_path], '--key', @resource[:auth_cert_key_path] , "#{@resource[:api_url]}/tenants/search-results?q=#{@resource[:name]}"]
    puts("search command #{search_command}")
    search_response = curl(search_command)
    #puts "search response = #{search_response}"
    response_json = JSON.parse(search_response)
    found_user = response_json['users'].select do | user |
      #puts user.to_json
      user['component']['identity'] == identity
    end
    #puts("found user #{found_user}")
    found_user[0]
  end

  def create_user
    #Example post
    # {
    #   "revision": {
    #   "clientId": "value",
    #   "version": 0,
    #   "lastModifier": "value"
    # },
    #   "id": "value",
    #   "uri": "value",
    #   "position": {
    #   "x": 0.0,
    #   "y": 0.0
    # },
    #   "permissions": {
    #   "canRead": true,
    # "canWrite": true
    # },
    #   "bulletins": [{
    #                   "id": 0,
    #   "groupId": "value",
    #   "sourceId": "value",
    #   "timestamp": "value",
    #   "nodeAddress": "value",
    #   "canRead": true,
    # "bulletin": {…}
    # }],
    #   "component": {
    #   "id": "value",
    #   "parentGroupId": "value",
    #   "position": {…},
    #   "identity": "value",
    #   "userGroups": [{…}],
    #   "accessPolicies": [{…}]
    # }
    # }
    puts("###########create user")
    username = @resource[:name]
    req_json = %Q{
      {
        "revision": {
          "version": 0,
        },
        "id": null,
        "uri": null,
        "position": {
          "x": 0.0,
          "y": 0.0
        },
        "permissions": {
          "canRead": true,
          "canWrite": true
        },
        "component": {
          "id": null,
          "parentGroupId": null,
          "identity": "#{username}",
          "userGroups": [],
          "accessPolicies": []
        }
      }
    }
    #puts "request_json :#{req_json}"
    curl(['-k', '-X', 'POST', '--cert', resource[:auth_cert_path], '--key', @resource[:auth_cert_key_path], "#{@resource[:api_url]}/tenants/users"])
  end


  def delete_user
    exisiting_user = get_user(@resource[:name])
    if ! exisiting_user.nil?
      user_id = exisiting_user['id']
      delete_request_url= "#{@resource[:api_url]}/tenants/users/#{user_id}"
      delete_response= curl(['-k', '-X', 'DELETE', '--cert', @resource[:auth_cert_path], '--key', @resource[:auth_cert_key_path], delete_request_url])
      #puts "Delete user response: #{delete_response}"
      if delete_response
        response_json = JSON.parse(delete_response)
        response_code = response_json['status']
        puts "Delete response code : #{response_code}"
      end
    end
  end

  def create
    create_user
    @property_hash[:ensure] = :present
    exists? ? (return true) : (return false)
  end

  def destroy
    delete_user
    @property_hash.clear
    still_there = exists?
    still_there ? (return false) :(return true)
  end
end