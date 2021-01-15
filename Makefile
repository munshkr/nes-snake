.PHONY: run clean

ROM := snake.nes

run: $(ROM)
	fceux $<

$(ROM): $(wildcard src/*)
	asm6 src/cart.asm $@

clean:
	rm -f $(ROM)
