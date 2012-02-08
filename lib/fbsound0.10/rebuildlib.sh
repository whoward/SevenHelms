#!/bin/sh
echo "build cpu layer"
fbc  -mt -i inc -lib src/fbscpu.bas    -x lib/fbscpulin
echo "build fbsound"
fbc  -mt -i inc -lib src/fbsound.bas   -x lib/fbsoundlin
echo "build plug alsa"
fbc  -mt -i inc -dll src/plug-alsa.bas -x lib/libplug-alsa.so
echo "build plug dsp"
fbc  -mt -i inc -dll src/plug-dsp.bas  -x lib/libplug-dsp.so
echo "build plug arts"
fbc  -mt -i inc -dll src/plug-arts.bas -x lib/libplug-arts.so
echo "ready!"
echo ""
echo "have fun with FreeBASIC and FBSound"
echo ""

