require 'nokogiri'

module Jekyll
  module NavbarFilter
    def navbar(input)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      headings = doc.css('h1, h2, h3, h4, h5, h6')

      # Create a new empty array for the list items
      list_items = []

      # For each heading, create a list item with a link to the heading
      headings.each do |heading|
        if heading[:id]
          list_items << "<li><a href=\"##{heading[:id]}\">#{heading.text}</a></li>"
        end
      end

      # Return the navigation bar as an unordered list
      "<nav><ul>#{list_items.join}</ul></nav>"
    end
  end
end

Liquid::Template.register_filter(Jekyll::NavbarFilter)
