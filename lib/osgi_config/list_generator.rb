# coding: utf-8

require "optparse"
require "json"
require "erb"
require "cgi"
require "open-uri"
require "fileutils"

require "osgi_config"


module OsgiConfig

class ListGenerator

  def info(message)
    STDOUT.puts message
    STDOUT.flush
  end
  
  def error(message)
    STDERR.puts message
    STDERR.flush
  end
  
  
  # Escape as HTML
  def eh(any)
    return CGI.escapeHTML(any.to_s)
  end
  
  
  def download_as_file(url, file_name, user, password)
    info "Downloading #{url} as #{file_name}"
    begin
      response_body = open(url,
        {:http_basic_authentication => [user, password]}).read
      open(file_name, 'wb') do |file|
        file.puts response_body
      end
    rescue => e
      error e
      exit 1
    end
  end
  
  
  def download_config_details(base_url, list_dir, user, password)
    list_url = "#{base_url}/system/console/configMgr"
    list_html_file = "#{list_dir}/configMgr.html"
    download_as_file(list_url, list_html_file, user, password)
    list_html = File.open(list_html_file, encoding: 'UTF-8:UTF-8').read
    
    config_lines = list_html.split(/\x0A/).grep(/var configData/)
    if config_lines.nil? || config_lines.empty?
      error "Cannot extract config list"
      exit 1
    end
    
    config_list_json = config_lines[0].chomp.sub(/^[^\{]+/, "").sub(/;$/, "")
    config_list = JSON.parse(config_list_json)
    
    pids = config_list["pids"].sort_by {|pid| pid.values_at("name", "id") }
    pids.each do |pid|
      id = pid["id"]
      info id
      encoded_id = URI.encode(id)
  
      detail_url = "#{list_url}/#{encoded_id}?post=true"
      detail_file = "#{list_dir}/#{encoded_id}.json"
      download_as_file(detail_url, detail_file, user, password)
    end
  end
  
  
  def prepare_list_dir(output_dir, options, started_at)
    list_dir = "#{output_dir}/list"

    if options[:use_local].nil?
      if ::Dir.exist?(list_dir)
        backup_dir = "#{list_dir}_#{started_at.strftime('%Y%m%d-%H%M%S')}"
        ::FileUtils.mv(list_dir, backup_dir)
      end
    
      ::FileUtils.mkdir_p(list_dir)
    else
      list_dir = options[:use_local]
      if !::Dir.exist?(list_dir)
        error "ERROR: #{list_dir} does not exist"
        exit 1
      end
    end
    
    return list_dir
  end
  
  
  def opt_parse(argv)
    opts = {}
    OptionParser.new do |opt|
      begin
        opt.version = OsgiConfig::VERSION
        
        opt.on('-s=AEM_SERVER', '--server',
          'FQDN of AEM server') do |v|
            opts[:server] = v
        end
        
        opt.on('-p=AEM_PORT', '--port',
          'Port number of AEM server') do |v|
            opts[:port] = v
        end
        
        opt.on('-l=DOWNLOAD_DIR', '--use-local',
          'Generates the list with local json files under given directory') do |v|
            opts[:use_local] = v
        end
        
        opt.on('-u=USER:PASSWORD', '--credential',
          'User:Password') do |v|
            opts[:credential] = v
        end
        
        
        opt.parse!(argv)
      rescue => e
        $stderr.puts "ERROR: #{e}.\n#{opt}"
        exit
      end
    end
    
    return opts
  end
  
  
  # main
  def main(argv)
    started_at = Time.new
    base_dir = File.dirname(MODULE_PATH)
    options = opt_parse(argv)
    
    output_dir = "#{base_dir}/out"
    list_dir = prepare_list_dir(output_dir, options, started_at)
    
    # download config jsons
    if options[:server].nil?
      server = "localhost"
    else
      server = options[:server]
    end
    
    if options[:port].nil?
      port = "4502"
    else
      port = options[:port]
    end
    
    if options[:credential].nil?
      user, password = ["admin", "admin"]
    else
      user, password = options[:credential].split(":")
    end
    
    if options[:use_local].nil?
      base_url = "http://#{server}:#{port}"
      download_config_details(base_url, list_dir, user, password)
    end
    
    
    # render the configuration list
    info "Generating config list"
    config_details = []
    Dir.glob("#{list_dir}/*.json") do |json_file|
      info json_file
      json = File.read(json_file)
      config_detail = ::JSON.parse(json)
      config_details.push(config_detail)
    end
    
    template = File.read("#{MODULE_PATH}/osgi_config/config_list.erb")
    rendered = ERB.new(template).result(binding)
    output_html = "#{output_dir}/config_list.html"
    open(output_html, 'wb') do |file|
      file.puts rendered
    end
    
    info "Done. Check #{output_html}."
    
  end # main

end # class ListGenerator

end # module OSGiConfig



###############################################


if $0 == __FILE__
  generator = OsgiConfig::ListGenerator.new
  generator.main(ARGV)
end


# EOF

