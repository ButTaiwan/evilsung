#$fields = [:trad, :draft, :d1p, :d2p, :d3p, :d4p, :simp64, :simpr, :er1, :er2, :simp86, :simp88, :simp13, :kmt, :sg1, :sg2, :gb2312, :flag]

require './common.rb'
$fields = $simptables.keys

files = {
	'draftsimp' => 'cn_1955_SimpDraft798.txt',
	'draftvars' => 'cn_1955_Variants400.txt',
	'vars' => 'cn_1955_VariantsBatch1.txt',
	'd1p' => 'cn_1956_SimpBatch1.txt',
	'd2p' => 'cn_1956_SimpBatch2.txt',
	'd3p' => 'cn_1958_SimpBatch3.txt',
	'd4p' => 'cn_1959_SimpBatch4.txt',
	'simp1964' => 'cn_1964_SimpTable.txt',
	'print' => 'cn_1965_PrintGlyphs.txt',
	'printuf' => 'cn_1965_PrintUnified.txt',
	'erjian1' => 'cn_1977_2ndSimpTable1.txt',
	'erjian2' => 'cn_1977_2ndSimpTable2.txt',
	'simp1986' => 'cn_1986_SimpTable.txt',
	'common1988' => 'cn_1988_Common.txt',
	'common2013' => 'cn_2013_Common.txt',
	'kmt' => 'kmt_1935_SimpTable.txt',
	'sg1' => 'sg_1969_SimpTable.txt',
	'sg2' => 'sg_1974_SimpTable.txt'
}

def read_mapping key, fn, notemode = false
	res = Hash.new(nil)
	f = File.open('./simptables/' + fn, 'r:utf-8')
	f.each { |s|
		s.chomp!
		next if s.length == 0
		next if s[0] == '#'

		c1, c2, note = s.split(/\t/)
		res[c1] = c2 if !notemode && !res[c1]
		res[c1] = note if notemode
		#notes[note] = true

		if key =~ /^(simp|common|print|erjian)/ || $big5[c1.ord]	# || (key =~ /print/ && c2 !~ /\./)
			$all[c1.ord] = {}
			$fields.each { |k| $all[c1.ord][k] = nil }
			$all[c1.ord][:trad] = c1
		end
	}
	f.close
	res
end

def apply_mapping key, mappers, ignores = []
	$all.values.each { |r|
		#r[key] = r[:trad]
		mappers.each { |map|
			c = (r[key] ? r[key] : r[:trad]).gsub(/\.cn$/, '')
			#c = r[key]
			cs = $mapper[map][c] if $mapper[map][c]
			next unless cs
			next if map == 'vars' && $mapper['varsnotes'][c] && ignores.include?($mapper['varsnotes'][c])
			r[key] = cs if cs != c
		}
	}
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
f.close

$mapper = {}
$all = {}
files.each { |key, fn| $mapper[key] = read_mapping(key, fn) }
$mapper['varsnotes'] = read_mapping('vars', files['vars'], true)

apply_mapping :draft, ['draftvars', 'draftsimp']
apply_mapping :d1p, ['vars', 'd1p'], ['1964~', '1965~']
apply_mapping :d2p, ['vars', 'd1p', 'd2p'], ['<1956', '1964~', '1965~']
apply_mapping :d3p, ['vars', 'd1p', 'd2p', 'd3p'], ['<1956', '1964~', '1965~']
apply_mapping :d4p, ['vars', 'd1p', 'd2p', 'd3p', 'd4p'], ['<1956', '1964~', '1965~']
apply_mapping :simp64, ['vars', 'simp1964'], ['<1956', '<1964', '1965~']
apply_mapping :simpr, ['vars', 'simp1964', 'print', 'printuf'], ['<1956', '<1964', '<1965']
apply_mapping :simp86, ['vars', 'simp1986', 'print', 'printuf'], ['<1956', '<1964', '<1965', '<1986']
apply_mapping :simp88, ['vars', 'common1988', 'simp1986', 'print', 'printuf'], ['<1956', '<1964', '<1965', '<1986', '<1988']
apply_mapping :simp13, ['vars', 'common1988', 'common2013', 'simp1986', 'print', 'printuf'], ['<1956', '<1964', '<1965', '<1986', '<1988', '<1993', '<2013']

apply_mapping :er1, ['vars', 'simp1964', 'print', 'erjian1', 'printuf'], ['<1956', '<1964', '<1965']
apply_mapping :er2, ['vars', 'simp1964', 'print', 'erjian1', 'erjian2', 'printuf'], ['<1956', '<1964', '<1965']

apply_mapping :kmt, ['kmt']
apply_mapping :sg1, ['sg1']
#apply_mapping :sg2, ['sg1', 'simp1964', 'print', 'printuf']


vals = $all.values
vals.each { |c|
	# apply sg2
	c[:sg2] = $mapper['sg2'][c[:trad]] if $mapper['sg2'][c[:trad]]
	c[:sg2] = (c[:sg1] ? c[:sg1] : c[:simpr]) if !c[:sg2]

	# create erjian nested mappings
	cs = c[:simpr]
	next if !cs
	cs = cs.gsub(/\.cn/, '')
	next if cs =~ /\./
	next if cs == c[:er1] && cs == c[:er2]
	
	if !$all.has_key?(cs.ord)
		$all[cs.ord] = {}
		$fields.each { |k| $all[cs.ord][k] = nil }
		$all[cs.ord][:trad] = cs
	end	
	$all[cs.ord][:er1] = c[:er1] if c[:er1] != cs
	$all[cs.ord][:er2] = c[:er2] if c[:er2] != cs
}

# 補入沒有簡體異體字的文字
single_cnt = 0
loadfile('./adjustment/basechars.txt') { |s, x|
	next if $all.has_key?(s.ord)
	$all[s.ord] = {}
	$fields.each { |k| $all[s.ord][k] = nil }
	$all[s.ord][:trad] = s
	single_cnt += 1
}

$symbols.each { |ct, cs|
	$all[ct.ord] = {}
	$fields.each { |k| $all[ct.ord][k] = cs }
	$all[ct.ord][:trad] = ct
	$all[ct.ord][:kmt] = $all[ct.ord][:sg1] = nil
}

f = File.open('all_simptable.txt', 'w:utf-8')
$all.sort_by{ |k, v| k }.each { |k, v|
	f.puts "#{v[:trad]}\t#{v[:kmt]}\t#{v[:draft]}\t#{v[:d1p]}\t#{v[:d2p]}\t#{v[:d3p]}\t#{v[:d4p]}\t#{v[:simp64]}\t#{v[:simpr]}\t#{v[:sg1]}\t#{v[:sg2]}\t#{v[:er1]}\t#{v[:er2]}\t#{v[:simp86]}\t#{v[:simp88]}\t#{v[:simp13]}"
}
f.close
