require 'sshkit/dsl'
require 'highline/import'
require 'socket'
require 'timeout'

class SnmpdConfig < CloudstackNagios::Base

  desc "check", "check if snmpd is configured on virtual routers"
  def check
       hosts = routers.map {|router| router['linklocalip']}
       on hosts, in: :sequence, wait: 5 do
          Timeout::timeout(1) do
               begin
                  socket = TCPSocket.new("#{host}", "161")
                  socket.close
                    puts "port is open"
                    return true
                  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
                    puts "port is closed"
                    return false
                  end
               end
       end
  end

  desc "enable", "enable snmpd configuration on virtual routers"
  def enable
        say 'Collecting all routers from cloudstack..', :yellow
  	hosts = routers.map do |router|
          unless router['linklocalip'] == ''
            host = SSHKit::Host.new("root@#{router['linklocalip']}")
            host.ssh_options = sshoptions
            host.port = 3922
          end
          host
        end
        say 'connect to routers and execute commands...', :yellow
  	on hosts[0], in: :sequence do
          begin 
            execute 'apt-get', 'update'
            execute 'apt-get', '-y', 'install', 'snmpd'
            upload! File.join(File.dirname(__FILE__), '..', 'files', 'snmpd.conf'), '/etc/snmpd.conf'
            execute 'service', 'snmpd', 'restart'
            execute 'iptables', '-A INPUT -p udp -m udp --dport 161 -j ACCEPT'
          rescue 
            say 'configuration failed!', :red
	  end
	end
  end

  no_commands do

        def sshoptions
          {
            timeout: 5,
            keys: %w(/var/lib/cloud/management/.ssh/id_rsa),
            auth_methods: %w(publickey)
          }
        end

  	def snmp_hosts(host_names)
  		hosts = host_names.map do |host_name|
				host = SSHKit::Host.new("root@#{host_name}")
				host
			end
		end

	end

end
