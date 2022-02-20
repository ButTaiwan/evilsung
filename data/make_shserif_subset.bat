set newfdk=D:\fontworks\afdko-3.8.0\afdko-3.8.0.data\scripts
set oldfdk=D:\fontworks\FDK-2014\Tools\win
if "%oldfdkset%"=="" set path=%oldfdk%
set oldfdkset=1

%newfdk%\mergefonts tmp\subset.cid.ps working\afdko_shs_mergefile_subset.txt shserif\cidfont.ps.OTC.SC
%newfdk%\tx -t1 -decid -usefd 0 tmp\subset.cid.ps > tmp\subset.decid.pfa
%newfdk%\mergefonts tmp\subset.name.pfa working\afdko_shs_mergefile_rename.txt tmp\subset.decid.pfa
:%newfdk%\tx -pdf tmp\subset.name.pfa > tmp\subset.name.pdf
makeotf.cmd -f tmp\subset.name.pfa
