sample_lines = [
    {
        :line=>"01-04 02:04:22.620   970  1132 D BluetoothAdapterStateMachine: PowerOff process message: 1",
        #:regex=>/^\s*\d\d-\d\d \d\d:\d\d:\d\d:\.\d\d\d\s+\d+\s+\d+\w\s+BluetoothAdapterStateMachine:\w*$/
        :regex=>/^\s*\d\d-\d\d\s+\d\d:\d\d:\d\d\.\d\d\d\s+\d+\s+\d+\s+\w\s+BluetoothAdapterStateMachine:.*$/
    }
]

sample_lines.each do |item|
    if ! ( item[:line] =~ item[:regex] )
        puts "Not match: %s" % item[:line]
    end
end
