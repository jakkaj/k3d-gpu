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