This will help create a new k3s container that supports Nvidia GPUs for use with K3D! It's been updated to support a more streamlined approach than older examples. 

NOTE: This only works when the host machine (the one the container is running on) is running Linux. I've tested with LTS Ubuntu (i think 18.04, 20.04 are good... YMMV). 
NOTE: WSL doesnt work yet as of Feb 15th 22! Something something nvidia something. 

It's based on [https://k3d.io/v4.4.8/usage/guides/cuda/](https://k3d.io/v4.4.8/usage/guides/cuda/). It removes the containerd configs and a few other little bits (no longer needed in latest k3s, as it does it automatically when it detects nvidia stuff installed!), fixes the daemonset and adds a RuntimeClass and a few other little tunings


NOTE: There was a bug in `libnvidia-container` <=1.8.0 which was patched in [this commit](https://github.com/NVIDIA/libnvidia-container/commit/162f9ba9280e5d5f412778c8806384da2d4922c6) just a few days ago at the time of writing this. It's was not relased at the time, so I've compiled it and included it here. Compile from `libnvidia-container` is simple - just clone it, and run `make ubuntu18.04` (the version of the K3S container) and you're off to the races. 

If you see errors in the daemonset pod with `nvidia-runtime-cli` and cannot find `devices.allow` etc etc - then it's probably this libnvidia problem. 


# Host Set Up

On the host...

Ensure you have nvidia-docker2 installed on the host. Follow this: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

Ensure `nvidia-smi` returns something on the host. 

Ensure `docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi` something from the host as well!

If you're in Azure, ensure you have the NVIDIA GPU extension installed from hte portal on this VM (to install the drivers).

# VS Code Dev Container
Once the docker command is returning a valid `nvidia-smi` output, you're ready to load the project in the dev container. Just open in VS Code and make sure to then re-open in dev container. 

NOTE: You can remote SSH to a another machine that has GPU support or us running Linux (just in case you're on Windows in WSL!) and once there, you can use Code to re-open in devcontainer and it will do so on the remote machine! Remember to have all the nvidia drivers and things set up already on that remote machine!

Once in the dev container, swap in to the `k3d` folder:

Run `make registry`

Run `make cluster`

Check the outputs in `k9s` to ensure all the containers come up. Pay particular attention to the daemonset `nvidia-device-plugin`. If this comes up - it's probably going to all work. 

Once all pods are up, you can run `make deploy-test`. Watch in `k9s` or hammer `kubectl logs cuda-vector-add` to check the output. If this returns a valid output then you're golden. 

# No Dev Container


Install K3D

```bash
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

Create local container registry

```bash
k3d registry create -p 50051
```

Chagne in to k3d path and run `./run.sh`


# Some more info

The run script applies `device-plugin-daemonset.yaml` which creates the `RuntimeClass` and the daemonset which allows the GPU stuff to work. Once you get the cluster up and running, if the daemonset comes up withotu errors then GPU is working. 

https://github.com/k3s-io/k3s/issues/4070

Need to ensure you have which is in the daemonset file too. 

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
   name: nvidia
handler: nv
```

Apply the correct daemonset `https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.10.0/nvidia-device-plugin.yml` or what ever version is current :)

Then in that daemonset, need to make sure you have `runtimeClassName: nvidia` on the podspec. 

Do not modify config.toml.tmpl and things as per other tutorials, just leave it all - since 1.22 of k3s its much simpler to get going!

You can apply the `cuda-vector-add.yaml` file to really test if cuda is running. Note this file has `runtimeClassName: nvidia` too!

```
Vector addition of 50000 elements
│ Copy input data from the host memory to the CUDA device
│ CUDA kernel launch with 196 blocks of 256 threads
│ Copy output data from the CUDA device to the host memory
│ Test PASSED                                                                                                                                       │
│ Done 
```
