FBSNDDIR = lib/fbsound0.10
FBSNDSRC = $(FBSNDDIR)/src
FBSNDLIB = $(FBSNDDIR)/lib

FBC = fbc
FBCFLAGS = -i $(FBSNDDIR)/inc -p $(FBSNDLIB)

PROGRAM = seven-helms
PROGRAMSRC = src/MUD2.BAS
OBJS = src/Ds4qb2.o
LIBS = $(FBSNDLIB)/libfbscpulin.a $(FBSNDLIB)/libfbsoundlin.a $(FBSNDLIB)/libplug-alsa.so $(FBSNDLIB)/libplug-arts.so $(FBSNDLIB)/libplug-dsp.so

all : $(PROGRAMSRC) $(OBJS) $(LIBS)
	$(FBC) $(FBCFLAGS) -x $(PROGRAM) $(PROGRAMSRC) $(OBJS)

clean :
	rm $(LIBS) $(OBJS) $(PROGRAM)

src/Ds4qb2.o : src/Ds4qb2.bas
	$(FBC) $(FBCFLAGS) -c -C src/Ds4qb2.bas

$(FBSNDLIB)/libplug-alsa.so : $(FBSNDSRC)/plug-alsa.bas
	$(FBC) $(FBCFLAGS) -mt -dll $(FBSNDSRC)/plug-alsa.bas -x $(FBSNDLIB)/libplug-alsa.so

$(FBSNDLIB)/libplug-arts.so : $(FBSNDSRC)/plug-arts.bas
	$(FBC) $(FBCFLAGS) -mt -dll $(FBSNDSRC)/plug-arts.bas -x $(FBSNDLIB)/libplug-arts.so

$(FBSNDLIB)/libplug-dsp.so : $(FBSNDSRC)/plug-dsp.bas
	$(FBC) $(FBCFLAGS) -mt -dll $(FBSNDSRC)/plug-dsp.bas -x $(FBSNDLIB)/libplug-dsp.so

$(FBSNDLIB)/libfbscpulin.a : $(FBSNDSRC)/fbscpu.bas
	$(FBC) $(FBCFLAGS) -mt -lib $(FBSNDSRC)/fbscpu.bas -x $(FBSNDLIB)/fbscpulin

$(FBSNDLIB)/libfbsoundlin.a : $(FBSNDSRC)/fbsound.bas
	$(FBC) $(FBCFLAGS) -mt -lib $(FBSNDSRC)/fbsound.bas -x $(FBSNDLIB)/fbsoundlin