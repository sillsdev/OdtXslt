<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        PictureParaStyle.xsl
    # Purpose:     Set style of paragraph with a picture
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2014/01/17
    # Copyright:   (c) 2013 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    version="1.0">

    <!-- Recursive copy template -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text:p[count(@*) = 0]">
        <xsl:copy>
            <xsl:attribute name="text:style-name">
                <xsl:text>entry_letData_dicBody</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>