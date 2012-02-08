FBSNDDIR = lib/fbsound0.10
FBSNDSRC = $(FBSNDDIR)/src
FBSNDLIB = $(FBSNDDIR)/lib

FBC = fbc
FBCFLAGS = -i $(FBSNDDIR)/inc -p $(FBSNDLIB)

PROGRAM = seven-helms
PROGRAMSRC = src/MUD2.BAS
OBJS = src/Ds4qb2.o
LIBS = $(FBSNDLIB)/libfbscpulin.a $(FBSNDLIB)/libfbsoundlin.a libplug-alsa.so libplug-arts.so libplug-dsp.so

all : $(PROGRAM)

clean :
	rm $(LIBS) $(OBJS) $(PROGRAM)

$(PROGRAM) : $(PROGRAMSRC) $(OBJS) $(LIBS)
	$(FBC) $(FBCFLAGS) -x $(PROGRAM) $(PROGRAMSRC) $(OBJS)

src/Ds4qb2.o : src/Ds4qb2.bas
	$(FBC) $(FBCFLAGS) -c -C src/Ds4qb2.bas

libplug-alsa.so : $(FBSNDSRC)/plug-alsa.bas
	$(FBC) $(FBCFLAGS) -mt -dll $(FBSNDSRC)/plug-alsa.bas -x libplug-alsa.so

libplug-arts.so : $(FBSNDSRC)/plug-arts.bas
	$(FBC) $(FBCFLAGS) -mt -dll $(FBSNDSRC)/plug-arts.bas -x libplug-arts.so

libplug-dsp.so : $(FBSNDSRC)/plug-dsp.bas
	$(FBC) $(FBCFLAGS) -mt -dll $(FBSNDSRC)/plug-dsp.bas -x libplug-dsp.so

$(FBSNDLIB)/libfbscpulin.a : $(FBSNDSRC)/fbscpu.bas
	$(FBC) $(FBCFLAGS) -mt -lib $(FBSNDSRC)/fbscpu.bas -x $(FBSNDLIB)/fbscpulin

$(FBSNDLIB)/libfbsoundlin.a : $(FBSNDSRC)/fbsound.bas
	$(FBC) $(FBCFLAGS) -mt -lib $(FBSNDSRC)/fbsound.bas -x $(FBSNDLIB)/fbsoundlin
