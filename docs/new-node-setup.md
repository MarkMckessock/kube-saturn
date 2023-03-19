## New Node Setup Process

### Nvidia GPU Considerations
1. Install Nvidia driver
2. Install Nvidia Container Runtime

     See her for more info: https://github.com/NVIDIA/k8s-device-plugin#preparing-your-gpu-nodes

    1. Install the nvidia-container-toolkit
    ```bash
          distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
          curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
          curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/libnvidia-container.list

          sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
    ```
    2. Modify the containerd config with the following. For K3s the config file is located at `/var/lib/rancher/k3s/agent/etc/containerd/config.toml`
    ```
    version = 2
    [plugins]
      [plugins."io.containerd.grpc.v1.cri"]
        [plugins."io.containerd.grpc.v1.cri".containerd]
          default_runtime_name = "nvidia"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
              privileged_without_host_devices = false
              runtime_engine = ""
              runtime_root = ""
              runtime_type = "io.containerd.runc.v2"
              [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
                BinaryName = "/usr/bin/nvidia-container-runtime"
      ```
3. Install NFS library
