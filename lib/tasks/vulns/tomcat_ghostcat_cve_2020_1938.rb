module Intrigue
  module Task
  class TomcatGhostcatCve20201938 < BaseTask
  
    def self.metadata
      {
        :name => "vuln/tomcat_ghostcat_cve_2020_1938",
        :pretty_name => "Vuln - Tomcat Ghostcat",
        :identifiers => [
          { "cve" =>  "CVE-2020-1938" }
        ],
        :authors => ["jcran", "fatal0"],
        :description => "When using the Apache JServ Protocol (AJP), care must be taken when trusting incoming connections to Apache Tomcat. Tomcat treats AJP connections as having higher trust than, for example, a similar HTTP connection. If such connections are available to an attacker, they can be exploited in ways that may be surprising. In Apache Tomcat 9.0.0.M1 to 9.0.0.30, 8.5.0 to 8.5.50 and 7.0.0 to 7.0.99, Tomcat shipped with an AJP Connector enabled by default that listened on all configured IP addresses. It was expected (and recommended in the security guide) that this Connector would be disabled if not required.",
        :references => [
          "https://github.com/fatal0/tomcat-cve-2020-1938-check/blob/master/tomcat-cve-2020-1938-check.go",
        ],
        :type => "vuln_check",
        :passive => false,
        :allowed_types => ["IpAddress", "NetworkService"],
        :example_entities => [ {"type" => "IpAddress", "details" => {"name" => "1.1.1.1"}} ],
        :allowed_options => [  ],
        :created_types => []
      }
    end
  
    ## Default method, subclasses must override this
    def run
      super
  
      if @entity.kind_of? Intrigue::Entity::IpAddress
        ip_address = _get_entity_name
        port = 8009
      elsif @entity.kind_of? Intrigue::Entity::NetworkService
        ip_address = _get_entity_detail("ip_address") || _get_entity_name.split(":").first
        port = _get_entity_detail("port") || _get_entity_name.split(":").last
      end
    
      begin

        # run the exploit 
        command_string = "tomcat-cve-2020-1938-check -h #{ip_address} -p #{port}"

        output = _unsafe_system(command_string).strip
        _log "Output:\n#{output}"

        # test the response
        if output.strip =~ /is vulnerable/
          # create an issue 
          _create_linked_issue "vulnerability_tomcat_ghostcat_cve_2020_1938", {
            proof: output.strip
          }
        end 

      end
  
    end
  
  end
  end
  end
  