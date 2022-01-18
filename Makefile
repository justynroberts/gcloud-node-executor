all: install

clean:
	rm -rf build

build:
	mkdir -p build/zip/gcloud-node-executor-plugin
	cp src/plugin.yaml build/zip/gcloud-node-executor-plugin/
	cp -r src/contents build/zip/gcloud-node-executor-plugin/
	
	cd build/zip; zip -r gcloud-node-executor-plugin.zip *

