# frozen_string_literal: true

require 'kubeclient'
require 'uri'

module KubeClientFactory

  def self.client(api: 'api', version: 'v1', host_url: nil, options: nil)
    full_url = "#{host_url}/#{api}"
    validate_host_url! full_url

    puts "Add client, api: #{api}, version: #{version}, url: #{full_url}"

    @cert_store = OpenSSL::X509::Store.new
    @cert_store.set_default_paths
    add_chained_cert(@cert_store, ENV["KUBE_CA_CERT"])

    auth_options = {
      bearer_token: ENV["KUBE_SERVICE_ACCOUNT_TOKEN"]
    }
    ssl_options = {
      cert_store: @cert_store,
      verify_ssl:  OpenSSL::SSL::VERIFY_PEER
    }

    Kubeclient::Client.new(full_url, version, auth_options: auth_options, ssl_options: ssl_options)
  end

  class << self
    private

    def validate_host_url! host_url
      raise if URI.parse(host_url).host.empty?
    rescue
      puts "Invalid URL " + host_url
      raise("Invalid URL")
    end
  end
end

# Gets the client object to the /api v1 endpoint.
def kubectl_client
  KubeClientFactory.client(host_url: ENV["KUBE_API_URL"], options: nil)
end

def k8s_client_info client
  group    = client.instance_variable_get(:@api_group)
  version  = client.instance_variable_get(:@api_version)
  entities = client.instance_variable_get(:@entities).to_yaml
  "api_group: #{group}, api_version: #{version}, entities: #{entities}"
end
 
# Methods move around between API versions across releases, so search the
# client API objects to find the method we are looking for.
def k8s_client_for_method method_name
  puts "Getting client for method " + method_name
  k8s_clients.find do |client|
    begin
      puts "==========================================================="
      responded    = client.respond_to?(method_name)
      client_info  = k8s_client_info(client)
      support_desc = responded ? "supported" : "NOT supported"
      puts "Method #{method_name} is #{support_desc} for client: #{client_info}"
      responded
    rescue KubeException => e
      raise e unless e.error_code == 404
      false
    end
  end
end

# If more API versions appear, add them here.
# List them in the order that you want them to be searched for methods.
def k8s_clients

  api_url = ENV["KUBE_API_URL"]

  @clients ||= [
    kubectl_client,
    KubeClientFactory.client(api: 'apis/apps', version: 'v1beta2', host_url: api_url),
    KubeClientFactory.client(api: 'apis/apps', version: 'v1beta1', host_url: api_url),
    KubeClientFactory.client(api: 'apis/extensions', version: 'v1beta1', host_url: api_url),
    # OpenShift 3.3 DeploymentConfig
    KubeClientFactory.client(api: 'oapi', version: 'v1', host_url: api_url),
    # OpenShift 3.7 DeploymentConfig
    KubeClientFactory.client(api: 'apis/apps.openshift.io', version: 'v1', host_url: api_url),
  ]
end
 
CERT_RE = /-----BEGIN CERTIFICATE-----\n.*?\n-----END CERTIFICATE-----\n/m

def parse_certs certs
  # fix any mangled namespace
  certs = certs.gsub(/\s+/, "\n")
  certs.gsub! "-----BEGIN\nCERTIFICATE-----", '-----BEGIN CERTIFICATE-----'
  certs.gsub! "-----END\nCERTIFICATE-----", '-----END CERTIFICATE-----'
  certs += "\n" unless certs[-1] == "\n"

  certs.scan(CERT_RE).map do |cert|
    begin
      OpenSSL::X509::Certificate.new cert
    rescue OpenSSL::X509::CertificateError => exn
      raise exn, "Invalid certificate:\n#{cert} (#{exn.message})"
    end
  end
end

# Add a certificate to a given store. If the certificate has more than
# one certificate in its chain, it will be parsed and added to the store
# one by one. This is done because `OpenSSL::X509::Store.new.add_cert`
# adds only the intermediate certificate to the store.
def add_chained_cert store, chained_cert
  parse_certs(chained_cert).each do |cert|
    begin
      store.add_cert cert
    rescue OpenSSL::X509::StoreError => ex
      raise unless ex.message == 'cert already in hash table'
    end
  end
end

method = "get_" + ENV["KUBE_GET_RESOURCE"]
client = k8s_client_for_method(method)
puts "==========================================================="
puts "Acceptable client found for method " + method
puts "   api_group:   " + client.instance_variable_get(:@api_group)
puts "   api_version: " + client.instance_variable_get(:@api_version)
puts "==========================================================="

