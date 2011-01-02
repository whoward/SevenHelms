@echo "create debug cpu layer"
@fbc  -mt -i inc -lib src/fbscpu.bas -x lib/fbscpuwin

@echo "create debug fbsound"
@fbc  -mt -i inc -lib src/fbsound.bas -x lib/fbsoundwin

@echo "create debug plug mm"
@fbc  -mt -i inc -dll src/plug-mm.bas -x lib/plug-mm.dll

@echo "ready!"
@pause

