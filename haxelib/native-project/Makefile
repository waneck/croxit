PROJECTNAME:=croxit

CC:=ios-clang
CPP:=ios-clang++
AR:=arm-apple-darwin11-ar

CFLAGS += -objc-arc
CFLAGS += -fblocks
CFLAGS += -g0 -O2
CFLAGS += -I"$(SRCDIR)"
CFLAGS += -I"/usr/include/clang/3.2/include/"

ARCH=
ifneq ($(IOSARCH),)
	CPPFLAGS += -arch arm$(IOSARCH)
	ARCH = -$(IOSARCH)
endif

CPPFLAGS += -objc-arc
CPPFLAGS += -fblocks
CPPFLAGS += -g0 -O2
CPPLAGS += -I"$(SRCDIR)"
CPPFLAGS += -I"$(shell haxelib path hxcpp | head -1)/include"
CPPFLAGS += -I"/usr/include/clang/3.2/include/"

SRCDIR=native/iPhone
OBJS+=$(patsubst %.m,%.o,$(wildcard $(SRCDIR)/*.m))
OBJS+=$(patsubst %.c,%.o,$(wildcard $(SRCDIR)/*.c))
OBJS+=$(patsubst %.cpp,%.o,$(wildcard $(SRCDIR)/*.cpp))
OBJS+=$(patsubst %.mm,%.o,$(wildcard $(SRCDIR)/*.mm))

all:	../ndll/iPhone/lib$(PROJECTNAME).iphoneos${ARCH}.a

../ndll/iPhone/lib$(PROJECTNAME).iphoneos${ARCH}.a:	$(OBJS)
	$(AR) cr $@ $(filter %.o,$^)

%.o:	%.m
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.c
	$(CC) -c $(CFLAGS) $< -o $@

%.o:	%.cpp
	$(CPP) -c $(CPPFLAGS) $< -o $@

%.o:	%.mm
	$(CPP) -c $(CPPFLAGS) $< -o $@


clean:
	find . -name \*.o|xargs rm -rf
	rm -f $(PROJECTNAME)

.PHONY: all dist install uninstall clean
