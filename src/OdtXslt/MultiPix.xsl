<?xml version="1.0" encoding="UTF-8"?>
<!-- #############################################################
    # Name:        MovePix.xsl
    # Purpose:     Control Pictures per line
    #
    # Author:      Greg Trihus <greg_trihus@sil.org>
    #
    # Created:     2012/12/11
    # Updates:     
    # Copyright:   (c) 2012 SIL International
    # Licence:     <LPGL>
    ################################################################-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" 
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0">
    
    <xsl:param name="width">468pt</xsl:param>
    
    <!-- Recursive copy template -->   
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="//text:section/text:p/*/@svg:width">
        <xsl:attribute name="svg:width">
            <xsl:value-of select="$width"/>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>