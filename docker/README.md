# Docker usage

This image targets `x86_64`, ROS Noetic, CUDA 12.8, and NVIDIA GPUs such as
the RTX 5080. Install the host NVIDIA driver and NVIDIA Container Toolkit
first; the driver is not installed inside the image.

Build and open a shell:

```bash
docker compose build
docker compose run --rm gemini
```

Inside the container, verify CUDA and build a TensorRT engine for the current
GPU if needed:

```bash
python3 -c 'import torch; print(torch.cuda.get_device_name(0))'
source /root/gemini_ws/devel/setup.bash
rosrun FastFoundationStereo build_engine.py \
  --model /root/gemini_ws/src/FastFoundationStereo/models/onnx/448x256.onnx \
  --engine /root/gemini_ws/src/FastFoundationStereo/models/engine/448x256_rtx5080_fp16.engine
```

With the Orbbec camera connected to the host, start the two nodes in separate
shells (or use `docker compose exec gemini bash`):

```bash
roslaunch orbbec_camera gemini_330_series.launch
roslaunch FastFoundationStereo gemini335l_bringup.launch
```

`privileged: true` and `/dev/bus/usb` are intentional for USB camera access.
The compose file uses host networking so ROS nodes share the host network.
For RViz, allow the container with `xhost +local:docker` before starting it.
