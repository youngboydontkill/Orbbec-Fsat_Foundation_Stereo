# Repository Guidelines

## Project Structure & Module Organization

This repository is a ROS 1 catkin workspace rooted at `gemini_ws/`. The top-level `src/` contains two packages:

- `src/FastFoundationStereo/`: custom stereo depth pipeline. Python ROS node code lives in `nodes/` and `src/fast_foundation_stereo/`; launch files are in `launch/`, camera configs in `config/`, helper scripts in `scripts/`, and ONNX/TensorRT assets in `models/`.
- `src/OrbbecSDK_ROS1-v2-main/`: the `orbbec_camera` driver package. Core C++ sources are in `src/`, public headers in `include/`, and camera assets or examples in `launch/`, `urdf/`, `meshes/`, and `examples/`.

Keep changes scoped to the package you are touching. Treat `OrbbecSDK_ROS1-v2-main` as upstream-style vendor code unless the task explicitly requires driver changes.

## Build, Test, and Development Commands

Run commands from the workspace root unless noted otherwise:

- `catkin_make`: build all catkin packages in `src/`.
- `source devel/setup.bash`: load the built workspace before running ROS tools.
- `roslaunch orbbec_camera gemini_330_series.launch`: start the Orbbec camera driver.
- `roslaunch FastFoundationStereo gemini335l_bringup.launch`: launch the stereo inference pipeline.
- `rosrun FastFoundationStereo build_engine.py`: build or refresh a TensorRT engine for a selected ONNX model.

If you only changed Python code, rebuild is often unnecessary, but always re-source `devel/setup.bash` before testing.

## Coding Style & Naming Conventions

Python follows the existing ROS style: 4-space indentation, `snake_case` for functions and variables, `PascalCase` for classes, and concise docstrings where behavior is not obvious. C++ in `orbbec_camera` uses 2-space indentation, braces on the same line, and `snake_case` or ROS-style member naming. Match the surrounding file instead of reformatting unrelated code.

Name launch files and configs descriptively, for example `gemini335l_bringup.launch` or `gemini335l_424x240.yaml`.

## Testing Guidelines

There is no committed automated test suite yet. The `FastFoundationStereo` `CMakeLists.txt` only contains commented test hooks, so validation is currently runtime-focused:

- build with `catkin_make`
- launch `orbbec_camera`
- launch `FastFoundationStereo`
- verify depth and disparity topics with `rostopic list` or RViz

Document manual validation steps in your change notes when behavior changes.

## Commit & Pull Request Guidelines

Recent `FastFoundationStereo` history uses short, imperative commit subjects such as `add downsample pipeline & sim camera propccess`. Keep subjects brief, action-first, and focused on one change. For pull requests, include the affected package, launch or hardware setup used for validation, parameter changes, and screenshots or topic snapshots when output images or RViz behavior changed.
