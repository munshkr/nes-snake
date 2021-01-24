.PHONY: run clean

objdir := obj
srcdir := src
objlist := crt0 main

rom := snake.nes
config := $(srcdir)/nrom128.cfg

CC65 := cc65
CA65 := ca65
LD65 := ld65
CFLAGS65 :=
EMU := fceux

run: $(rom)
	$(EMU) $<

# Rules for PRG ROM

objlistfiles = $(foreach o,$(objlist),$(objdir)/$(o).o)

map.txt $(rom): $(objlistfiles) $(wildcard $(srcdir)/*)
	$(LD65) -o $(rom) -m map.txt -C $(config) $(objlistfiles) $(srcdir)/nes.lib

$(objdir)/%.o: $(srcdir)/%.s
	$(CA65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(CA65) $(CFLAGS65) $< -o $@

$(objdir)/%.s: $(srcdir)/%.c
	$(CC65) $(CFLAGS65) $< -o $@

clean:
	@rm -rf $(objdir)/*
