Name: cn24-cpu
License: BSD
BuildArch: x86_64
Group: Brust
Requires: libpng, libjpeg-turbo
Summary: Deep Learning Framework (CPU)
%description
CN24 Deep Learning Framework (CPU version).
%prep
%setup -q
%build
mkdir build
cd build
cmake3 -DCMAKE_BUILD_TYPE=Release ..
make -j12

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT && mkdir -p $RPM_BUILD_ROOT
echo "Installing to $RPM_BUILD_ROOT..."
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%{_libdir}
cp build/cn24-shell $RPM_BUILD_ROOT%{_bindir}
cp build/libcn24.* $RPM_BUILD_ROOT%{_libdir}

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%files
%{_bindir}/cn24-shell
%{_libdir}/libcn24.*
