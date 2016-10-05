<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        NoHardSpace.xsl
    # Purpose:     Change hard spaces to regular spaces
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2013/03/12
    # Copyright:   (c) 2013 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

    <!-- Recursive copy template -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="translate(.,'&#xa0;',' ')"/>
    </xsl:template>

</xsl:stylesheet>