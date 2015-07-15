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
            :mstar => ['^\s*\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d\d\d\s+\d+\s+\d+\s+\w+\s+',':\s+'],
            :x60 => ['^\s*\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d\d\d\s+\w\/','\(\s*\d+\):\s+' ],
            :max70 =>['^\s*\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d\d\d\s+\d+\s+\d+\s+\w\s+',':\s*'],
        }

        def self.detect_vendor(line)
            #puts line
            COMMON_REX.each_pair do |key,value|
                #puts "%s=>%s" % [ key, value[0] ]
                if Regexp.compile( value[0] ).match( line )
                    #puts "Detect vendor result: #{key}"
                    return key
                end
            end

            raise "Can't detect vendor"
        end

        def initialize( tag, regex, sample, block )
            @sample = sample
            #@regex = gen_regexp( Config.inst.vendor, tag, regex )
            @regex = regex
            @tag = tag
            @block = block
            @action = block
            if !test_match( tag, regex )
                raise "<<%s>> can't match <<%s>>" % [ @regex.to_s, @sample ]
            end
        end

        def gen_regexp( vendor, tag, regex )
            #puts "===<<"+COMMON_REX[vendor][0] + tag + COMMON_REX[vendor][1] + regex + '$'+">>===="
            Regexp.compile( COMMON_REX[vendor][0] + tag + COMMON_REX[vendor][1] + regex + '$' )
        end

        def dump_regexp
            COMMON_REX.each_pair do |vendor,value|
                puts "<<"+COMMON_REX[vendor][0] + @tag + COMMON_REX[vendor][1] + @regex + '$'+">>"
            end
        end

        def test_match(tag, regex)
            COMMON_REX.each_pair do |key,value|
                if gen_regexp(key,tag,regex).match( @sample )
                    return true
                end
            end

            false
        end

        def match( line )
            @regexp ||= gen_regexp( Config::inst::vendor, @tag, @regex )
            result = @regexp.match(line)
            if result
                 @action.call( result, line )
            end
            result
        rescue => ex
            $stderr.puts "+++++++++++++===============[#{line}]"
            raise ex
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

        def dump
            rules.each do |r|
                r.dump_regexp
            end
        end
    end

    def self.included(receiver)
        #puts "Extend #{receiver}"
        if receiver === Object
            receiver.include(ClassMethods)
        else
            receiver.extend(ClassMethods)
        end
    end
end
