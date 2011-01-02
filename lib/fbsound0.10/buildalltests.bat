@echo "please wait create all 35 tests ..."
del tests\*.exe
fbc  -mt  -p lib -i inc tests/test01.bas
fbc  -mt  -p lib -i inc tests/test02.bas
fbc -s gui -mt  -p lib -i inc tests/test02_window.bas
fbc  -mt  -p lib -i inc tests/test03.bas
fbc  -mt  -p lib -i inc tests/test04.bas
fbc  -mt  -p lib -i inc tests/test05.bas
fbc  -mt  -p lib -i inc tests/test06.bas
fbc  -mt  -p lib -i inc tests/test06_b.bas
fbc  -mt  -p lib -i inc tests/test06_c.bas
fbc  -mt  -p lib -i inc tests/test07.bas
fbc  -mt  -p lib -i inc tests/test08.bas
fbc  -mt  -p lib -i inc tests/test09.bas
fbc  -mt  -p lib -i inc tests/test10.bas
fbc  -mt  -p lib -i inc tests/test11.bas
fbc  -mt  -p lib -i inc tests/test11_b.bas
fbc  -mt  -p lib -i inc tests/test12.bas
fbc  -mt  -p lib -i inc tests/test12_b.bas
fbc  -mt  -p lib -i inc tests/test12_c.bas
fbc  -mt  -p lib -i inc tests/test13.bas
fbc  -mt  -p lib -i inc tests/test14.bas
fbc  -mt  -p lib -i inc tests/test14_b.bas
fbc  -mt  -p lib -i inc tests/test15.bas
fbc  -mt  -p lib -i inc tests/test16.bas
fbc  -mt  -p lib -i inc tests/test17.bas
fbc  -mt  -p lib -i inc tests/test18.bas
fbc  -mt  -p lib -i inc tests/test19.bas
fbc  -mt  -p lib -i inc tests/test20.bas
fbc  -mt  -p lib -i inc tests/test21.bas
fbc  -mt  -p lib -i inc tests/test22.bas
fbc  -mt  -p lib -i inc tests/test23.bas
fbc  -mt  -p lib -i inc tests/test24.bas
fbc  -mt  -p lib -i inc tests/test25.bas
fbc  -mt  -p lib -i inc tests/test26.bas
fbc  -mt  -p lib -i inc tests/test27.bas
fbc  -mt  -p lib -i inc tests/test28.bas

cd tests
dir *.exe
@echo "ready!"
@echo.
@echo "have fun with FreeBASIC and FBSound"
@echo.
@pause

