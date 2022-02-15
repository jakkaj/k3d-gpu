registry:
	k3d registry create -p 50051

cluster:
	./run.sh

deploy-test:
	kubectl apply -f ./cuda-vector-add.yaml
	
	@echo "\nif this doesnt work, just re-run the command or try running kubectl logs cuda-vector-add\n\n"
	
	kubectl logs cuda-vector-add