#!/usr/bin/env ruby
 
require 'find'
filename = 'info.plist'
exp = /(CFBundleVersion.*[\s].*>)(\d+)(<.*)/
buffer = File.new(filename,'r').read
if buffer
    newBuild = ((exp.match(buffer)[2].to_i)+1).to_s
    buffer = buffer.sub(exp,'\1'+newBuild+'\3')
    File.open(filename,'w') {|fw| fw.write(buffer)}
end