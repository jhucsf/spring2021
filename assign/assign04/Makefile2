CC = gcc
CFLAGS = -g -Wall -Wextra -pedantic -std=c11 -fPIC

CXX = g++
CXXFLAGS = -g -Wall -Wextra -pedantic -std=c++14 -fPIC

# C source files to be linked into the driver (imgproc) executable
DRIVER_C_SRCS = pnglite.c image.c

# C++ source files to be linked into the driver (imgproc) executable
DRIVER_CXX_SRCS = imgproc.cpp

# C plugin source files
PLUGIN_C_SRCS = swapbg.c

# C++ plugin source files
PLUGIN_CXX_SRCS =  mirrorh.cpp mirrorv.cpp tile.cpp expose.cpp

DRIVER_OBJS = $(DRIVER_C_SRCS:%.c=%.o) $(DRIVER_CXX_SRCS:%.cpp=%.o)
PLUGINS = $(PLUGIN_C_SRCS:%.c=plugins/%.so) $(PLUGIN_CXX_SRCS:%.cpp=%.o)

%.o : %.c
	$(CC) $(CFLAGS) -c $*.c -o $*.o

%.o : %.cpp
	$(CXX) $(CXXFLAGS) -c $*.cpp -o $*.o

plugins/%.so : %.o
	mkdir -p plugins
	$(CXX) -o plugins/$*.so -shared $*.o

all : imgproc $(PLUGINS)

imgproc : $(DRIVER_OBJS)
	$(CXX) -export-dynamic -o $@ $(DRIVER_OBJS) -lz -ldl

plugins/swapbg.so : swapbg.o

# TODO: add targets for other plugins

# E.g.,
#plugins/mirrorh.so : plugins/mirrorh.o

clean :
	rm -f *.o imgproc plugins/*.so depend.mak

# Running
#    make depend
# will automatically generate header file dependencies.
depend :
	$(CC) $(CFLAGS) -M $(DRIVER_C_SRCS) $(PLUGIN_C_SRCS) > depend.mak
	$(CXX) $(CXXFLAGS) -M $(DRIVER_CXX_SRCS) $(PLUGIN_CXX_SRCS) >> depend.mak

depend.mak :
	touch $@

include depend.mak
