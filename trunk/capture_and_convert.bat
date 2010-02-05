CutyCapt.exe --url="http://localhost?Comet_port=%1" --out=tmp_%2
convert tmp_%2 -resize %3 -crop "%3x%3+0+0" %2
del tmp_%2
