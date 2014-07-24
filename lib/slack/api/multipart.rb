require "stringio"

module Slack
  module Api
    class Multipart
      def initialize(args, boundary=nil)
        @boundary = boundary || "boundary"
        @io = []
        args.each do |name,value|
          filename = nil
          if value.kind_of?(Hash)
            filename = File.basename(value['filepath'])
          end


          @io.push(
            StringIO.new([boundary_line, content_disposition(name, filename), "", ""].join(new_line))
          )

          if filename.nil?
            @io.push(StringIO.new("#{value}"+new_line))
          else
            @io.push(File.open(value['filepath'], 'rb'))
          end

        end

        @io.push(
          StringIO.new([boundary_last, ""].join(new_line))
        )

        @size = 0
        @io.each do |i|
          @size += i.size
        end
      end 

      def content_type
        "multipart/form-data; boundary=#{@boundary}"
      end

      def boundary_line
        "--#{@boundary}"
      end

      def boundary_last
        "--#{@boundary}--"
      end

      def content_disposition(name, filename=nil)
        "Content-Disposition: form-data; name=\"#{name}\"" + (filename.nil? ? "" : "; filename=\"#{filename}\"")
      end

      def new_line
        "\r\n"
      end

      def read(len=nil, buf=nil)
       if @io[0].eof?
         @io.shift
       end

       if @io.length == 0
         return nil
       end

       return @io[0].read(len, buf)
      end

      def size
        @size
      end

      def eof?
        @io.length == 0 ? true : false
      end
    end
  end
end
