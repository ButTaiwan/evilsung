require './common.rb'
require 'set'
require 'json'

xsimptag = :simpr
maintags = [:trad, :kmt, :draft, xsimptag, :sg1, :er2]


chars = {}
max_varieties = 0

json = {
	diff_simp64_simp86: [],
	diff_simp86_simp13: [],
	diff_simp64_draft: [],	# 均有簡化，但簡化方式不同者 
	diff_simp64_sg: [],		# sg有簡化，但方式與simp64不同者	
	diff_simp64_kmt: [],	# kmt有簡化，但方式與simp64不同者	
}

#cn2tmap = Hash.new { |hsh, k| hsh[k] = Set.new }
s2tmaps = {}
maintags.each { |tag| s2tmaps[tag] = Hash.new { |hsh, k| hsh[k] = Set.new } }

loadfile('all_simptable.txt') { |tmp|
	row = {}
	varieties = Set.new
	#simp_varieties = Set.new

	$simptables.keys.each_with_index { |k, i|
		row[k] = tmp[i] && tmp[i] != '' ? tmp[i].gsub(/\.cn$/, '') : tmp[0].gsub(/\.cn$/, '')		# 此比較一律將.cn視為相同
		varieties << row[k] if maintags.include?(k)
	}
	chars[row[:trad]] = row

	json[:diff_simp64_simp86] << row[:trad] if row[:simp64] != row[:simp86]
	json[:diff_simp86_simp13] << row[:trad] if row[:simp86] != row[:simp13]
	json[:diff_simp64_draft] << row[:trad] if row[:draft] != row[:trad] && row[:simp64] != row[:trad] && row[:draft] != row[:simp64]
	json[:diff_simp64_sg] << row[:trad] if row[:sg1] != row[:trad] && row[:sg1] != row[:simp64]
	json[:diff_simp64_kmt] << row[:trad] if row[:kmt] != row[:trad] && row[:kmt] != row[:simp64]

	row[:varieties] = varieties.size
	max_varieties = varieties.size if varieties.size > max_varieties

	maintags.each { |tag|
		s2tmaps[tag][row[tag]] << row[:trad] #if row[tag] != row[:trad]
	}
}

# 異體最多的字
json[:maxVarieties] = {max: max_varieties}
2.times { |i|
	cnt = max_varieties - i
	data = []
	chars.each { |char, c|
		#data << c.slice(:trad, :kmt, :draft, :simp13, :sg2, :er2) if c[:varieties] == cnt
		data << char if c[:varieties] == cnt
		#p c.slice(:trad, :kmt, :draft, :simp13, :sg2, :er2) if c[:varieties] == cnt
	}
	json[:maxVarieties][cnt] = data
}

puts json[:diff_simp64_simp86].size
puts json[:diff_simp86_simp13].size
puts json[:diff_simp64_draft].size
puts json[:diff_simp64_sg].size
puts json[:diff_simp64_kmt].size

json[:simpDiffs] = {kmt: [], draft: [], sg1: [], er2: []}
json[:simpMore] = {kmt: [], draft: [], sg1: [], er2: []}

s2tmaps.each { |tag, map|
	next if tag == xsimptag

	same_keys = map.keys & s2tmaps[xsimptag].keys
	same_keys.each { |sc|
		next if (map[sc] - [sc]).size == 0
#		p "#{tag} / #{sc} / #{map1[sc]} / #{s2tmaps[xsimptag][sc]}" if (map1[sc] & s2tmaps[xsimptag][sc]).size == 0
		diff = (s2tmaps[xsimptag][sc] - map[sc]).size > 0
		xTrads = (map[sc] - [sc]).to_a.join(' ')
		cnTrads = (s2tmaps[xsimptag][sc] - [sc]).to_a.join(' ')
		next if (map[sc] - s2tmaps[xsimptag][sc]).size == 0
		json[:simpDiffs][tag] << {s: sc, cn: cnTrads, x: xTrads} if diff
		json[:simpMore][tag] << {s: sc, cn: cnTrads, x: xTrads} if !diff
		p "#{tag} / #{sc} / #{xTrads} / #{cnTrads} / #{diff}" if (map[sc] - s2tmaps[xsimptag][sc]).size > 0
	}
	#p tag1, same_keys
}

#puts JSON.pretty_generate(json[:simpDiffs])
#p json[:simpDiffs]

# json[:simpDiffs].each { |k, res|
# 	chars.each { |trad, c|		# 尋找用途與cn不同的簡體字
# 		next if c[k] == trad
# 		next if !cn2tmap.has_key?(c[k]) || cn2tmap[c[k]].include?(trad)

# 		simpc = c[k]
# 		res[simpc] = {:simp64 => cn2tmap[c[k]], k => Set.new} if !res.has_key?(simpc)
# 		res[simpc][k] << trad
# 		##p "#{c[k]}: #{trad}/#{k} <=> #{cn2tmap[c[k]]}" if cn2tmap.has_key?(c[k]) && !cn2tmap[c[k]].include?(trad)
# 	}
# }

f = File.open('../pages/data.js', 'w:utf-8')
f.puts 'var data = ' + JSON.generate(json) + ';'
f.close

#p json[:simpDiffs]


#puts JSON.generate(json)
# max_s2t_cnt = 0
# s2tmap.each { |sc, trads| max_s2t_cnt = trads.size if trads.size > max_s2t_cnt  }
# p max_s2t_cnt
# 6.times { |i|
# 	s2tmap.each { |sc, trads| p sc, trads if trads.size == max_s2t_cnt-i  }
# }


# 各主要方案差異最多元的字
