module LogScan
    class Rule
        attr_accessor :sample, :regex, :action

        COMMON_REX = '^\s*\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d\d\d\s+\d+\s+\d+\s+\w\s+'

        def initialize( regex, sample, block )
            @sample = sample
            puts COMMON_REX + regex + '$'
            @regex = Regexp.compile( COMMON_REX + regex + '$' )
            @action = block

            if @regex.match( @sample ).nil?
                raise "%s can't match %s" % [ @regex.to_s, @sample ]
            end
        end

        def match( line )
            result = @regex.match(line)
            if result
                 @action.call( result, line )
            end
            result
        end
    end

    module ClassMethods
        def rules
            @rules ||= []
        end

        def rule( regex, sample, &block )
            rules << Rule.new( regex, sample, block )
        end

        def match_line( line )
            cont = true 
            i = 0
            while cont && ( i < rules.length ) do
                if rules[i].match( line )
                    cont = false
                end
    
                i += 1
            end

            !cont
        end
    end

    def self.included(receiver)
        puts "Extend #{receiver}"
        if receiver === Object
            receiver.include(ClassMethods)
        else
            receiver.extend(ClassMethods)
        end
    end
end
