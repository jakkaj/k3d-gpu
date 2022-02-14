Note: WSL doesnt work yet! 

Ensure you have nvidia-docker2 installed.

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

Ensure `nvidia-smi` returns something. 

If you're in Azure, ensure you have the NVIDIA GPU extension installed from hte portal on this VM (to install the drivers).

Install K3D

```bash
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

Create local container registry

```bash
k3d registry create
```

Find the address of it (will show in the command that returned - `k3d-registry:35169`).

In `run.sh` change the registry port to the one you just created. Leave the host as `localhost`. 

Run `run.sh`



This issue was the thing that got it through. 

https://github.com/k3s-io/k3s/issues/4070

Need to ensure you have 

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
   name: nvidia
handler: nv
```

apply the correct daemonset `https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.10.0/nvidia-device-plugin.yml` or what ever version is current :)

THen in that daemonset, add `runtimeClassName: nvidia` on the podspec. 

Do not modify config.toml.tmpl and things as per other tutorials, just leave it all - since 1.22 of k3s its much simpler to get going!




Notes:

https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html

```bash
helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --set driver.enabled=false \
      --set toolkit.enabled=false
```

https://www.google.com/search?q=k3s+nvidia.com%2Fgpu+runtimeclass&oq=k3s+nvidia.com%2Fgpu+runtimeclass&aqs=edge..69i57j69i64.3597j0j1&sourceid=chrome&ie=UTF-8