<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        DoubleUnderlineGn.xsl
    # Purpose:     Change underline style to double on gn
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2016/05/06
    # Updates:
    # Copyright:   (c) 2016 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0">

    <!-- Recursive copy template -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="style:style[starts-with(@style:name, 'gn_')]/*[@style:text-underline-style]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="style:text-underline-type">double</xsl:attribute>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>