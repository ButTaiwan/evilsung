$simptables = {
	trad: {year: nil, en: 'Traditional Chinese', zh: '繁體字'}, 
	kmt: {year: 1935, en: 'First Batch Simplified Characters', zh: '第一批簡體字表'}, 
	draft: {year: 1955, en: 'Simplification Scheme Draft', zh: '漢字簡化方案草案'}, 
	d1p: {year: 1956, en: 'Simplification Scheme Batch 1', zh: '漢字簡化方案第一批簡化字'}, 
	d2p: {year: 1956, en: 'Simplification Scheme Batch 2', zh: '漢字簡化方案第二批簡化字'},
	d3p: {year: 1958, en: 'Simplification Scheme Batch 3', zh: '漢字簡化方案第三批簡化字'}, 
	d4p: {year: 1959, en: 'Simplification Scheme Batch 4', zh: '漢字簡化方案第四批簡化字'}, 
	simp64: {year: 1964, en: 'Simplified Chinese', zh: '簡化字總表'}, 
	simpr: {year: 1965, en: 'Printing Standard Forms of Characters', zh: '印刷通用漢字字形表'}, 
	sg1: {year: 1969, en: 'Singapore Simplified Characters', zh: '簡體字表(新加坡)'}, 
	sg2: {year: 1974, en: 'Singapore Simplified Characters', zh: '簡体字總表(新加坡)'}, 
	er1: {year: 1977, en: 'Second Scheme Draft (Table 1)', zh: '第二次漢字簡化方案草案第一表'}, 
	er2: {year: 1977, en: 'Second Scheme Draft (Table 2)', zh: '第二次漢字簡化方案草案第二表'}, 
	simp86: {year: 1986, en: 'Simplified Chinese', zh: '簡化字總表'}, 
	simp88: {year: 1988, en: 'Commonly Used Characters', zh: '現代漢語通用字表'}, 
	simp13: {year: 2013, en: 'General Standard Chinese Characters', zh: '通用規範漢字表'}
}

$symbols = {
	'「' => '“', '」' => '”', '、' => '、.cn', '。' => '。.cn',
	'！' => '！.cn', '，' => '，.cn', '：' => '：.cn', '；' => '；.cn', '？' => '？.cn'
}

def loadfile fn
	f = File.open(fn, 'r:utf-8')
	f.each { |s|
		s.chomp!
		next if s == ''
		next if s[0] == '#'
		yield s.split(/\t/)
	}
	f.close	
end

def is_han? unidec
	(0x3400..0x9FFF).include?(unidec) || (0xF900..0xFAFF).include?(unidec) || unidec >= 0x20000
end