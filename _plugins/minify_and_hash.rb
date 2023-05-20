require 'base64'
require 'cssminify'
require 'htmlcompressor'
require 'json'
require 'nokogiri'
require 'openssl'
require 'uglifier'
require 'uri'

Jekyll::Hooks.register :site, :post_write do |site|
  compressor = HtmlCompressor::Compressor.new
  uglifier = Uglifier.new(harmony: true)

  # Process non-HTML files first
  Dir.glob(File.join(site.dest, '**', '*.{css,js}')).each do |file|
    next if File.basename(file).start_with?('.')

    content = File.read(file)

    case File.extname(file)
    when '.css'
      # Minify the CSS
      content = CSSminify.compress(content)

      # Write back the minified content
      File.write(file, content)
    when '.js'
      # Minify the JavaScript
      content = uglifier.compile(content)

      # Write back the minified content
      File.write(file, content)

      # If the file is the service worker script, calculate the SRI hash and write it to a file
      if File.basename(file) == 'sw.js'
        digest = OpenSSL::Digest::SHA384.new
        binary_content = File.binread(file)
        utf8_content = binary_content.force_encoding('UTF-8')
        hash = digest.digest(utf8_content)
        sri_hash = Base64.strict_encode64(hash)
        File.write("#{site.dest}/sw_sri.json", {sri: "sha384-#{sri_hash}"}.to_json)
      end
    end
  end

  # Now process HTML files
  Dir.glob(File.join(site.dest, '**', '*.html')).each do |file|
    next if File.basename(file).start_with?('.')

    content = File.read(file)

    # Parse the HTML document with Nokogiri
    doc = Nokogiri::HTML(content)

    # Find all script and link tags with the `sri_tag` attribute
    doc.css('script[sri_tag],link[sri_tag]').each do |node|
      # Read the referenced file's content and calculate its digest
      ref_file = File.join(site.dest, URI(node['src'] || node['href']).path)

      # Check if file exists
      if File.exists?(ref_file)
        # Read file content
        ref_content = File.read(ref_file)

        # Check file content
        if !ref_content.empty?
          # Compute and log hash
          digest = Digest::SHA384.base64digest(ref_content)

          # Set the integrity attribute
          node['integrity'] = "sha384-#{digest}"

          # Remove the `sri_tag` attribute
          node.remove_attribute('sri_tag')
        end
      end
    end

    # Serialize the updated HTML document back to a string
    content = doc.to_html

    # Minify the HTML
    content = compressor.compress(content)

    # Write back the minified content
    File.write(file, content)
  end
end
