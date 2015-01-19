autoload :CSV, 'csv'

module Linecook
  class Parser

    def initialize(source, options = {})
      @field_names = options.fetch(:field_names, nil)

      csv_options = {}
      if field_sep = options[:field_sep]
        csv_options[:col_sep] = field_sep
      end

      if headers = options[:headers]
        csv_options[:headers] = headers
      end

      @csv = CSV.new(source, csv_options)
    end

    def gets
      if row = @csv.gets

        case
        when row.kind_of?(Array)
          row
        when @field_names
          row.fields(*@field_names)
        else
          row.fields
        end

      else
        nil
      end
    end
  end
end
