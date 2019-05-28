PROTOC = protoc
INCLUDES = -Iinclude
LDFLAGS =  -lprotobuf

CC = clang++

PROTOS = $(wildcard proto/*.proto)
SRCS = $(patsubst proto/%.proto,src/%.pb.cc,$(PROTOS))
SRCS += src/tensorboard_logger.cc src/crc.cc
OBJS = $(patsubst src/%.cc,src/%.o,$(SRCS))

.PHONY: all proto obj test clean distclean

all: proto obj test
obj: $(OBJS)

proto: $(PROTOS)
	$(PROTOC) -Iproto $(PROTOS) --cpp_out=proto
	mv proto/*.cc src
	mv proto/*.h include

$(OBJS): %.o: %.cc
	$(CC) -std=c++11 $(INCLUDES) -c $< -o $@

test: tests/test_tensorboard_logger.cc
	$(CC) -std=c++11 $(INCLUDES) $(OBJS) $< -o $@ $(LDFLAGS)

clean:
	rm -f src/*.o test

distclean: clean
	rm include/*.pb.h src/*.pb.cc

lib: proto obj
	ar rcs libtensorboard_logger.a $(OBJS)
