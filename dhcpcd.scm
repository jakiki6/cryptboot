(define-module (dhcpcd))

(use-modules (guix packages)
	     (gnu packages bash)
             (guix download)
	     (guix git-download)
             (guix build-system gnu)
             (guix licenses))

(define-public dhcpcd
  (package
    (name "dhcpcd")
    (version "10.0.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                      (url "https://github.com/NetworkConfiguration/dhcpcd")
                      (commit "v10.0.2")))
              (sha256
               (base32
                "1bhsbdibmpd83vsg58ywmfjfyqv3nyi3ajwfln1gvda8wmmr2sqk"))))
    (build-system gnu-build-system)
    (arguments
      '(#:configure-flags (list "CC=gcc") ; override reference to cc since the build breaks otherwise
        #:tests? #f ; doesn't have any tests
        #:phases (modify-phases %standard-phases
                   (add-before 'build 'remove-bin-sh-in-makefile
                      (lambda* (#:key outputs build-inputs #:allow-other-keys)
                        ; remove unnecessary reference to /bin/sh
                        (substitute* "src/Makefile"
                          (("\\$\\{HOST_SH\\}")
                           "sh"))
			; remove install of the database directory in /var during build
			; this is a bit hackish but the build breaks otherwise
                        (substitute* "src/Makefile"
                          (("\\$\\{INSTALL\\} \\-m \\$\\{DBMODE\\} \\-d \\$\\{DESTDIR\\}\\$\\{DBDIR\\}")
                          ""))
		        )))))
    (synopsis "DHCP / IPv4LL / IPv6RA / DHCPv6 client.")
    (description
     "dhcpcd is a DHCP and a DHCPv6 client. It's also an IPv4LL (aka ZeroConf) client. In layperson's terms, dhcpcd runs on your machine and silently configures your computer to work on the attached networks without trouble and mostly without configuration.")
    (home-page "https://roy.marples.name/projects/dhcpcd")
    (license bsd-2)))
