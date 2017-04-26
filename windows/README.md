# Prerequisites

- AMD APP SDK (even for NVIDIA users)
  - Install at least "OpenCL Runtime".

- Intel OpenCL driver for Xeon/Core
  - Install only if you don't have a gpu driver
  - Otherwise, tests will fail!

- MSYS 2 (using version 20161025)
  - Follow MSYS's installation instructions including running `pacman -Syu` etc.
  - Install the following packages:
  `mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-readline p7zip make unzip mingw-w64-x86_64-libwebp`

- Inno Setup (using version 5.5.9)
  - Also install Inno Download Plugin


# Building the setup package

*Note*: `cn24-distribution` should be a subfolder of the cn24 repo root

- Start MSYS2 MinGW 64
- Navigate to `cn24-distribution/windows/msys` folder
- Execute `./build-packages.sh`
- Check log for errors :)
- Run Inno Script Studio with `cn24-distribution/windows/inno/cn24.iss`
- Compile
