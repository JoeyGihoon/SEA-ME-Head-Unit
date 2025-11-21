SUMMARY = "Run Instrument Cluster Shell Script"
LICENSE = "CLOSED"

SRC_URI = "file://select.sh"

do_install() {
    install -d ${D}${bindir}
    
    install -m 0755 ${S}/../select.sh ${D}${bindir}/select
}

FILES:${PN} = "${bindir}/select"
