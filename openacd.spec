Name: openacd
Version: 0.9.5
Summary: OpenACD Call Center
Release: %{?buildno:%buildno}%{!?buildno:1}
Group: Applications/Communications
Vendor: OpenACD
Packager: Douglas Hubler
License: CPAL
AutoReqProv: no
URL: http://github.com/OpenACD/OpenACD/wiki
Source: OpenACD.tar.gz

BuildRequires: erlang

# unclear how to express >= R13B04 or >= R13B-04 ?
Requires: erlang

BuildRoot: %{_builddir}/%{name}-root

%description
OpenACD is a skills-based, Call Center software based on FreeSWITCH and built in erlang.

%prep
%setup -n OpenACD

%build
make compile

%install
make install DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%pre

%post

%files
%defattr(-,root,root,-)
%dir /%_lib/openacd
%dir /var/lib/openacd
%dir /var/log/openacd
%dir /etc/openacd
/%_lib/openacd/*
/var/lib/openacd/*
/etc/openacd/*
/bin/openacd
/bin/nodetool


%changelog
* Thu Apr 25 2012 Cristi Starasciuc <cristi@ezuce.com>
- New packaging closer to erlang standards
* Fri Jun 24 2011 Micah Warren <micahw@lordnull.com>
- Updated provider, url, and removed no longer needed enviroment variables.
* Thu Jan 27 2011 Douglas Hubler <douglas@hubler.us>
- Initial release
