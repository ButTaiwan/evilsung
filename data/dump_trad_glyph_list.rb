$table = {}

def add_char key, uni, cid
	unidec = uni.to_i(16)
	
	if (0x4E00..0x9FFF).include?(unidec) # || (0xF900..0xFAFF).include?(unidec) || unidec >= 0x20000
		$table[unidec] = {cn: nil, kr: nil} if !$table.has_key?(unidec)
		$table[unidec][key] = cid
	end
end

def read_map fn, key
	f = File.open(fn, 'r:utf-8')
	f.each { |s|
		uni, cid = s.gsub(/[<>]/, '').split(/\s+/)
		unidec = uni.to_i(16)
		next if !$big5[unidec]
		#$table[unidec][key] = cid if $table.has_key?(unidec)
		add_char(key, uni, cid)
	}
	f.close
end

$big5 = Hash.new(false)
f = File.open('./refs/BIG5.txt', 'r')
f.each { |s|
	s.chomp!
	next if s.length == 0
	next if s[0] == '#'
	b5, uni = s.gsub(/0x/, '').split(/\s+/)
	$big5[uni.to_i(16)] = true
}

read_map('./shserif/utf32-cn.map', :cn)
read_map('./shserif/utf32-kr.map', :kr)

$chars = {}

f = File.open('all_simptable.txt', 'r:utf-8')
f.each { |s|
	s.chomp!
	tmp = s.gsub(/\.cn/, '').split(/\t/)
	tmp.size.times { |i|
		break if i >= 16
		c = tmp[i] != '' ? tmp[i] : tmp[0]
		next if c =~ /\./
		ci = c.ord
		next if !$table.has_key?(ci)
		next if $table[ci][:cn] == $table[ci][:kr]

		$chars[c] = { trads: false, simps: false } if !$chars.has_key?(c)
		$chars[c][:trads] = true if i <= 7 || i == 9
		$chars[c][:simps] = true if i == 8 || i >= 10
	}
}
f.close

# f = File.open('cn_1965_PrintUnified.txt', 'w:utf-8')
# f.puts "# 新字體中在Unicode未分離者，在此字型需要區分"
# $chars.each { |c, v|
# 	f.puts "#{c}\t#{c}.cn" if v[:trads] && v[:simps]
# }
# f.close

f = File.open('tradglyphs.txt', 'w:utf-8')
f.puts "# BOTH"
$chars.sort_by{ |c, v | c }.each { |c, v|
	f.puts "#{c}" if v[:trads] && v[:simps]
}
f.puts "# ONLY TRADS"
$chars.sort_by{ |c, v | c }.each { |c, v|
	f.puts "#{c}" if v[:trads] && !v[:simps]
}
f.close
