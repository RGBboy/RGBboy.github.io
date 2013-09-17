module Jekyll

  class LessCssFile < StaticFile
    def write(dest)
      # do nothing
    end
  end

# Expects a lessc: key in your _config.yml file with the path to a local less.js/bin/lessc
# Less.js will require node.js to be installed
  class LessJsGenerator < Generator
    safe true
    priority :low
    
    def generate(site)
      src_root = site.config['source']
      dest_root = site.config['destination']
      less_ext = /\.less$/i
      done = false

      raise "Missing 'lessc' path in site configuration" if !site.config['lessc']
      raise "Missing 'less_input_path' path in site configuration" if !site.config['less_input_path']
      raise "Missing 'less_output_path' path in site configuration" if !site.config['less_output_path']

      less_path = site.config['less_input_path']
      css_path = site.config['less_output_path']
      css_dir = File.dirname(css_path)

      FileUtils.mkdir_p(css_dir)

      # static_files have already been filtered against excludes, etc.
      site.static_files.reverse.each do |sf|
        next if not sf.path =~ less_ext

        # puts 'sf.path: ' + sf.path

        # Remove the LESS file so it gets cleaned
        site.static_files.delete(sf)

        if not done

          begin
            command = [site.config['lessc'], 
                       less_path, 
                       css_path
                       ].join(' ')
                   
            puts 'Compiling LESS: ' + command

            `#{command}`

            raise "LESS compilation error" if $?.to_i != 0
          end

          done = true

        end

      end

    end
    
  end
end