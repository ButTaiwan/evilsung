require './common.rb'

def to_glyphname str
	uni, post = str.split(/\./)
	udec = uni.ord
	cname = sprintf(udec <= 0xffff ? 'uni%04X' : 'u%05X', udec)  + (post ? '.' + post : '')
	cname
end

def is_cnset n
	n == 8 || n >= 10
end



$glyphs = {}
$refs = Hash.new(false)

$gsubs = {}
$simptables.each { |k, v| $gsubs[k] = [] }

loadfile('all_simptable.txt') { |tmp|
	gntrad = to_glyphname(tmp[0])

	tmp.each_with_index { |w, i|
		next if w == ''

		tag = $simptables.keys[i]

		uni, post = w.split(/\./)
		udec = uni.ord
		$glyphs[w] = nil
		$refs[w] = "#{tmp[0]}(#{tag})" if !$refs[w]

		if i > 0 && w != tmp[0]
			gnsimp = to_glyphname(w)
			next if is_cnset(i) && gntrad + '.cn' == gnsimp
			$gsubs[tag] << "sub #{gntrad} by #{gnsimp};" 
		end
		#p w if (i == 8 || i >= 10) && $cnstyles.has_key?(w)
	}
}

#p $glyphs.size


# Load Source Han Serif CID Mappings
$shs_cn = {}
$shs_kr = {}
$shs_tw = {}
loadfile('./shserif/utf32-cn.map') { |uni, cid|
	$shs_cn[uni[1..8].to_i(16).chr('utf-8')] = cid.to_i
}
loadfile('./shserif/utf32-kr.map') { |uni, cid|
	$shs_kr[uni[1..8].to_i(16).chr('utf-8')] = cid.to_i
}
loadfile('./shserif/utf32-tw.map') { |uni, cid|
	$shs_tw[uni[1..8].to_i(16).chr('utf-8')] = cid.to_i
}

# 強制指定KR字符者
loadfile('tradglyphs.txt') { |s, x|
	next if !$glyphs.has_key?(s)
	$glyphs[s] = {mode: 'shs_kr', cid: $shs_kr[s]}
}

# 強制指定CN字符 (有.cn對應字符者)
loadfile('./simptables/cn_1965_PrintUnified.txt') { |ct, cs|
	next if !$glyphs.has_key?(ct)
	$glyphs[cs] = {mode: 'shs_cn', cid: $shs_cn[ct]}
	#$cnstyles[ct] = cs
}

# 從思源宋體裡找出其他可用的字符 (因字形相同，一律從CN取)
# 但標點採用TW字符
$glyphs.each { |gn, g|
	next if g
	next if gn =~ /\./

	if !is_han?(gn.ord) && $shs_tw.has_key?(gn)
		$glyphs[gn] = {mode: 'shs_tw', cid: $shs_tw[gn]}
	elsif $shs_cn.has_key?(gn)
		$glyphs[gn] = {mode: 'shs_u', cid: $shs_cn[gn]}
	end
}

# 字符改名列表 (跟舊版比較)
$renamelist = Hash.new(false)
loadfile('./adjustment/oldfont_glyph_renames.txt') { |newgn, oldgn| $renamelist[oldgn] = newgn }

# 從2019舊版.glyphs找出可用的字符
$copylist_olds = []
loadfile('./adjustment/oldfont_glyphlist.txt') { |gn, cgn, uni, char|
	#$copylist_olds << gn if uni && !(0x3400..0x9FFF).include?(dec) && !(0xF900..0xFAFF).include?(dec) && dec < 0x20000
	newgn = $renamelist[cgn] || cgn
	dec = uni && uni != '' ? uni.to_i(16) : nil
	if $glyphs.has_key?(newgn)
		next if $glyphs[newgn]
		$glyphs[newgn] = {mode: 'old', oldgn: gn}
	elsif uni && is_han?(dec) #!(0x3400..0x9FFF).include?(dec) && !(0xF900..0xFAFF).include?(dec) && dec < 0x20000
		$copylist_olds << {oldgn: gn, newgn: gn}
	#elsif gn =~ /\./
	#	puts "#{gn}\t#{cgn}"
	end
}

# 剩下還是找不到的是需要新建的字符
$glyphs.each { |gn, g|
	next if g
	$glyphs[gn] = {mode: 'custom', ref: $refs[gn]}
}

# 輸出總字表 (漢字部分)
f = File.open('dump_ideo_glyph_list.txt', 'w:utf-8')
$glyphs.sort_by{ |gn, g| gn }.each { |gn, g|
	f.puts "#{gn}\t#{g[:mode]}\t#{g[:cid]}\t#{g[:oldgn]}\t#{g[:ref]}"
}
f.close

# 生成 Glyphs 用檔案 (複製用字符列表、更改字符名稱用的python script等)
#fsc = File.open('working/glyphs_shs_copylist.txt', 'w:utf-8')
fsa1 = File.open('working/afdko_shs_mergefile_subset.txt', 'w:utf-8')
fsa2 = File.open('working/afdko_shs_mergefile_rename.txt', 'w:utf-8')
fsc = File.open('working/glyphs_shs_copylist.txt', 'w:utf-8')
#fsr = File.open('working/glyphs_shs_renamelist.txt', 'w:utf-8')
fgc = File.open('working/glyphs_old_copylist.txt', 'w:utf-8')
fgn = File.open('working/glyphs_old_glyphlist.txt', 'w:utf-8')
fgr = File.open('working/glyphs_old_renamelist.txt', 'w:utf-8')
fcs = File.open('working/glyphs_custom_list.txt', 'w:utf-8')
fcn = File.open('working/glyphs_custom_notes.txt', 'w:utf-8')

fsa1.puts "mergefonts"
fsa1.puts "0\t0"
fsa2.puts "mergefonts"
fsa2.puts ".notdef\t.notdef"

$glyphs.sort_by{ |cgn, g| cgn }.each { |cgn, g|
	if g[:mode] =~ /^shs_/
		#cidgn = 'cid' + sprintf('%05d', g[:cid])
		gn = to_glyphname(cgn)
		fsa1.puts "#{g[:cid]}\t#{g[:cid]}"
		fsa2.puts "#{gn}\tcid#{g[:cid]}"
		fsc.puts gn
		#fsr.puts "font.glyphs['#{cidgn}'].name = '#{gn}'"
	elsif g[:mode] == 'old'
		gn = to_glyphname(cgn)
		fgc.puts g[:oldgn]
		fgn.puts gn
		fgr.puts "font.glyphs['#{g[:oldgn]}'].name = '#{gn}'" if g[:oldgn] != gn
	elsif g[:mode] == 'custom'
		gn = to_glyphname(cgn)
		fcs.puts gn
		fcn.puts "#{gn}\t#{cgn}\t#{g[:ref]}"
	end
}
fsa1.close
fsa2.close
fsc.close
#fsr.close
fgn.close
fcs.close
fcn.close

$copylist_olds.each { |g|
	fgc.puts g[:oldgn]
	fgr.puts "font.glyphs['#{g[:oldgn]}'].name = '#{g[:newgn]}';" if g[:oldgn] != g[:newgn]
}
fgc.close
fgr.close


$extg = {}
loadfile('./adjustment/extG_codemap.txt') { |cgn, extg| $extg[cgn] = extg.ord.to_s(16).upcase }

feg = File.open('working/glyphs_assign_extg_unicodes.txt', 'w:utf-8')
$extg.each { |cgn, uni|
	gn = to_glyphname(cgn)
	feg.puts "font.glyphs['#{gn}'].unicode = '#{uni}'"
}
feg.close

puts "    SHS: " + ($glyphs.select{ |cgn, g| g[:mode] =~ /^shs_/ }).size.to_s
puts "      - kr: " + ($glyphs.select{ |cgn, g| g[:mode] =~ /^shs_kr/ }).size.to_s
puts "      - cn: " + ($glyphs.select{ |cgn, g| g[:mode] =~ /^shs_cn/ }).size.to_s
puts "      - tw: " + ($glyphs.select{ |cgn, g| g[:mode] =~ /^shs_tw/ }).size.to_s
puts "   - other: " + ($glyphs.select{ |cgn, g| g[:mode] =~ /^shs_u/ }).size.to_s
puts "    OLD: " + ($glyphs.select{ |cgn, g| g[:mode] == 'old'}).size.to_s + $copylist_olds.size.to_s
puts " - existed: " + ($glyphs.select{ |cgn, g| g[:mode] == 'old'}).size.to_s
puts " - symbols: " + $copylist_olds.size.to_s
puts " Cutsom: " + ($glyphs.select{ |cgn, g| g[:mode] == 'custom'}).size.to_s
puts "  Total: " + ($glyphs.size + $copylist_olds.size).to_s
puts "Mapping: " + $glyphs.size.to_s
puts


# 建立cn字符對應lookup
f = File.open("working/lookup_cnstyle.txt", 'w:utf-8')
f.puts "lookup cn_style {"

$symbols.each { |ct, cs|
	ctgn = to_glyphname(ct)
	csgn = to_glyphname(cs)
	f.puts "  sub #{ctgn} by #{csgn};"
}

loadfile('./simptables/cn_1965_PrintUnified.txt') { |ct, cs|
	next if !$glyphs.has_key?(ct)
	gn = to_glyphname(ct)
	f.puts "  sub #{gn} by #{gn}.cn;"
}
f.puts "} cn_style;"
f.close

#$gsubs.each_with_index { |lst, i|
fm = File.open("working/feature_prefix.txt", 'w:utf-8')
i = 0
$gsubs.each { |tag, lst|
	if i > 0
		sstag = sprintf('ss%02d', i)
		f = File.open("working/feature_#{sstag}.txt", 'w:utf-8')
		zhname = ''
		$simptables[tag][:zh].each_char { |c|
			zhname += c =~ /[A-Za-z0-9 ,_-]/ ? c : sprintf('\\%04x', c.ord)
		}
		f.puts "featureNames {"
		f.puts "  name \"#{$simptables[tag][:year]} #{$simptables[tag][:en]}\";"
		f.puts "  name 3 1 0x404 \"#{$simptables[tag][:year]} #{zhname}\";"
		f.puts "  name 1 \"#{$simptables[tag][:year]} #{$simptables[tag][:en]}\";"
		f.puts "};"

		if is_cnset(i) || lst.size > 2000
			f.puts "lookup #{sstag}main;"
			f.puts "lookup cn_style;" if is_cnset(i) 
			fm.puts "lookup #{sstag}main useExtension {"
			lst.each { |s| fm.puts '  ' + s }
			fm.puts "} #{sstag}main;"
			fm.puts
		else
			lst.each { |s| f.puts s }
		end

		f.close
		puts " - #{sstag}: #{lst.size}"
	end
	i += 1
}
fm.close
