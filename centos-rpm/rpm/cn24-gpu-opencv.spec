Name: cn24-gpu-opencv
License: BSD
BuildArch: x86_64
Group: Brust
Requires: libpng, libjpeg-turbo, opencv
Summary: Deep Learning Framework (GPU)
%description
CN24 Deep Learning Framework (GPU version).
%prep
%setup -q
%build
# First, make clBLAS
git clone https://github.com/clMathLibraries/clBLAS -b v2.12
cd clBLAS
mkdir prefix
mkdir build
cd build
cmake3 -DBUILD_TEST=OFF ../src/
make DESTDIR=../prefix all install -j12
cd ../..

mkdir build
cd build
cmake3 -DCN24_BUILD_OPENCL=ON -DCN24_BUILD_OPENMP=ON -DCN24_BUILD_OPENCL_CLBLAS=ON -DCN24_BUILD_OPENCV=ON -DCMAKE_BUILD_TYPE=Release \
-DCLBLAS_LIBRARY=../clBLAS/prefix/usr/local/lib64/libclBLAS.so -DCLBLAS_INCLUDE_DIR=../clBLAS/prefix/usr/local/include ..
make -j12

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT && mkdir -p $RPM_BUILD_ROOT
echo "Installing to $RPM_BUILD_ROOT..."
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%{_libdir}
cp build/cn24-shell $RPM_BUILD_ROOT%{_bindir}
cp build/libcn24.* $RPM_BUILD_ROOT%{_libdir}

mkdir -p $RPM_BUILD_ROOT/usr/share/cn24/kernels
cp kernels/* $RPM_BUILD_ROOT/usr/share/cn24/kernels/
cp -r clBLAS/prefix/usr/local/lib64/libclBLAS.* $RPM_BUILD_ROOT%{_libdir}

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%files
%{_bindir}/cn24-shell
%{_libdir}/libcn24.*
%{_libdir}/libclBLAS.*
/usr/share/cn24/kernels/*
