# 簡體字整理程式與檔案說明

## 字符命名方式

- 為處理易於閱讀，所有資料中直接以漢字描述字符名稱。
例如「部」字，在表格裡就直接輸入「部」字。實際上在字型內字符名稱會轉換成「uni90EB」。
- 簡體字也直接以正確 Unicode 命名處理。
- 當該簡體字在 Unicode 未收錄時，則加上後綴。如「溜」的二簡字，在資料上為「溜.er1」，實際的字符名稱則是「uni6E9C.er1」。
- 這類加上後綴文字的基礎文字盡可能選擇相似者，如「部」的二簡字是類似注音符號ㄗ，類似「卩」但有出頭，這裡命名為「卩.er1」而不是「部.er1」。但沒有絕對規則。
- 部分簡化的命名特別麻煩，如「繹」在〈漢字簡化方案草案〉右側的「睪」簡化了，左側未簡化。雖然命名為「繹.ca798」或「绎.ca798」均合理，在這裡以攫取特徵為主，故命名為「绎.ca798」。
- 各簡化方案常有文字同形的情形。所以各文件裡可能夾雜出現其他方案的後綴，單純是字型製造順序的結果。先製作的字符先命名，後來出現同形文字就沿用原字符名稱。但這也是最容易出錯的部份，或許收有部分不同字符名稱而同形的文字。（若發現請於 issues 告訴我。）

## 本目錄

- common.rb : 共通函式與共通設定資料
- gen_simptable.rb : 產生完整各方案簡體對應表
	- 邪宋 2022 年版最重要的一支程式。舊版本多由人工整理夾雜部分錯誤，新版本將各方案分開整理，方案之間的繼承關係則由程式自動化處理，避免錯誤，且方便未來修正錯誤時的整批修改。
- all_simptable.txt : 各方案簡體字總表（由上面程式產生）
- dump_trad_glyph_list.rb : 產生字型所需的舊字形漢字總表
	- working 資料夾下所有檔案均由此程式產生
- tradglyphs.txt : 舊字形漢字總表（由上面程式產生）
	- 本檔案不含 KR、CN 字符相同的文字。
- gen_font_working_files.rb : 產生製作字型時會需要的各種檔案
- make_shserif_subset.bat : 從思源宋體擷取所需字符子集並轉換成otf字型。需要AFDKO。
	- 雖然用到 tx、mergefonts、makeotf 三支程式，但不是每個版本都能正常運作，在這裡用到兩個能 work 的不同版本。
- makedemodata.rb : 產生[示範頁面](https://buttaiwan.github.io/evilsung/)所需要的資料集。

## adjustment 目錄（人為介入的基本調整資料）

- basechars.txt : 至少要包含的基底文字。
	- 此文件大致上是由 Big5 與 GB12345 的重複文字整理出來的。
- extG_codemap.txt : 擴充G區文字的名稱與 Unicode 對應
	- 在此字型 2019 年原先製作時，擴充 G 區文字還沒正式實施，多數二簡等文字都是用「原.er1」這樣的形式命名，但後來此字被正式收進 Unicode（U+30196）。考慮到資料修改幅度大，且 G 區文字實際上在作業時也難以編輯顯示，故資料上保留「原.er1」呈，並在字型檔最後輸出時依此表指定 Unicode 值。
- oldfont_glyphlist.txt : 從 2019 舊版字型 .glyphs 檔案傾印出來的所有字符名稱
- oldfont_glyph_renames.txt : 從 2019 舊版字型複製字符時，需要修改名稱的字符。
	- 新版製作過程發現當初命名不佳，或當初 Unicode 已編碼遺漏未發現者

## simptalbes 目錄（各簡化方案整理表）

- 中國部份
	- cn_1955_SimpDraft798.txt : 〈漢字簡化方案草案〉內的「798個漢字簡化表草案」
	- cn_1955_Variants400.txt : 〈漢字簡化方案草案〉內的「擬廢除的400的異體字表草案」
	- cn_1955_VariantsBatch1.txt : 〈第一批异体字整理表〉，此表除部分陸續修改外，適用於後續各方案，故部份文字有標註效期
	- cn_1956_SimpBatch[1-4].txt : 〈漢字簡化方案〉第一至四批
	- cn_1964_SimpTable.txt : 〈简化字总表〉 1964 年版
	- cn_1965_PrintGlyphs.txt : 〈印刷通用汉字字形表〉中，在 Unicode 因原規格分離，為不同碼位者
	- cn_1965_PrintUnified.txt : 思源宋體中 KR/CN 字形不同者（注意其實不是〈印刷通用汉字字形表〉的整理）
	- cn_1977_2ndSimpTable1.txt : 〈第二次汉字简化方案（草案）〉第一表
	- cn_1977_2ndSimpTable2.txt : 〈第二次汉字简化方案（草案）〉第二表
	- cn_1986_SimpTable.txt : 〈简化字总表〉 1986 年版
	- cn_1988_Common.txt : 〈现代汉语通用字表〉（並非完整內容，僅為人工有限比對差異）
	- cn_2013_Common.txt : 〈通用规范汉字表〉（並非完整內容，僅為人工有限比對差異）
- 國民政府部份
	- kmt_1935_SimpTable.txt : 〈第一批简体字表〉
- 新加坡部份
	- sg_1969_SimpTable.txt : 〈簡體字表〉的502簡體
	- sg_1974_SimpTable.txt : 追加簡化的幾個字
		- 1974 年版是已中國簡體字為主，再保留承認 1969 年版不同寫法的簡體字。但部分文字會有追加減化的問題，如「識	」字在1969年版簡化成「䛊」，1974年就直接用「识」較合理，保留「䛊」比較奇怪。此檔案只修正此類文字，其他均由程式自動合併兩規格。

關於這些方案的詳細說明，請見本專案其他目錄的解說。

## refs 目錄（其他參考資料）

- babal_er[12].txt : 魏安所整理的二簡字總表，互相比對用。
- refs\BIG5.txt : Unicode 組織提供的 Big5 字碼表。

## shserif 目錄（思源宋體文件）

因此字型舊版是 2019 年開始製作，故使用的是 1.0 版本，非 2.0。

- cidfont.ps.OTC.SC : 所有字碼的 PostScript 字型
- utf32-(cn|kr|tw).map : 各國字形的 CID 對應表

## working 目錄（自動生成的字型製作用檔案）

- afdko_shs_mergefile_subset.txt : 擷取思源宋體子集的映射檔，AFDKO用 (CID)
- afdko_shs_mergefile_rename.txt : 將 CID-keyed 字型字符名稱改為 name-keyed 字型的名稱映射檔，AFDKO用
	- 以上兩檔案，本應一次完成。但我實際上用 mergefonts 工具直接嘗試擷取出 name-keyed 字型，各版本都無法正確產生字型檔。
	- 使用 tx -t1 -decid 可以將 CID-keyed 正確轉成 name-keyed，但整個思源宋體檔案太大太複雜，轉出來的 Type1 字型檔會出問題，無法正確進行後續處理
	- 最後解決方式是先用 mergefonts 擷取 CID-keyed 子集後，再用 tx 轉換成 name-keyed（字符名稱會是 cidXXXXX 形式），最後再用一次 mergefonts 映射成本專案的形式
- glyphs_shs_copylist.txt : 將上述檔案中複製到 Glyphs 的字符清單
	- 實際上就是除了 .notdef 的所有字符，這裡附上字符列表是為了方便在 Glyphs 以清單篩選模式檢查完整性用
- glyphs_old_copylist.txt : 從邪宋 2019 版本複製的字符清單
	- 當時已經做好 700 多新加坡、二簡字，重作可惜。
	- 英數符號也直接沿用當時版本，沒有從思源宋體再複製。
- glyphs_old_renamelist.txt : 字符改名用的 Python 程式碼，Glyphs 用
- glyphs_old_glyphlist.txt : 從邪宋 2019 版本複製的字符清單（改名後，驗證用）
- glyphs_custom_list.txt : 2022 版新增需要製作的字符清單
- glyphs_custom_notes.txt : 清單內多數字符從名稱難以確認來源（尤其是 Unicode 有收錄者），自動匯出備註資訊供造字時參考
- glyphs_assign_extg_unicodes.txt : 字型最後匯出時，指定擴充 G 區文字 Unicode 的 Python 程式碼，Glyphs 用
- feature_prefix.txt : 字型特性的表頭文件，為各簡化方案的 lookup 因內容太大量需要 useExtension 的部分。
- lookup_cnstyle.txt : CN 新字形轉換的 lookup，整理在一起降低字型檔大小。注意應該放在所有中國簡化字表 lookup 的最後面，運作才會正常。
- feature_ss(01~15).txt : 特性 ss01～ss15 各自的表格。
	- 簡化字總表之後，因字數過多，都已經拆成 lookup 在 feature_prefix.txt 裡。
	- 未來應該將簡化字總表後各方案完全相同的文字再抽出獨立 lookup，進一步縮小字型檔。
