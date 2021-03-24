CC = gcc
CFLAGS = -g -Wall -Wextra -pedantic -std=c11 -fPIC

PLUGIN_SRCS = swapbg.c mirrorh.c mirrorv.c tile.c expose.c
SRCS = imgproc.c pnglite.c $(PLUGIN_SRCS)

OBJS = $(SRCS:%.c=%.o)
PLUGINS = $(PLUGIN_SRCS:%.c=plugins/%.so)

%.o : %.c
	$(CC) $(CFLAGS) -c $*.c -o $*.o

plugins/%.so : %.o
	mkdir -p plugins
	$(CC) -o plugins/$*.so -shared $*.o

all : imgproc $(PLUGINS)

imgproc : imgproc.o image.o pnglite.o
	$(CC) -export-dynamic -o $@ imgproc.o image.o pnglite.o -lz -ldl

plugins/swapbg.so : swapbg.o

clean :
	rm -f *.o imgproc plugins/*.so depend.mak

# Running
#    make depend
# will automatically generate header file dependencies.
depend :
	$(CC) $(CFLAGS) -M $(SRCS) >> depend.mak

depend.mak :
	touch $@

include depend.mak
