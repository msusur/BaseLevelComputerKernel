default: start-qemu

bootloader.bin: force_look
	cd bootloader; $(MAKE)
	
MICRO_KERNEL_SRC=$(wildcard micro_kernel/*.asm)
MICRO_KERNEL_UTILS_SRC=$(wildcard micro_kernel/utils/*.asm)

micro_kernel.bin: force_look
	cd micro_kernel; $(MAKE)

kernel.bin: force_look
	cd kernel; $(MAKE)
	
filler.bin: kernel.bin
	bash prepForLoading.sh
	
balecok.iso: bootloader.bin micro_kernel.bin kernel.bin filler.bin
	cat bootloader/bootloader.bin > balecok.bin
	cat micro_kernel/micro_kernel.bin >> balecok.bin
	cat kernel/kernel.bin >> balecok.bin
	dd status=noxfer conv=notrunc if=balecok.bin of=balecok.iso

start-qemu: balecok.iso
	qemu-system-x86_64 -fda balecok.iso

bochs: balecok.iso
	echo balecok.iso
	bochs -qf .bochsConfig -rc commands
	rm commands

debug: balecok.iso
	echo "c" > commands
	bochs -qf .bochsConfig -rc commands
	rm commands
	
devMicro: 
	geany $(MICRO_KERNEL_SRC) $(MICRO_KERNEL_UTILS_SRC)
	
devCpp:
	geany kernel/src/*.cpp

devBoot:
	geany bootloader/*.asm
	
devEnv:
	geany $(MICRO_KERNEL_SRC) $(MICRO_KERNEL_UTILS_SRC) bootloader/*.asm kernel/src/*.cpp

force_look:
	true
	
clean:
	cd bootloader; $(MAKE) clean
	cd kernel; $(MAKE) clean
	cd micro_kernel; $(MAKE) clean
	rm -rf *.bin *.o *.g *.iso
