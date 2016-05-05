GCC = gcc
CFLAGS = -g -Wall
OBJS = PCIE.o ECCDH3DES.o main.o
HDRS = TERASIC_PCIE.h PCIE.h ECCDH3DES.h
TARGET = main

.PHONY : clean environment

build: $(TARGET)

main : $(OBJS) $(HDRS) | environment
	$(GCC) $(CFLAGS) $(OBJS) -o $@ -ldl

environment:
	@mkdir -p pri_key
	@mkdir -p pub_key_local
	@mkdir -p pub_key_external
	@mkdir -p plain_text
	@mkdir -p cipher_text
	@echo "This is an unusual paragraph. I'm curious as to just how quickly you can find out what is so unusual about it. It looks so ordinary and plain that you would think nothing was wrong with it. In fact, nothing is wrong with it! It is highly unusual though. Study it and think about it, but you still may not find anything odd. But if you work at it a bit, you might find out. Try to do so without any coaching." > test_input.txt

.c.o:
	$(GCC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(TARGET) *.a *.o *~
	rm -rf pri_key/
	rm -rf pub_key_local/
	rm -rf pub_key_external/
	rm -rf cipher_text/
	rm -rf plain_text/
	rm -f test_input.txt
