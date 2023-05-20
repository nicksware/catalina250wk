module Jekyll
  module MarkdownListFilter
    def markdown_list(input, site)
      md_files = []
      source = site.config['source']
      destination = site.config['destination']
      Dir.glob(File.join(source, '**', '*.md')) do |file|
        html_file = file.sub(source, destination).sub('.md', '.html')
        # Append the relative path to the array
        md_files << html_file.sub(destination, '')
      end
      md_files
    end
  end
end

Liquid::Template.register_filter(Jekyll::MarkdownListFilter)
