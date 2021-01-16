.PHONY: run clean

ROM := snake.nes

AS65 := asm6
EMU := fceux

run: $(ROM)
	$(EMU) $<

$(ROM): $(wildcard src/*)
	$(AS65) src/cart.asm $@

clean:
	rm -f $(ROM)
