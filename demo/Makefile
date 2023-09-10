all: run

run: build
	sudo python3 run_exercise.py -t topology.json -b simple_switch_grpc

stop:
	sudo mn -c

build: dirs basic.json

basic.json: basic.p4
	p4c-bm2-ss --p4v 16 --p4runtime-files build/$(basename $@).p4.p4info.txt -o build/$@ $<

dirs:
	mkdir -p build pcaps logs

clean: stop
	rm -f *.pcap
	rm -rf build pcaps logs
