default: bin/main.nes

bin/main.nes: bin/asm6 generated/main.asm generated/undertale_a.chr generated/undertale_b.chr \
	generated/graphic_LesserDog.asm generated/graphic_Options.asm
	cd generated; \
		../bin/asm6 -L main.asm ../bin/main.nes ../bin/main.lst

bin/asm6: tools/asm6.c
	gcc $^ -o $@

generated/main.asm: src/*.asm
	./scripts/transform-asm.py < src/main.asm > $@

generated/graphic_Options.asm: graphics/Options.graphic
	./scripts/compile-graphic.py $< undertale_a.chr > $@

generated/graphic_LesserDog.asm: graphics/LesserDog.graphic
	./scripts/compile-graphic.py $< undertale_b.chr > $@

generated/undertale_a.chr: chrsets/undertale_a.chr
	./scripts/simplify-chrset.py $@ $^

generated/undertale_b.chr: chrsets/undertale_b.chr
	./scripts/simplify-chrset.py $@ $^

clean:
	rm -f generated/*
	rm -f bin/*
