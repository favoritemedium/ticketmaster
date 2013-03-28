require 'csv'

# Parse a csv file from uTest into title/description pairs that can
# be auto-submitted as tickets, e.g. to Unfuddle.
#
# Class method ParseCsv.fromfile returns an array of hashes.

module UtestAids

  class ParseCsv

    def self.fromfile(filename)
      head = nil
      tickets = []
      CSV.foreach(filename) do |x|
        if head.nil?
          head = x.map { |z| z.chomp }
        else
          title = ""
          desc = []
          x.each_index do |i|
            h = head[i]
            if !x[i].nil?
              y = x[i].chomp
              if h == "Title"
                title = y
              elsif i <= 11
                desc << h+": "+y
              else
                desc << "" << h << "="*h.length << y
              end
            end
          end
          tickets << {:title => title, :description => desc.join("\n")}
        end
      end
      tickets
    end
  end

end
