module LogScan
    class Config
        attr_accessor :vendor

        def initialize
            @vendor = :mstar
        end

        def self.inst
            @inst ||= self.new
        end
    end

    class Rule
        attr_accessor :sample, :regex, :action

        

        COMMON_REX ={ 
            :mstar => '^\s*\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d\d\d\s+\d+\s+\d+\s+\w\s+%s:\s+',
            :qualcomm => '^\s*\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d\d\d\s+\w\/%s\s*\(\s*\d+\):\s+',
        }

        def self.detect_vendor(line)
            puts line
            COMMON_REX.each_pair do |key,value|
                puts "%s=>%s" % [ key, value % '\w+' ]
                if Regexp.compile( value % '\w+' ).match( line )
                     return key
                end
            end

            raise "Can't detect vendor"
        end

        def initialize( tag, regex, sample, block )
            @sample = sample
            puts Config.inst.vendor
            puts COMMON_REX[Config.inst.vendor] % tag + regex + '$'
            @regex = gen_regexp( Config.inst.vendor, tag, regex )
            @action = block
            if test_match( :mstar, tag, regex ).nil? and test_match( :qualcomm, tag, regex ).nil?
                raise "%s can't match %s" % [ @regex.to_s, @sample ]
            end
        end

        def gen_regexp( vendor, tag, regex )
            Regexp.compile( COMMON_REX[vendor] % tag + regex + '$' )
        end

        def test_match(vendor, tag, regex)
            gen_regexp(vendor,tag,regex).match( @sample ).nil?
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

        def rule( tag, regex, sample, &block )
            rules << Rule.new( tag, regex, sample, block )
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
